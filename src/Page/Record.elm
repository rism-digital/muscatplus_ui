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
import Page.Query exposing (QueryArgs, defaultQueryArgs, setKeywordQuery, setNationalCollection, setNextQuery, setRows, setSort, toNextQuery)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel, routeToCurrentRecordViewTab)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Search exposing (searchSubmit)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Page.Route exposing (Route)
import Page.UpdateHelpers exposing (probeSubmit, textQuerySuggestionSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedResultSorting, userChangedResultsPerPage, userChangedSelectFacetSort, userClickedClosePreviewWindow, userClickedResultForPreview, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInKeywordQueryBox, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userFocusedRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Url exposing (Url)
import Utlities exposing (convertNodeIdToPath)
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
    }


init : RecordConfig -> RecordPageModel RecordMsg
init cfg =
    let
        activeSearch =
            toNextQuery activeSearchInit
                |> setNationalCollection cfg.nationalCollection
                |> flip setNextQuery activeSearchInit

        activeSearchInit =
            case cfg.queryArgs of
                Just qa ->
                    ActiveSearch.init
                        { queryArgs = qa
                        , keyboardQueryArgs = Nothing
                        }

                Nothing ->
                    ActiveSearch.empty

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
            case cfg.queryArgs of
                Just q ->
                    ActiveSearch.init
                        { queryArgs = q
                        , keyboardQueryArgs = Nothing
                        }

                Nothing ->
                    ActiveSearch.empty

        activeSearch =
            toNextQuery activeSearchInit
                |> setNationalCollection cfg.nationalCollection
                |> flip setNextQuery activeSearchInit

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
                                Response { totalItems = body.totalItems, modes = body.modes }

                        _ ->
                            NoResponseToShow

                searchResults =
                    case response of
                        SearchData body ->
                            if body.totalItems == 0 then
                                NoResponseToShow

                            else
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
                | response = Error (createErrorMessage error)
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
                            Loading Nothing

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

        ServerRespondedWithRecordPreview (Ok ( _, response )) ->
            ( { model
                | preview = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithRecordPreview (Err error) ->
            ( { model
                | preview = Error (createErrorMessage error)
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

        DebouncerCapturedProbeRequest recordMsg ->
            Debouncer.update (update session) updateDebouncerProbeConfig recordMsg model

        DebouncerSettledToSendProbeRequest ->
            probeSubmit ServerRespondedWithProbeData session model

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

        UserClickedClosePreviewWindow ->
            userClickedClosePreviewWindow session model

        UserTriggeredSearchSubmit ->
            searchSubmit session model

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

        UserLostFocusRangeFacet alias ->
            userLostFocusOnRangeFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        UserFocusedRangeFacet alias ->
            userFocusedRangeFacet alias model

        UserEnteredTextInRangeFacet alias inputBox value ->
            ( userEnteredTextInRangeFacet alias inputBox value model
            , Cmd.none
            )

        UserClickedSelectFacetExpand alias ->
            ( userClickedSelectFacetExpand alias model
            , Cmd.none
            )

        UserChangedFacetBehaviour alias facetBehaviour ->
            userChangedFacetBehaviour alias facetBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

        UserChangedSelectFacetSort alias facetSort ->
            ( userChangedSelectFacetSort alias facetSort model
            , Cmd.none
            )

        UserClickedSelectFacetItem alias facetValue ->
            userClickedSelectFacetItem alias facetValue model
                |> probeSubmit ServerRespondedWithProbeData session

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromQueryFacet alias query model
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

        DebouncerCapturedQueryFacetSuggestionRequest suggestMsg ->
            Debouncer.update (update session) updateDebouncerSuggestConfig suggestMsg model

        DebouncerSettledToSendQueryFacetSuggestionRequest suggestionUrl ->
            ( model
            , textQuerySuggestionSubmit suggestionUrl ServerRespondedWithSuggestionData
            )

        UserChoseOptionForQueryFacet alias selectedValue currentBehaviour ->
            updateQueryFacetFilters alias selectedValue currentBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

        UserChangedResultSorting sort ->
            userChangedResultSorting sort model
                |> searchSubmit session

        UserChangedResultsPerPage num ->
            userChangedResultsPerPage num model
                |> searchSubmit session

        UserResetAllFilters ->
            setNextQuery defaultQueryArgs model.activeSearch
                |> setRangeFacetValues Dict.empty
                |> flip setActiveSearch model
                |> searchSubmit session

        ClientCompletedViewportJump ->
            ( model, Cmd.none )

        ClientCompletedViewportReset ->
            ( model, Cmd.none )

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


updatePageMetadata : ServerData -> Cmd RecordMsg
updatePageMetadata incomingData =
    case incomingData of
        SourceData sourceBody ->
            let
                fullDescription =
                    case sourceBody.creator of
                        Just c ->
                            case c.relatedTo of
                                Just n ->
                                    extractLabelFromLanguageMap None n.label ++ ": " ++ title

                                Nothing ->
                                    case c.name of
                                        Just nm ->
                                            extractLabelFromLanguageMap None nm ++ ": " ++ title

                                        Nothing ->
                                            title

                        Nothing ->
                            title

                title =
                    extractLabelFromLanguageMap None sourceBody.label
            in
            PortSendHeaderMetaInfo { description = fullDescription }
                |> encodeMessageForPortSend
                |> sendOutgoingMessageOnPort

        PersonData personBody ->
            PortSendHeaderMetaInfo { description = extractLabelFromLanguageMap None personBody.label }
                |> encodeMessageForPortSend
                |> sendOutgoingMessageOnPort

        InstitutionData instBody ->
            PortSendHeaderMetaInfo { description = extractLabelFromLanguageMap None instBody.label }
                |> encodeMessageForPortSend
                |> sendOutgoingMessageOnPort

        _ ->
            Cmd.none
