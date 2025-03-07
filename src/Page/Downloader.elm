module Page.Downloader exposing (..)

import DateFormat
import Element exposing (Element, centerX, centerY, column, fill, height, htmlAttribute, px, row, width)
import Element.Background as Background
import Element.Border as Border
import File.Download
import Html.Attributes as HA
import Http exposing (Error(..))
import Json.Decode exposing (Decoder)
import Language exposing (Language, toLanguageMap)
import List.Extra as LE
import Maybe.Extra as ME
import Page.Downloader.CsvHelpers exposing (convertResult, resultListToCsvString, searchUrlRecord)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloadProgressTracker(..), DownloadState(..), DownloaderMsg(..))
import Page.Downloader.Task exposing (getTask)
import Page.Downloader.View
import Page.Keyboard as Keyboard
import Page.Keyboard.Model exposing (toKeyboardQuery)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs, buildQueryParameters, setPage, setRows)
import Page.RecordTypes.Search exposing (ResultsBody, SearchResult, resultsBodyDecoder, searchBodyDecoder)
import Page.Request exposing (createProbeRequestWithDecoder)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Components exposing (viewWindowTitleBar)
import Page.UI.Style exposing (colourScheme)
import Page.UpdateHelpers exposing (createProbeUrl, createSearchUrl)
import Request exposing (serverUrl)
import Session exposing (Session)
import Task exposing (Task)
import Task.Parallel as Parallel
import Time


init : { queryArgs : QueryArgs, keyboard : Maybe (Keyboard.Model KeyboardMsg), session : Session } -> DownloaderModel
init cfg =
    { queryToDownload = cfg.queryArgs
    , keyboardQueryToDownload = cfg.keyboard
    , session = cfg.session
    , downloadState = DownloadNotStarted
    , progress = NoProgress
    , timestamp = ""
    , includeSearchUrlInResults = False
    , taskQueue = []
    , resultsList = []
    }


downloadQueryParameters : Int -> { queryToDownload : QueryArgs, keyboardQueryToDownload : Maybe (Keyboard.Model KeyboardMsg) } -> String
downloadQueryParameters pageNumber { queryToDownload, keyboardQueryToDownload } =
    let
        notationQueryParameters =
            keyboardQueryToDownload
                |> ME.unwrap []
                    (\kq ->
                        toKeyboardQuery kq
                            |> buildNotationQueryParameters
                    )

        textQueryParameters =
            setPage pageNumber queryToDownload
                |> setRows 100
                |> buildQueryParameters
    in
    serverUrl [ "search" ] (List.append textQueryParameters notationQueryParameters)


queueTasks : List String -> Decoder a -> List (List (Task Http.Error a))
queueTasks urls decoder =
    List.map (\u -> getTask u decoder) urls
        |> LE.greedyGroupsOf 10


processResultsForSorting : List ResultsBody -> List ( Int, List SearchResult )
processResultsForSorting searchResults =
    List.map (\rb -> ( .thisPage rb.pagination, rb.items )) searchResults


