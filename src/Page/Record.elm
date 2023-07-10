module Page.Record exposing
    ( Model
    , Msg
    , RecordConfig
    , init
    , load
    , recordPageRequest
    , recordSearchRequest
    , requestPreviewIfSelected
    , update
    )

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setRangeFacetValues)
import Browser.Navigation as Nav
import Config as C
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Flip exposing (flip)
import Language exposing (Language(..), extractLabelFromLanguageMap)
import Page.Query exposing (QueryArgs, defaultQueryArgs, setNationalCollection, setNextQuery, toNextQuery)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel, routeToCurrentRecordViewTab)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Search exposing (searchSubmit)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.Request exposing (createRequestWithDecoder)
import Page.Route exposing (Route)
import Page.UpdateHelpers exposing (hasNonZeroSourcesAttached, probeSubmit, textQuerySuggestionSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedResultSorting, userChangedResultsPerPage, userChangedSelectFacetSort, userClickedClosePreviewWindow, userClickedFacetPanelToggle, userClickedResultForPreview, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInKeywordQueryBox, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userFocusedRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Response exposing (Response(..), ServerData(..))
import SearchPreferences exposing (SearchPreferences)
import Session exposing (Session)
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
    , nationalCollection : Maybe CountryCode
    , searchPreferences : Maybe SearchPreferences
    }


init : RecordConfig -> RecordPageModel RecordMsg
init cfg =
    let
        activeSearchInit =
            case cfg.queryArgs of
                Just qa ->
                    ActiveSearch.init
                        { queryArgs = qa
                        , keyboardQueryArgs = Nothing
                        , searchPreferences = cfg.searchPreferences
                        }

                Nothing ->
                    ActiveSearch.empty cfg.searchPreferences

        activeSearch =
            toNextQuery activeSearchInit
                |> setNationalCollection cfg.nationalCollection
                |> flip setNextQuery activeSearchInit

        selectedResult =
            .fragment cfg.incomingUrl
                |> Maybe.map (\f -> C.serverUrl ++ "/" ++ convertNodeIdToPath f)

        tabView =
            Url.toString cfg.incomingUrl
                |> routeToCurrentRecordViewTab cfg.route
    in
    { response = Loading Nothing
    , currentTab = tabView
    , searchResults = NoResponseToShow
    , preview = NoResponseToShow
    , sourceItemsExpanded = False
    , selectedResult = selectedResult
    , activeSearch = activeSearch
    , probeResponse = Loading Nothing
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , applyFilterPrompt = False
    }


load : RecordConfig -> RecordPageModel RecordMsg -> RecordPageModel RecordMsg
load cfg oldBody =
    let
        activeSearchInit =
            ActiveSearch.load oldBody.activeSearch

        initActiveSearch =
            toNextQuery activeSearchInit
                |> setNationalCollection cfg.nationalCollection
                |> flip setNextQuery activeSearchInit

        activeSearch =
            case cfg.queryArgs of
                Just qa ->
                    setNextQuery qa initActiveSearch

                Nothing ->
                    initActiveSearch

        ( previewResp, selectedResult ) =
            case .fragment cfg.incomingUrl of
                Just f ->
                    ( oldBody.preview, Just (C.serverUrl ++ "/" ++ convertNodeIdToPath f) )

                Nothing ->
                    ( NoResponseToShow, Nothing )

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


recordPageRequest : Url -> Cmd RecordMsg
recordPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithRecordData (Url.toString initialUrl)


recordSearchRequest : Url -> Cmd RecordMsg
recordSearchRequest searchUrl =
    createRequestWithDecoder ServerRespondedWithPageSearch (Url.toString searchUrl)


requestPreviewIfSelected : Maybe String -> Cmd RecordMsg
requestPreviewIfSelected selected =
    case selected of
        Just s ->
            recordPagePreviewRequest s

        Nothing ->
            Cmd.none


