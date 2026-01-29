module Page.Record exposing
    ( Model
    , Msg
    , RecordConfig
    , init
    , load
    , recordPageRequest
    , recordSearchRequest
    , requestPreviewIfSelected
    , sourceFetchCmd
    , update
    )

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setAliasLabelMap, setDownloader, setQueryBuilder, setRangeFacetValues)
import Basics.Extra exposing (flip)
import Browser.Navigation as Nav
import Config as C
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Json.Decode as Decode exposing (Value)
import Language exposing (Language(..), extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (errorMessages)
import Maybe.Extra as ME
import Murmur3
import Page.Decoders exposing (recordResponseDecoder)
import Page.Downloader as Downloader
import Page.Downloader.Model as Downloader
import Page.Downloader.Msg as DownloaderMsg
import Page.Query exposing (QueryArgs, buildQueryParameters, defaultQueryArgs, setFilters, setMode, setNationalCollection, setNextQuery, setRows, toNextQuery)
import Page.QueryBuilder as QueryBuilder
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel, routeToCurrentRecordViewTab)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Search exposing (searchSubmit)
import Page.RecordTypes.ApiError exposing (apiErrorDecoder)
import Page.RecordTypes.Probe exposing (ProbeStatus(..), QueryValidation(..))
import Page.RecordTypes.SearchControl exposing (resultModeToSearchControlOption)
import Page.RecordTypes.Tombstone exposing (tombstoneDecoder)
import Page.Request exposing (createRequestWithDecoder)
import Page.Route exposing (Route(..), routeToResultMode)
import Page.UI.Animations exposing (PreviewAnimationStatus(..))
import Page.UI.Errors exposing (ErrorResponse(..), createErrorMessage)
import Page.UpdateHelpers exposing (applyKeywordInputWithProbe, applyPreviewResponse, chooseResponse, extractSearchResponseData, hasNonZeroSourcesAttached, probeSubmit, textQuerySuggestionSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedResultSorting, userChangedResultsPerPage, userChangedSelectFacetSort, userClickedClosePreviewWindow, userClickedFacetPanelToggle, userClickedResultForPreview, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedSingleChoiceFacetItem, userClickedToggleFacet, userEnteredTextInKeywordQueryBox, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userFocusedRangeFacet, userLostFocusOnRangeFacet, userPressedArrowKeysInSearchResultsList, userRemovedItemFromActiveFilters, userResetSingleChoiceFacet)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Request exposing (serverUrl)
import Response exposing (Response(..), ServerData(..))
import Result.Extra as RE
import SearchPreferences.SetPreferences exposing (SearchPreferenceVariant(..))
import Session exposing (Session)
import Set
import Set.Extra as SE
import Url exposing (Url)
import Utilities exposing (convertNodeIdToPath)
import Viewport exposing (jumpToIdIfNotVisible, resetViewportOf)


type alias Model =
    RecordPageModel RecordMsg


type alias Msg =
    RecordMsg


type alias RecordConfig =
    { incomingUrl : Url
    , route : Route
    , queryArgs : Maybe QueryArgs
    , initialData : Maybe Value
    , session : Session
    }


