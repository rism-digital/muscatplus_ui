module Page.Record exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setRangeFacetValues)
import Browser.Navigation as Nav
import Config as C
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Flip exposing (flip)
import Page.Query exposing (defaultQueryArgs, setKeywordQuery, setNextQuery, toNextQuery)
import Page.Record.Model exposing (CurrentRecordViewTab(..), RecordPageModel)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Search exposing (searchSubmit)
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Page.Route exposing (Route(..))
import Page.UpdateHelpers exposing (probeSubmit, textQuerySuggestionSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedSelectFacetSort, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)
import Utlities exposing (convertNodeIdToPath, convertPathToNodeId)
import Viewport exposing (jumpToId, resetViewportOf)


type alias Model =
    RecordPageModel RecordMsg


type alias Msg =
    RecordMsg


init : Url -> Route -> RecordPageModel RecordMsg
init incomingUrl route =
    let
        selectedResult =
            incomingUrl.fragment
                |> Maybe.andThen (\f -> Just (C.serverUrl ++ "/" ++ convertNodeIdToPath f))

        tabView =
            case route of
                InstitutionSourcePageRoute _ _ ->
                    RelatedSourcesSearchTab <| Url.toString incomingUrl

                PersonSourcePageRoute _ _ ->
                    RelatedSourcesSearchTab <| Url.toString incomingUrl

                _ ->
                    DefaultRecordViewTab <| Url.toString incomingUrl
    in
    { response = Loading Nothing
    , currentTab = tabView
    , searchResults = NoResponseToShow
    , activeSearch = ActiveSearch.init route
    , preview = NoResponseToShow
    , selectedResult = selectedResult
    , applyFilterPrompt = False
    , probeResponse = NoResponseToShow
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    }


load : Url -> Route -> RecordPageModel RecordMsg -> RecordPageModel RecordMsg
load url route oldModel =
    let
        ( previewResp, selectedResult ) =
            case url.fragment of
                Just f ->
                    ( oldModel.preview, Just (C.serverUrl ++ "/" ++ convertNodeIdToPath f) )

                Nothing ->
                    ( NoResponseToShow, Nothing )

        tabView =
            case route of
                InstitutionSourcePageRoute _ _ ->
                    RelatedSourcesSearchTab <| Url.toString url

                PersonSourcePageRoute _ _ ->
                    RelatedSourcesSearchTab <| Url.toString url

                _ ->
                    DefaultRecordViewTab <| Url.toString url
    in
    { response = oldModel.response
    , activeSearch = oldModel.activeSearch
    , preview = previewResp
    , selectedResult = selectedResult
    , currentTab = tabView
    , searchResults = oldModel.searchResults
    , applyFilterPrompt = oldModel.applyFilterPrompt
    , probeResponse = oldModel.probeResponse
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    }


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


recordPagePreviewRequest : String -> Cmd RecordMsg
recordPagePreviewRequest previewUrl =
    createRequestWithDecoder ServerRespondedWithRecordPreview previewUrl


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


update : Session -> RecordMsg -> RecordPageModel RecordMsg -> ( RecordPageModel RecordMsg, Cmd RecordMsg )
update session msg model =
    case msg of
        ServerRespondedWithRecordData (Ok ( _, response )) ->
            ( { model
                | response = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithRecordData (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        ServerRespondedWithPageSearch (Ok ( _, response )) ->
            ( { model
                | searchResults = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithPageSearch (Err error) ->
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

        DebouncerCapturedProbeRequest recordMsg ->
            Debouncer.update (update session) updateDebouncerProbeConfig recordMsg model

        DebouncerSettledToSendProbeRequest ->
            probeSubmit ServerRespondedWithProbeData session model

        ServerRespondedWithProbeData (Ok ( _, response )) ->
            ( { model
                | probeResponse = Response response
                , applyFilterPrompt = True
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Err error) ->
            ( model, Cmd.none )

        ServerRespondedWithSuggestionData (Ok ( _, response )) ->
            let
                newModel =
                    setActiveSuggestion (Just response) model.activeSearch
                        |> flip setActiveSearch model
            in
            ( newModel, Cmd.none )

        ServerRespondedWithSuggestionData (Err error) ->
            ( model, Cmd.none )

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
                                                |> Maybe.andThen (\a -> Just <| recordSearchRequest a)
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
                | preview = NoResponseToShow
                , searchResults = Loading oldData
              }
            , Cmd.batch
                [ Nav.pushUrl session.key pageUrl
                , resetViewportOf NothingHappened "search-results-list"
                ]
            )

        UserClickedSearchResultForPreview result ->
            let
                resultUrl =
                    Url.fromString result

                resPath =
                    case resultUrl of
                        Just p ->
                            String.dropLeft 1 p.path
                                |> convertPathToNodeId
                                |> Just

                        Nothing ->
                            Nothing

                currentUrl =
                    session.url

                newUrl =
                    { currentUrl | fragment = resPath }

                newUrlStr =
                    Url.toString newUrl
            in
            ( { model
                | selectedResult = Just result
              }
            , Nav.pushUrl session.key newUrlStr
            )

        UserClickedClosePreviewWindow ->
            let
                currentUrl =
                    session.url

                newUrl =
                    { currentUrl | fragment = Nothing }

                newUrlStr =
                    Url.toString newUrl
            in
            ( { model
                | preview = NoResponseToShow
                , selectedResult = Nothing
              }
            , Nav.pushUrl session.key newUrlStr
            )

        UserTriggeredSearchSubmit ->
            searchSubmit session model

        UserEnteredTextInKeywordQueryBox queryText ->
            let
                newText =
                    if String.isEmpty queryText then
                        Nothing

                    else
                        Just queryText

                newQueryArgs =
                    toNextQuery model.activeSearch
                        |> setKeywordQuery newText

                newModel =
                    setNextQuery newQueryArgs model.activeSearch
                        |> flip setActiveSearch model

                debounceMsg =
                    provideInput DebouncerSettledToSendProbeRequest
                        |> DebouncerCapturedProbeRequest
            in
            update session debounceMsg newModel

        UserClickedToggleFacet alias ->
            userClickedToggleFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        UserLostFocusRangeFacet alias ->
            userLostFocusOnRangeFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        UserFocusedRangeFacet alias ->
            ( model, Cmd.none )

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

                newModel =
                    userEnteredTextInQueryFacet alias query model
            in
            update session debounceMsg newModel

        DebouncerCapturedQueryFacetSuggestionRequest suggestMsg ->
            Debouncer.update (update session) updateDebouncerSuggestConfig suggestMsg model

        DebouncerSettledToSendQueryFacetSuggestionRequest suggestionUrl ->
            ( model
            , textQuerySuggestionSubmit suggestionUrl ServerRespondedWithSuggestionData
            )

        UserChoseOptionForQueryFacet alias selectedValue currentBehaviour ->
            updateQueryFacetFilters alias selectedValue currentBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

        UserResetAllFilters ->
            setNextQuery defaultQueryArgs model.activeSearch
                |> setRangeFacetValues Dict.empty
                |> flip setActiveSearch model
                |> searchSubmit session

        NothingHappened ->
            ( model, Cmd.none )