update : Session -> RecordMsg -> RecordPageModel RecordMsg -> ( RecordPageModel RecordMsg, Cmd RecordMsg )
update session msg model =
    case msg of
        ServerRespondedWithPageSearch (Ok ( _, response )) ->
            let
                jumpCmd =
                    case .fragment session.url of
                        Just frag ->
                            jumpToIdIfNotVisible ClientCompletedViewportJump "search-results-list" frag

                        Nothing ->
                            Cmd.none

                probeState =
                    case response of
                        SearchData body ->
                            if body.totalItems == 0 then
                                NoResponseToShow

                            else
                                Response { modes = body.modes, totalItems = body.totalItems }

                        _ ->
                            NoResponseToShow

                searchResults =
                    case response of
                        SearchData _ ->
                            Response response

                        _ ->
                            NoResponseToShow
            in
            ( { model
                | searchResults = searchResults
                , probeResponse = probeState
                , applyFilterPrompt = False
              }
            , jumpCmd
            )

        ServerRespondedWithPageSearch (Err error) ->
            ( { model
                | response = Error error
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Ok ( _, response )) ->
            ( { model
                | probeResponse = Response response
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
                            let
                                hasSourcesAttached =
                                    hasNonZeroSourcesAttached response
                            in
                            if hasSourcesAttached then
                                Loading Nothing

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
                | response = Error error
              }
            , Cmd.none
            )

        ServerRespondedWithRecordPreview (Ok ( _, response )) ->
            ( { model
                | preview = Response response
                , sourceItemsExpanded = False
              }
            , Cmd.none
            )

        ServerRespondedWithRecordPreview (Err error) ->
            ( { model
                | preview = Error error
                , sourceItemsExpanded = False
              }
            , Cmd.none
            )

        ServerRespondedWithSuggestionData (Ok ( _, response )) ->
            let
                newModel =
                    setActiveSuggestion (Just response) model.activeSearch
                        |> flip setActiveSearch model
            in
            ( newModel, Cmd.none )

        ServerRespondedWithSuggestionData (Err _) ->
            ( model, Cmd.none )

        ClientCompletedViewportJump ->
            ( model, Cmd.none )

        ClientCompletedViewportReset ->
            ( model, Cmd.none )

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
            userEnteredTextInKeywordQueryBox queryText model
                |> update session debounceMsg

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
            userRemovedItemFromQueryFacet alias query model
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

        UserClickedSelectFacetItem alias facetValue ->
            userClickedSelectFacetItem alias facetValue model
                |> probeSubmit ServerRespondedWithProbeData session

        UserTriggeredSearchSubmit ->
            searchSubmit session model

        UserResetAllFilters ->
            setNextQuery defaultQueryArgs model.activeSearch
                |> setRangeFacetValues Dict.empty
                |> flip setActiveSearch model
                |> searchSubmit session

        UserChangedResultSorting sort ->
            userChangedResultSorting sort model
                |> searchSubmit session

        UserChangedResultsPerPage num ->
            userChangedResultsPerPage num model
                |> searchSubmit session

        UserClickedSearchResultsPagination pageUrl ->
            let
                oldData =
                    case model.searchResults of
                        Response d ->
                            Just d

                        _ ->
                            Nothing
            in
            ( { model
                | searchResults = Loading oldData
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

        UserClickedClosePreviewWindow ->
            userClickedClosePreviewWindow session model

        UserClickedRecordViewTab recordTab ->
            let
                cmd =
                    case recordTab of
                        DefaultRecordViewTab recordUrl ->
                            Nav.pushUrl session.key recordUrl

                        RelatedSourcesSearchTab searchUrl ->
                            case model.searchResults of
                                -- if there is already a response, then don't refresh it when we switch tabs
                                Response _ ->
                                    Nav.pushUrl session.key searchUrl

                                _ ->
                                    let
                                        searchRequest =
                                            Url.fromString searchUrl
                                                |> Maybe.map (\a -> recordSearchRequest a)
                                                |> Maybe.withDefault Cmd.none
                                    in
                                    Cmd.batch
                                        [ searchRequest
                                        , Nav.pushUrl session.key searchUrl
                                        ]
            in
            ( { model
                | currentTab = recordTab
              }
            , cmd
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
                    case sourceBody.creator of
                        Just c ->
                            case c.relatedTo of
                                Just n ->
                                    extractLabelFromLanguageMap English n.label ++ ": " ++ title

                                Nothing ->
                                    case c.name of
                                        Just nm ->
                                            extractLabelFromLanguageMap English nm ++ ": " ++ title

                                        Nothing ->
                                            title

                        Nothing ->
                            title
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