init : RecordConfig -> RecordPageModel RecordMsg
init cfg =
    let
        session =
            cfg.session

        resultMode =
            routeToResultMode cfg.route

        incomingData :
            { probeData : ProbeStatus
            , recordData : Response ServerData
            , searchData : Response ServerData
            }
        incomingData =
            case cfg.initialData of
                Just d ->
                    let
                        dval =
                            Decode.decodeValue recordResponseDecoder d
                    in
                    case dval of
                        Ok (SearchData sd) ->
                            { probeData =
                                ProbeSuccess
                                    { totalItems = sd.totalItems
                                    , queryStatus = NotCheckedQuery
                                    , pagination = sd.pagination
                                    }
                            , recordData = Loading Nothing
                            , searchData = Response (SearchData sd)
                            }

                        Ok rd ->
                            { probeData = NotChecked
                            , recordData = Response rd
                            , searchData = NoResponseToShow
                            }

                        Err _ ->
                            let
                                errorResponse =
                                    Decode.decodeValue tombstoneDecoder d
                                        |> Result.map (\t -> Error (GoneResponse { label = errorMessages.recordDeleted, tombstone = t }))
                                        |> RE.orElse
                                            (Decode.decodeValue apiErrorDecoder d
                                                |> Result.map (\o -> Error (BadBodyEncodedResponse { label = toLanguageMap "Unexpected response", errorMessage = o }))
                                            )
                                        |> Result.mapError
                                            (\er ->
                                                Error
                                                    (BadBodyResponse
                                                        { label = toLanguageMap "Unexpected response"
                                                        , description = Decode.errorToString er
                                                        }
                                                    )
                                            )
                            in
                            case errorResponse of
                                Ok o ->
                                    { probeData = NotChecked
                                    , recordData = o
                                    , searchData = NoResponseToShow
                                    }

                                Err er ->
                                    { probeData = NotChecked
                                    , recordData = er
                                    , searchData = NoResponseToShow
                                    }

                Nothing ->
                    { probeData = NotChecked
                    , recordData = Loading Nothing
                    , searchData = NoResponseToShow
                    }

        searchInterface =
            resultModeToSearchControlOption resultMode

        numRows =
            ME.unwrap C.defaultRows .resultsPerPage session.searchPreferences

        activeSearchInit =
            cfg.queryArgs
                |> ME.unpack (\() -> ActiveSearch.empty session.searchPreferences)
                    (\qa ->
                        ActiveSearch.init
                            { queryArgs = qa
                            , keyboardQueryArgs = Nothing
                            , session = cfg.session
                            }
                    )

        activeSearch =
            toNextQuery activeSearchInit
                |> setNationalCollection session.restrictedToNationalCollection
                |> setRows numRows
                |> setMode resultMode
                |> flip setNextQuery activeSearchInit

        selectedResult =
            .fragment cfg.incomingUrl
                |> Maybe.map (\f -> C.serverUrl ++ "/" ++ convertNodeIdToPath f)

        tabView =
            Url.toString cfg.incomingUrl
                |> routeToCurrentRecordViewTab cfg.route
    in
    { response = incomingData.recordData
    , currentTab = tabView
    , searchResults = incomingData.searchData
    , preview = NoResponseToShow
    , sourceItemsExpanded = False
    , incipitInfoExpanded = Set.empty
    , digitizedCopiesCalloutExpanded = False
    , selectedResult = selectedResult
    , activeSearch = activeSearch
    , probeResponse = incomingData.probeData
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , applyFilterPrompt = False
    , previewAnimationStatus = NoAnimation
    , showSearchControls = searchInterface
    }


load : RecordConfig -> RecordPageModel RecordMsg -> RecordPageModel RecordMsg
load cfg oldBody =
    let
        session =
            cfg.session

        resultMode =
            routeToResultMode cfg.route

        activeSearchInit =
            ActiveSearch.load oldBody.activeSearch

        initActiveSearch =
            ME.unpack (\() -> activeSearchInit) (\qa -> setNextQuery qa activeSearchInit) cfg.queryArgs

        activeSearch =
            toNextQuery initActiveSearch
                |> setNationalCollection session.restrictedToNationalCollection
                |> setMode resultMode
                |> flip setNextQuery initActiveSearch

        ( previewResp, selectedResult ) =
            .fragment cfg.incomingUrl
                |> ME.unwrap ( NoResponseToShow, Nothing ) (\f -> ( oldBody.preview, Just (C.serverUrl ++ "/" ++ convertNodeIdToPath f) ))

        tabView =
            Url.toString cfg.incomingUrl
                |> routeToCurrentRecordViewTab cfg.route
    in
    { oldBody
        | currentTab = tabView
        , preview = previewResp
        , selectedResult = selectedResult
        , activeSearch = activeSearch
    }


recordPagePreviewRequest : String -> Cmd RecordMsg
recordPagePreviewRequest previewUrl =
    createRequestWithDecoder ServerRespondedWithRecordPreview previewUrl


