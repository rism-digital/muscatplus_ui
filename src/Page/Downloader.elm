module Page.Downloader exposing (update, view)

import Cmd.Extra as CE
import DateFormat
import Element exposing (Element)
import File.Download
import Http
import Http.Detailed
import Json.Decode exposing (Decoder)
import Language exposing (Language)
import List.Extra as LE
import Page.Downloader.CsvHelpers exposing (convertResult, createSearchUrlRecord, resultListToCsvString)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloadProgressTracker(..), DownloadState(..), DownloaderMsg(..))
import Page.Downloader.View
import Page.Query exposing (setPage, setRows)
import Page.RecordTypes.Search exposing (ResultsBody, SearchResult, resultsBodyDecoder)
import Page.Request exposing (createProbeRequestWithDecoder)
import Page.UpdateHelpers exposing (createProbeUrl, createSearchUrl)
import Task exposing (Task)
import Task.Parallel as Parallel
import Time


getTask : Decoder a -> String -> Task (Http.Detailed.Error String) ( Http.Metadata, a )
getTask decoder path =
    Http.task
        { body = Http.emptyBody
        , headers = [ Http.header "Accept" "application/ld+json" ]
        , method = "get"
        , resolver = Http.Detailed.responseToJson decoder |> Http.stringResolver
        , timeout = Nothing
        , url = path
        }


queueTasks : List String -> Decoder a -> List (List (Task (Http.Detailed.Error String) ( Http.Metadata, a )))
queueTasks urls decoder =
    List.map (getTask decoder) urls
        |> LE.greedyGroupsOf 10


processResultsForSorting : List ( Http.Metadata, ResultsBody ) -> List ( Int, List SearchResult )
processResultsForSorting searchResults =
    List.map (\( _, rb ) -> ( .thisPage rb.pagination, rb.items )) searchResults


type alias ContinueOrFinishRecord =
    { downloadProgress : DownloadProgressTracker
    , downloadState : DownloadState
    , nextCmd : Cmd DownloaderMsg
    , resultsList : List ( Int, List SearchResult )
    , taskQueue : List (List (Task (Http.Detailed.Error String) ( Http.Metadata, ResultsBody )))
    }


continueOrFinish :
    DownloaderModel
    -> List ( Http.Metadata, ResultsBody )
    -> ContinueOrFinishRecord
continueOrFinish model completed =
    if List.isEmpty model.taskQueue then
        -- finish
        let
            fullResultsList =
                processResultsForSorting completed
                    |> List.append model.resultsList
                    |> List.sortBy Tuple.first
                    |> List.concatMap Tuple.second
                    |> List.map convertResult

            injectedSearchUrlList =
                if model.includeSearchUrlInResults then
                    let
                        searchUrlEntry =
                            createSearchUrl model.session
                                { keyboard = model.keyboardQueryToDownload
                                , nextQuery = model.queryToDownload
                                }
                                |> createSearchUrlRecord (.mode model.queryToDownload)
                    in
                    searchUrlEntry :: fullResultsList

                else
                    fullResultsList

            fileName =
                "rism-online-search-results-" ++ model.timestamp ++ ".csv"

            downloadAndCloseCmd =
                Cmd.batch
                    [ resultListToCsvString injectedSearchUrlList
                        |> File.Download.string fileName "text/csv"
                    , CE.perform ClientWantsToCloseTheWindow
                    ]
        in
        { downloadProgress = NoProgress
        , downloadState = DownloadCompleted
        , nextCmd = downloadAndCloseCmd
        , resultsList = []
        , taskQueue = model.taskQueue
        }

    else
        -- continue
        let
            resultsList =
                processResultsForSorting completed

            ( nextBatch, remainingQueue ) =
                LE.uncons model.taskQueue
                    |> Maybe.withDefault ( [], [] )

            ( batchState, fetchCmd ) =
                Parallel.attemptList
                    { onFailure = RecordDownloadFailed
                    , onSuccess = RecordDownloadCompleted
                    , onUpdates = RecordDownloadUpdated
                    , tasks = nextBatch
                    }
        in
        { downloadProgress = model.progress
        , downloadState = Downloading batchState
        , nextCmd = fetchCmd
        , resultsList = List.append model.resultsList resultsList
        , taskQueue = remainingQueue
        }