update : DownloaderMsg -> DownloaderModel -> ( DownloaderModel, Cmd DownloaderMsg )
update msg model =
    case msg of
        ServerRespondedWithProbeData (Ok ( _, response )) ->
            let
                requestUrls =
                    LE.initialize (.totalPages response.pagination + 1)
                        (\pageNum ->
                            downloadQueryParameters pageNum
                                { queryToDownload = model.queryToDownload
                                , keyboardQueryToDownload = model.keyboardQueryToDownload
                                }
                        )
                        |> List.drop 1

                numUrls =
                    List.length requestUrls

                initialTaskQueue : List (List (Task Http.Error ResultsBody))
                initialTaskQueue =
                    queueTasks requestUrls resultsBodyDecoder

                -- take the first batch of tasks. If we can't, then the empty lists
                -- will simply be processed and nothing will happen.
                ( firstBatch, remainingQueue ) =
                    LE.uncons initialTaskQueue
                        |> Maybe.withDefault ( [], [] )

                ( initialState, fetchCmd ) =
                    Parallel.attemptList
                        { tasks = firstBatch
                        , onUpdates = RecordDownloadUpdated
                        , onFailure = RecordDownloadFailed
                        , onSuccess = RecordDownloadCompleted
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
                , progress = Progress 0 numUrls
                , taskQueue = remainingQueue
              }
            , Cmd.batch [ downloadStarted, fetchCmd ]
            )

        ServerRespondedWithProbeData (Err error) ->
            ( model, Cmd.none )

        ClientRespondedWithCurrentTime currentTime ->
            ( { model | timestamp = currentTime }, Cmd.none )

        RecordDownloadUpdated updates ->
            let
                downloadState =
                    model.downloadState

                ( downloadProgress, totalPages ) =
                    case model.progress of
                        Progress completed total ->
                            ( completed + 1, total )

                        NoProgress ->
                            ( 0, 0 )

                ( nextState, nextCmd ) =
                    case downloadState of
                        Downloading taskMsg ->
                            Parallel.updateList taskMsg updates
                                |> Tuple.mapFirst Downloading

                        _ ->
                            ( downloadState, Cmd.none )
            in
            ( { model
                | downloadState = nextState
                , progress = Progress downloadProgress totalPages
              }
            , nextCmd
            )

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
                    if List.length model.taskQueue == 0 then
                        let
                            fullResultsCsvList =
                                processResultsForSorting completed
                                    |> List.append model.resultsList
                                    |> List.sortBy Tuple.first
                                    |> List.map Tuple.second
                                    |> List.concat
                                    |> List.map convertResult
                                    |> resultListToCsvString

                            fileName =
                                "rism-online-search-results-" ++ model.timestamp ++ ".csv"

                            downloadCmd =
                                File.Download.string fileName "text/csv" fullResultsCsvList
                        in
                        { nextCmd = downloadCmd
                        , downloadState = DownloadCompleted completed
                        , downloadProgress = NoProgress
                        , taskQueue = model.taskQueue
                        , resultsList = []
                        }

                    else
                        let
                            _ =
                                Debug.log "Proceeding to the next batch" ""

                            resultsList =
                                processResultsForSorting completed

                            ( nextBatch, remainingQueue ) =
                                LE.uncons model.taskQueue
                                    |> Maybe.withDefault ( [], [] )

                            ( batchState, fetchCmd ) =
                                Parallel.attemptList
                                    { tasks = nextBatch
                                    , onUpdates = RecordDownloadUpdated
                                    , onFailure = RecordDownloadFailed
                                    , onSuccess = RecordDownloadCompleted
                                    }
                        in
                        { nextCmd = fetchCmd
                        , downloadState = Downloading batchState
                        , downloadProgress = model.progress
                        , taskQueue = remainingQueue
                        , resultsList = List.append model.resultsList resultsList
                        }
            in
            ( { model
                | downloadState = updateConfig.downloadState
                , progress = updateConfig.downloadProgress
                , taskQueue = updateConfig.taskQueue
                , resultsList = updateConfig.resultsList
              }
            , updateConfig.nextCmd
            )

        NothingHappenedWithTheDownloader ->
            ( model, Cmd.none )

        UserClickedDownloadButton ->
            let
                -- increasing the rows to 100 helps with the download speed.
                newQuery =
                    model.queryToDownload
                        |> setRows 100

                probeUrl =
                    createProbeUrl model.session
                        { nextQuery = newQuery
                        , keyboard = model.keyboardQueryToDownload
                        }
            in
            ( model, createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl )

        UserChangedIncludeSearchUrl checkState ->
            ( { model | includeSearchUrlInResults = checkState }, Cmd.none )


view :
    { language : Language
    , model : DownloaderModel
    , closeMsg : msg
    , userInteractedWithDownloaderMsg : DownloaderMsg -> msg
    }
    -> Element msg
view cfg =
    row
        [ width fill
        , height fill
        , Background.color colourScheme.translucentGrey
        , htmlAttribute (HA.attribute "style" "backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px); z-index:200;")
        ]
        [ column
            [ centerX
            , centerY
            , width (px 900)
            , height (px 300)
            , Background.color colourScheme.white
            , Border.color colourScheme.darkBlue
            , Border.width 3
            , htmlAttribute (HA.style "z-index" "10")
            , minimalDropShadow
            ]
            [ viewWindowTitleBar cfg.language (toLanguageMap "Download Search Results") cfg.closeMsg
            , Page.Downloader.View.view
                { language = cfg.language
                , model = cfg.model
                }
                |> Element.map cfg.userInteractedWithDownloaderMsg
            ]
        ]