recordPageRequest : Bool -> Url -> Cmd RecordMsg
recordPageRequest applyCacheBuster initialUrl =
    let
        requestUrl =
            if applyCacheBuster then
                let
                    hash =
                        Murmur3.hashString 3006 initialUrl.path
                in
                { initialUrl
                    | query =
                        ME.unpack
                            (\() -> Just ("hash=" ++ String.fromInt hash))
                            (\q -> Just (q ++ ("&hash=" ++ String.fromInt hash)))
                            initialUrl.query
                }

            else
                initialUrl
    in
    Url.toString requestUrl
        |> createRequestWithDecoder ServerRespondedWithRecordData


recordSearchRequest : String -> Cmd RecordMsg
recordSearchRequest searchUrl =
    createRequestWithDecoder ServerRespondedWithPageSearch searchUrl


requestPreviewIfSelected : Maybe String -> Cmd RecordMsg
requestPreviewIfSelected selected =
    ME.unwrap Cmd.none recordPagePreviewRequest selected


update : Session -> RecordMsg -> RecordPageModel RecordMsg -> ( RecordPageModel RecordMsg, Cmd RecordMsg )
update session msg model =
    case msg of
        ServerRespondedWithPageSearch (Ok ( _, response )) ->
            let
                nextQuery =
                    toNextQuery model.activeSearch

                jumpCmd =
                    .fragment session.url
                        |> ME.unwrap Cmd.none (jumpToIdIfNotVisible ClientCompletedViewportJump "search-results-list")

                ( aliasLabelMap, updatedFiltersWithCorrectLanguageMaps, probeState ) =
                    case response of
                        SearchData body ->
                            let
                                searchData =
                                    extractSearchResponseData nextQuery.filters body
                            in
                            ( searchData.aliasLabelMap
                            , searchData.updatedFilters
                            , searchData.probeStatus
                            )

                        _ ->
                            ( Dict.empty, nextQuery.filters, NotChecked )

                newNextQuery =
                    setFilters updatedFiltersWithCorrectLanguageMaps nextQuery
                        |> setMode (routeToResultMode session.route)

                newActiveSearch =
                    setAliasLabelMap aliasLabelMap model.activeSearch
                        |> setNextQuery newNextQuery

                searchResults =
                    case response of
                        SearchData _ ->
                            Response response

                        _ ->
                            NoResponseToShow

                -- The record data gets reset to Loading when submitting the search, so just get the
                -- old data (if it's there) and add it back to the model.
                -- if it's any other response than "Loading", then just keep it in that state.
                recordResponse =
                    case model.response of
                        Loading (Just oldData) ->
                            Response oldData

                        _ ->
                            model.response
            in
            ( { model
                | response = recordResponse
                , searchResults = searchResults
                , activeSearch = newActiveSearch
                , probeResponse = probeState
                , applyFilterPrompt = False
              }
            , jumpCmd
            )

        ServerRespondedWithPageSearch (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Ok ( _, response )) ->
            ( { model
                | probeResponse = ProbeSuccess response
                , applyFilterPrompt = True
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Err _) ->
            ( model, Cmd.none )

        ServerRespondedWithRecordData (Ok ( _, response )) ->
            let
                resultsStatus =
                    case model.searchResults of
                        NoResponseToShow ->
                            if hasNonZeroSourcesAttached response then
                                NoResponseToShow

                            else
                                model.searchResults

                        _ ->
                            model.searchResults
            in
            ( { model
                | response = Response response
                , searchResults = resultsStatus
              }
            , updatePageMetadata response
            )

        ServerRespondedWithRecordData (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        ServerRespondedWithRecordPreview result ->
            ( applyPreviewResponse result model
            , Cmd.none
            )

        ServerRespondedWithSuggestionData (Ok ( _, response )) ->
            ( setActiveSuggestion (Just response) model.activeSearch
                |> flip setActiveSearch model
            , Cmd.none
            )

        ServerRespondedWithSuggestionData (Err _) ->
            ( model, Cmd.none )

        ClientCompletedViewportJump ->
            ( model, Cmd.none )

        ClientCompletedViewportReset ->
            ( model, Cmd.none )

        ClientStartedAnimatingPreviewWindowClose ->
            ( { model
                | previewAnimationStatus = NoAnimation
              }
            , Cmd.none
            )

        ClientFinishedAnimatingPreviewWindowShow ->
            ( { model | previewAnimationStatus = ShownAndNotMoving }
            , Cmd.none
            )

        DebouncerCapturedProbeRequest recordMsg ->
            Debouncer.update (update session) updateDebouncerProbeConfig recordMsg model

        DebouncerSettledToSendProbeRequest ->
            probeSubmit ServerRespondedWithProbeData session model

        DebouncerCapturedQueryFacetSuggestionRequest suggestMsg ->
            Debouncer.update (update session) updateDebouncerSuggestConfig suggestMsg model

        DebouncerSettledToSendQueryFacetSuggestionRequest suggestionUrl ->
            ( model
            , textQuerySuggestionSubmit suggestionUrl ServerRespondedWithSuggestionData
            )

        UserClickedFacetPanelToggle panelAlias expandedPanels ->
            userClickedFacetPanelToggle panelAlias expandedPanels model

        UserEnteredTextInKeywordQueryBox queryText ->
            let
                debounceMsg =
                    provideInput DebouncerSettledToSendProbeRequest
                        |> DebouncerCapturedProbeRequest
            in
            applyKeywordInputWithProbe
                { applyInput = userEnteredTextInKeywordQueryBox
                , debounceMsg = debounceMsg
                , model = model
                , queryText = queryText
                , updateFn = update session
                }

        UserClickedToggleFacet alias ->
            userClickedToggleFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        UserChangedFacetBehaviour alias facetBehaviour ->
            userChangedFacetBehaviour alias facetBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

        UserEnteredTextInQueryFacet alias query suggestionUrl ->
            let
                debounceMsg =
                    String.append suggestionUrl query
                        |> DebouncerSettledToSendQueryFacetSuggestionRequest
                        |> provideInput
                        |> DebouncerCapturedQueryFacetSuggestionRequest
            in
            userEnteredTextInQueryFacet alias query model
                |> update session debounceMsg

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromActiveFilters alias query model
                |> probeSubmit ServerRespondedWithProbeData session

        UserChoseOptionForQueryFacet alias selectedValue currentBehaviour ->
            updateQueryFacetFilters alias selectedValue currentBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

        UserEnteredTextInRangeFacet alias inputBox value ->
            ( userEnteredTextInRangeFacet alias inputBox value model
            , Cmd.none
            )

        UserFocusedRangeFacet alias ->
            userFocusedRangeFacet alias model

        UserLostFocusRangeFacet alias ->
            userLostFocusOnRangeFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        UserChangedSelectFacetSort alias facetSort ->
            ( userChangedSelectFacetSort alias facetSort model
            , Cmd.none
            )

        UserClickedSelectFacetExpand alias ->
            ( userClickedSelectFacetExpand alias model
            , Cmd.none
            )

        UserClickedSelectFacetItem alias facetValue label ->
            userClickedSelectFacetItem alias facetValue label model
                |> probeSubmit ServerRespondedWithProbeData session

        UserClickedSingleChoiceFacetItem alias facetValue label ->
            userClickedSingleChoiceFacetItem alias facetValue label model
                |> probeSubmit ServerRespondedWithProbeData session

        UsersClickedSingleChoiceReset alias ->
            userResetSingleChoiceFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        UserTriggeredSearchSubmit ->
            searchSubmit session model

        UserRemovedActiveFilter alias value ->
            userRemovedItemFromActiveFilters alias value model
                |> probeSubmit ServerRespondedWithProbeData session

        UserResetAllFilters ->
            let
                qargs =
                    Maybe.map .resultsPerPage session.searchPreferences
                        |> defaultQueryArgs
            in
            setNextQuery qargs model.activeSearch
                |> setRangeFacetValues Dict.empty
                |> flip setActiveSearch model
                |> searchSubmit session

        UserChangedResultSorting sort ->
            userChangedResultSorting sort model
                |> searchSubmit session

        UserChangedResultsPerPage num ->
            let
                intNum =
                    String.toInt num
                        |> Maybe.withDefault C.defaultRows

                ( newModel, updateCmd ) =
                    userChangedResultsPerPage num model
                        |> searchSubmit session
            in
            ( newModel
            , Cmd.batch
                [ updateCmd
                , PortSendSaveSearchPreference
                    { key = "resultsPerPage"
                    , value = IntPreference intNum
                    }
                    |> encodeMessageForPortSend
                    |> sendOutgoingMessageOnPort
                ]
            )

        UserClickedSearchResultsPagination pageUrl ->
            let
                searchResultsStatus =
                    if pageUrl == Url.toString session.url then
                        model.searchResults

                    else
                        Loading (chooseResponse model.searchResults)
            in
            ( { model
                | searchResults = searchResultsStatus
                , preview = NoResponseToShow
              }
            , Cmd.batch
                [ Nav.pushUrl session.key pageUrl
                , resetViewportOf ClientCompletedViewportReset "search-results-list"
                ]
            )

        UserClickedSearchResultForPreview result ->
            userClickedResultForPreview result session model

        UserClickedExpandSourceItemsSectionInPreview ->
            ( { model
                | sourceItemsExpanded = not model.sourceItemsExpanded
              }
            , Cmd.none
            )

        UserClickedExpandIncipitInfoSectionInPreview incipitIdent ->
            ( { model
                | incipitInfoExpanded = SE.toggle incipitIdent model.incipitInfoExpanded
              }
            , Cmd.none
            )

        UserClickedExpandDigitalCopiesCallout ->
            ( { model
                | digitizedCopiesCalloutExpanded = not model.digitizedCopiesCalloutExpanded
              }
            , Cmd.none
            )

        UserClickedClosePreviewWindow ->
            userClickedClosePreviewWindow session model

        UserClickedRecordViewTab recordTab ->
            let
                cmd =
                    case recordTab of
                        DefaultRecordViewTab recordUrl ->
                            Nav.pushUrl session.key recordUrl

                        ContentsSearchDisplayTab searchUrl ->
                            case model.searchResults of
                                -- if there is already a response, then don't refresh it when we switch tabs
                                Response _ ->
                                    Nav.pushUrl session.key searchUrl

                                _ ->
                                    Cmd.batch
                                        [ recordSearchRequest searchUrl
                                        , Nav.pushUrl session.key searchUrl
                                        ]
            in
            ( { model
                | currentTab = recordTab
              }
            , cmd
            )

        UserPressedAnArrowKey arrowDirection ->
            userPressedArrowKeysInSearchResultsList arrowDirection session model

        UserClickedOpenQueryBuilder ->
            ( { model
                | activeSearch = setQueryBuilder (Just QueryBuilder.init) model.activeSearch
              }
            , Cmd.none
            )

        UserClickedCloseQueryBuilder ->
            ( { model
                | activeSearch = setQueryBuilder Nothing model.activeSearch
              }
            , Cmd.none
            )

        UserInteractedWithQueryBuilder _ ->
            ( model, Cmd.none )

        UserInteractedWithDownloader DownloaderMsg.ClientWantsToCloseTheWindow ->
            ( { model
                | activeSearch = setDownloader Nothing model.activeSearch
              }
            , Cmd.none
            )

        UserInteractedWithDownloader downloaderMsg ->
            case .downloader model.activeSearch of
                Just downloaderModel ->
                    let
                        ( dModel, dCmd ) =
                            Downloader.update downloaderMsg downloaderModel

                        newModel =
                            setDownloader (Just dModel) model.activeSearch
                                |> flip setActiveSearch model
                    in
                    ( newModel, Cmd.map UserInteractedWithDownloader dCmd )

                Nothing ->
                    ( model, Cmd.none )

        UserClickedOpenDownloader ->
            let
                modelCfg =
                    { keyboard = .keyboard model.activeSearch
                    , queryArgs = .nextQuery model.activeSearch
                    , session = session
                    }
            in
            ( { model
                | activeSearch = setDownloader (Just (Downloader.init modelCfg)) model.activeSearch
              }
            , Cmd.none
            )

        UserClickedCloseDownloader ->
            ( { model
                | activeSearch = setDownloader Nothing model.activeSearch
              }
            , Cmd.none
            )

        NothingHappened ->
            ( model, Cmd.none )


updateDebouncerProbeConfig : Debouncer.UpdateConfig RecordMsg (RecordPageModel RecordMsg)
updateDebouncerProbeConfig =
    { mapMsg = DebouncerCapturedProbeRequest
    , getDebouncer = .probeDebouncer
    , setDebouncer = \debouncer model -> { model | probeDebouncer = debouncer }
    }


updateDebouncerSuggestConfig : Debouncer.UpdateConfig RecordMsg (RecordPageModel RecordMsg)
updateDebouncerSuggestConfig =
    { mapMsg = DebouncerCapturedQueryFacetSuggestionRequest
    , getDebouncer = \model -> .activeSuggestionDebouncer model.activeSearch
    , setDebouncer =
        \debouncer model ->
            model.activeSearch
                |> setActiveSuggestionDebouncer debouncer
                |> flip setActiveSearch model
    }


updatePageMetadata : ServerData -> Cmd msg
updatePageMetadata incomingData =
    case incomingData of
        SourceData sourceBody ->
            let
                title =
                    extractLabelFromLanguageMap English sourceBody.label

                fullDescription =
                    sourceBody.creator
                        |> ME.unwrap title
                            (\c ->
                                ME.unpack
                                    (\() ->
                                        ME.unwrap title (\nm -> extractLabelFromLanguageMap English nm ++ ": " ++ title) c.name
                                    )
                                    (\n -> extractLabelFromLanguageMap English n.label ++ ": " ++ title)
                                    c.relatedTo
                            )
            in
            PortSendHeaderMetaInfo { description = fullDescription }
                |> encodeMessageForPortSend
                |> sendOutgoingMessageOnPort

        PersonData personBody ->
            PortSendHeaderMetaInfo { description = extractLabelFromLanguageMap English personBody.label }
                |> encodeMessageForPortSend
                |> sendOutgoingMessageOnPort

        InstitutionData instBody ->
            PortSendHeaderMetaInfo { description = extractLabelFromLanguageMap English instBody.label }
                |> encodeMessageForPortSend
                |> sendOutgoingMessageOnPort

        _ ->
            Cmd.none


sourceFetchCmd : RecordPageModel RecordMsg -> Url -> Route -> Cmd RecordMsg
sourceFetchCmd body initialUrl route =
    let
        shouldFetchSources =
            case route of
                SourcePageRoute _ ->
                    Just "/contents"

                SourceContentsPageRoute _ _ ->
                    Just ""

                PersonPageRoute _ ->
                    Just "/sources"

                PersonSourcePageRoute _ _ ->
                    Just ""

                InstitutionPageRoute _ ->
                    Just "/sources"

                InstitutionSourcePageRoute _ _ ->
                    Just ""

                PublicationPageRoute _ ->
                    Just "/works"

                PublicationWorksPageRoute _ _ ->
                    Just ""

                WorkPageRoute _ ->
                    Just "/sources"

                WorkSourcePageRoute _ _ ->
                    Just ""

                _ ->
                    Nothing
    in
    case shouldFetchSources of
        Just contentsUrlSuffix ->
            let
                resultMode =
                    routeToResultMode route

                qps =
                    toNextQuery body.activeSearch
                        |> setMode resultMode
                        |> buildQueryParameters

                sourceContentsPath =
                    if String.endsWith "/" initialUrl.path then
                        initialUrl.path ++ String.dropLeft 1 contentsUrlSuffix

                    else
                        initialUrl.path ++ contentsUrlSuffix

                sourcesUrl =
                    serverUrl [ sourceContentsPath ] qps
            in
            recordSearchRequest sourcesUrl

        Nothing ->
            Cmd.none