update : DownloaderMsg -> DownloaderModel -> ( DownloaderModel, Cmd DownloaderMsg )
update msg model =
    case msg of
        ServerRespondedWithProbeData (Ok ( _, response )) ->
            let
                -- there is no "0"th page, and the setPage function changes any 0 to 1, so the
                -- resulting URLs have two page 1 requests. That's why we List.drop 1 at the end.
                -- A page count of 100 minimizes the number of requests we need to do.
                requestUrls =
                    LE.initialize (.totalPages response.pagination + 1)
                        (\pageNum ->
                            createSearchUrl model.session
                                { keyboard = model.keyboardQueryToDownload
                                , nextQuery =
                                    setPage pageNum model.queryToDownload
                                        |> setRows 100
                                }
                        )
                        |> List.drop 1

                -- take the first batch of tasks. If we can't, then the empty lists
                -- will simply be processed and nothing will happen.
                -- "uncons" is like "pop" except it returns the first result and the
                -- rest of the list.
                ( firstBatch, remainingQueue ) =
                    queueTasks requestUrls resultsBodyDecoder
                        |> LE.uncons
                        |> Maybe.withDefault ( [], [] )

                ( initialState, fetchCmd ) =
                    Parallel.attemptList
                        { onFailure = RecordDownloadFailed
                        , onSuccess = RecordDownloadCompleted
                        , onUpdates = RecordDownloadUpdated
                        , tasks = firstBatch
                        }

                downloadStarted =
                    Task.map2
                        (\h n ->
                            DateFormat.format
                                [ DateFormat.yearNumber
                                , DateFormat.text "-"
                                , DateFormat.monthFixed
                                , DateFormat.text "-"
                                , DateFormat.dayOfMonthFixed
                                , DateFormat.text "_"
                                , DateFormat.hourMilitaryFixed
                                , DateFormat.minuteFixed
                                ]
                                h
                                n
                        )
                        Time.here
                        Time.now
                        |> Task.perform ClientRespondedWithCurrentTime
            in
            ( { model
                | downloadState = Downloading initialState
                , progress = Progress 0 (List.length requestUrls)
                , taskQueue = remainingQueue
              }
            , Cmd.batch [ downloadStarted, fetchCmd ]
            )

        ServerRespondedWithProbeData (Err error) ->
            ( { model
                | downloadState = ErrorDownloading error
                , progress = NoProgress
              }
            , Cmd.none
            )

        ClientRespondedWithCurrentTime currentTime ->
            ( { model
                | timestamp = currentTime
              }
            , Cmd.none
            )

        ClientWantsToCloseTheWindow ->
            -- this is handled in the calling update function
            ( model, Cmd.none )

        RecordDownloadUpdated updates ->
            case model.downloadState of
                Downloading taskMsg ->
                    let
                        ( downloadProgress, totalPages ) =
                            case model.progress of
                                NoProgress ->
                                    ( 0, 0 )

                                Progress completed total ->
                                    ( completed + 1, total )

                        ( nextState, nextCmd ) =
                            Parallel.updateList taskMsg updates
                                |> Tuple.mapFirst Downloading
                    in
                    ( { model
                        | downloadState = nextState
                        , progress = Progress downloadProgress totalPages
                      }
                    , nextCmd
                    )

                _ ->
                    ( model, Cmd.none )

        RecordDownloadFailed failure ->
            ( { model
                | downloadState = ErrorDownloading failure
                , progress = NoProgress
              }
            , Cmd.none
            )

        RecordDownloadCompleted completed ->
            let
                updateConfig =
                    continueOrFinish model completed
            in
            ( { model
                | downloadState = updateConfig.downloadState
                , progress = updateConfig.downloadProgress
                , taskQueue = updateConfig.taskQueue
                , resultsList = updateConfig.resultsList
              }
            , updateConfig.nextCmd
            )

        UserClickedDownloadButton ->
            let
                -- use a probe request to find out how many pages, etc. will be
                -- needed if we increase the number of results per page to 100.
                -- increasing the rows to 100 helps with the download speed.
                probeUrl =
                    createProbeUrl model.session
                        { keyboard = model.keyboardQueryToDownload
                        , nextQuery =
                            model.queryToDownload
                                |> setRows 100
                        }
            in
            ( model
            , createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl
            )

        UserClickedCancelDownloadButton ->
            ( { model
                | downloadState = DownloadCancelled
                , progress = NoProgress
                , timestamp = ""
                , taskQueue = []
                , resultsList = []
              }
            , Cmd.none
            )

        UserChangedIncludeSearchUrl checkState ->
            ( { model
                | includeSearchUrlInResults = checkState
              }
            , Cmd.none
            )


view :
    { closeMsg : msg
    , language : Language
    , model : DownloaderModel
    , userInteractedWithDownloaderMsg : DownloaderMsg -> msg
    }
    -> Element msg
view cfg =
    Page.Downloader.View.view cfg
