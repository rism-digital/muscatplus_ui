module Page.Search exposing
    ( Model
    , Msg
    , SearchConfig
    , init
    , load
    , requestPreviewIfSelected
    , searchPageRequest
    , update
    )

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setKeyboard, setRangeFacetValues, toKeyboard)
import Browser.Navigation as Nav
import Config as C
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Flip exposing (flip)
import Page.Keyboard as Keyboard exposing (buildNotationRequestQuery)
import Page.Keyboard.Model exposing (KeyboardQuery, toKeyboardQuery)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs, buildQueryParameters, defaultQueryArgs, resetPage, setMode, setNextQuery, toMode, toNextQuery)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..))
import Page.Request exposing (createErrorMessage, createProbeRequestWithDecoder, createRequestWithDecoder)
import Page.Route exposing (Route)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UpdateHelpers exposing (addNationalCollectionFilter, createProbeUrl, probeSubmit, textQuerySuggestionSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedResultSorting, userChangedResultsPerPage, userChangedSelectFacetSort, userClickedClosePreviewWindow, userClickedFacetPanelToggle, userClickedResultForPreview, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInKeywordQueryBox, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userFocusedRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Request exposing (serverUrl)
import Response exposing (Response(..), ServerData(..))
import SearchPreferences.SetPreferences exposing (SearchPreferenceVariant(..))
import Session exposing (Session)
import Set
import Url exposing (Url)
import Utlities exposing (convertNodeIdToPath)
import Viewport exposing (jumpToIdIfNotVisible, resetViewportOf)


type alias Model =
    SearchPageModel SearchMsg


type alias Msg =
    SearchMsg


type alias SearchConfig =
    { incomingUrl : Url
    , route : Route
    , queryArgs : QueryArgs
    , keyboardQueryArgs : KeyboardQuery
    }


convertFacetToResultMode : FacetItem -> ResultMode
convertFacetToResultMode facet =
    let
        (FacetItem qval _ _) =
            facet
    in
    parseStringToResultMode qval


init : SearchConfig -> SearchPageModel SearchMsg
init cfg =
    let
        selectedResult =
            case .fragment cfg.incomingUrl of
                Just frg ->
                    Just (C.serverUrl ++ "/" ++ convertNodeIdToPath frg)

                Nothing ->
                    Nothing
    in
    { response = Loading Nothing
    , activeSearch =
        ActiveSearch.init
            { queryArgs = cfg.queryArgs
            , keyboardQueryArgs = Just cfg.keyboardQueryArgs
            }
    , preview = NoResponseToShow
    , sourceItemsExpanded = False
    , selectedResult = selectedResult
    , showFacetPanel = False
    , probeResponse = NoResponseToShow
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , applyFilterPrompt = False
    }


load : SearchConfig -> SearchPageModel SearchMsg -> SearchPageModel SearchMsg
load cfg oldModel =
    let
        ( previewResp, selectedResult ) =
            case .fragment cfg.incomingUrl of
                Just f ->
                    ( oldModel.preview, Just (C.serverUrl ++ "/" ++ convertNodeIdToPath f) )

                Nothing ->
                    ( NoResponseToShow, Nothing )
    in
    { oldModel
        | activeSearch =
            ActiveSearch.load oldModel.activeSearch

        --{ queryArgs = cfg.queryArgs
        --, keyboardQueryArgs = Just cfg.keyboardQueryArgs
        --}
        , preview = previewResp
        , selectedResult = selectedResult
        , applyFilterPrompt = False
    }


requestPreviewIfSelected : Maybe String -> Cmd SearchMsg
requestPreviewIfSelected selected =
    case selected of
        Just s ->
            searchPagePreviewRequest s

        Nothing ->
            Cmd.none


searchPagePreviewRequest : String -> Cmd SearchMsg
searchPagePreviewRequest previewUrl =
    createRequestWithDecoder ServerRespondedWithSearchPreview previewUrl


searchPageRequest : Url -> Cmd SearchMsg
searchPageRequest requestUrl =
    createRequestWithDecoder ServerRespondedWithSearchData (Url.toString requestUrl)


searchSubmit : Session -> SearchPageModel SearchMsg -> ( SearchPageModel SearchMsg, Cmd SearchMsg )
searchSubmit session model =
    let
        nationalCollectionSetModel =
            addNationalCollectionFilter session.restrictedToNationalCollection pageResetModel

        -- when submitting a new search, reset the page
        -- to the first page.
        resetPageInQueryArgs =
            toNextQuery model.activeSearch
                |> resetPage

        pageResetModel =
            setNextQuery resetPageInQueryArgs model.activeSearch
                |> flip setActiveSearch model

        oldData =
            case model.response of
                Response d ->
                    Just d

                _ ->
                    Nothing

        newModel =
            { nationalCollectionSetModel
                | response = Loading oldData
                , preview = NoResponseToShow
            }

        notationQueryParameters =
            case toKeyboard pageResetModel.activeSearch of
                Just kq ->
                    toKeyboardQuery kq
                        |> buildNotationQueryParameters

                Nothing ->
                    []

        textQueryParameters =
            toNextQuery nationalCollectionSetModel.activeSearch
                |> buildQueryParameters

        searchUrl =
            serverUrl [ "search" ] (List.append textQueryParameters notationQueryParameters)
    in
    ( newModel
    , Nav.pushUrl session.key searchUrl
    )


update : Session -> SearchMsg -> SearchPageModel SearchMsg -> ( SearchPageModel SearchMsg, Cmd SearchMsg )
update session msg model =
    case msg of
        ServerRespondedWithSearchData (Ok ( _, response )) ->
            let
                jumpCmd =
                    case .fragment session.url of
                        Just frag ->
                            jumpToIdIfNotVisible ClientCompletedViewportJump "search-results-list" frag

                        Nothing ->
                            Cmd.none

                currentMode =
                    toNextQuery model.activeSearch
                        |> toMode

                notationRenderCmd =
                    case currentMode of
                        IncipitsMode ->
                            case toKeyboard model.activeSearch of
                                Just kq ->
                                    toKeyboardQuery kq
                                        |> buildNotationRequestQuery
                                        |> Cmd.map UserInteractedWithPianoKeyboard

                                Nothing ->
                                    Cmd.none

                        _ ->
                            Cmd.none

                totalItems =
                    case response of
                        SearchData body ->
                            Response { totalItems = body.totalItems, modes = body.modes }

                        _ ->
                            NoResponseToShow
            in
            ( { model
                | response = Response response
                , probeResponse = totalItems
                , applyFilterPrompt = False
              }
            , Cmd.batch
                [ notationRenderCmd
                , jumpCmd
                ]
            )

        ServerRespondedWithSearchData (Err error) ->
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

        ServerRespondedWithSearchPreview (Ok ( _, response )) ->
            ( { model
                | preview = Response response
                , sourceItemsExpanded = False
              }
            , Cmd.none
            )

        ServerRespondedWithSearchPreview (Err error) ->
            ( { model
                | preview = Error (createErrorMessage error)
                , sourceItemsExpanded = False
              }
            , Cmd.none
            )

        ServerRespondedWithSuggestionData (Ok ( _, response )) ->
            ( setActiveSuggestion (Just response) model.activeSearch
                |> flip setActiveSearch model
            , Cmd.none
            )

        ServerRespondedWithSuggestionData (Err _) ->
            ( model, Cmd.none )

        DebouncerCapturedProbeRequest searchMsg ->
            Debouncer.update (update session) updateDebouncerProbeConfig searchMsg model

        DebouncerSettledToSendProbeRequest ->
            probeSubmit ServerRespondedWithProbeData session model

        UserChangedFacetBehaviour alias facetBehaviour ->
            userChangedFacetBehaviour alias facetBehaviour model
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

        UserClickedToggleFacet alias ->
            userClickedToggleFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        UserClickedFacetPanelToggle panelAlias expandedPanels ->
            userClickedFacetPanelToggle panelAlias expandedPanels model

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

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromQueryFacet alias query model
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

        UserChangedResultSorting sort ->
            userChangedResultSorting sort model
                |> searchSubmit session

        UserChangedResultsPerPage num ->
            userChangedResultsPerPage num model
                |> searchSubmit session

        UserClickedModeItem item ->
            let
                newMode =
                    convertFacetToResultMode item

                newQuery =
                    toNextQuery model.activeSearch
                        |> setMode newMode
            in
            setNextQuery newQuery model.activeSearch
                |> flip setActiveSearch model
                |> searchSubmit session

        UserClickedSearchResultsPagination url ->
            let
                oldData =
                    case model.response of
                        Response d ->
                            Just d

                        _ ->
                            Nothing
            in
            ( { model
                | response = Loading oldData
                , preview = NoResponseToShow
              }
            , Cmd.batch
                [ Nav.pushUrl session.key url
                , resetViewportOf ClientCompletedViewportReset "search-results-list"
                ]
            )

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

        UserClickedClosePreviewWindow ->
            userClickedClosePreviewWindow session model

        UserClickedExpandSourceItemsSectionInPreview ->
            ( { model
                | sourceItemsExpanded = not model.sourceItemsExpanded
              }
            , Cmd.none
            )

        UserClickedSearchResultForPreview result ->
            userClickedResultForPreview result session model

        UserInteractedWithPianoKeyboard keyboardMsg ->
            case toKeyboard model.activeSearch of
                Just kq ->
                    let
                        ( keyboardModel, keyboardCmd ) =
                            Keyboard.update keyboardMsg kq

                        newModel =
                            setKeyboard (Just keyboardModel) model.activeSearch
                                |> flip setActiveSearch model

                        probeCmd =
                            if keyboardModel.needsProbe then
                                let
                                    probeUrl =
                                        createProbeUrl session newModel.activeSearch
                                in
                                createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl

                            else
                                Cmd.none
                    in
                    ( newModel
                    , Cmd.batch
                        [ Cmd.map UserInteractedWithPianoKeyboard keyboardCmd
                        , probeCmd
                        ]
                    )

                Nothing ->
                    ( model, Cmd.none )

        UserResetAllFilters ->
            let
                -- we don't reset *all* parameters; we keep the
                -- currently selected result mode so that the user
                -- doesn't get bounced back to the 'sources' tab.
                currentMode =
                    toNextQuery model.activeSearch
                        |> toMode

                adjustedQueryArgs =
                    { defaultQueryArgs | mode = currentMode }
            in
            setNextQuery adjustedQueryArgs model.activeSearch
                |> setRangeFacetValues Dict.empty
                |> setKeyboard (Just Keyboard.initModel)
                |> flip setActiveSearch model
                |> searchSubmit session

        ClientCompletedViewportReset ->
            ( model, Cmd.none )

        ClientCompletedViewportJump ->
            ( model, Cmd.none )

        NothingHappened ->
            ( model, Cmd.none )


updateDebouncerProbeConfig : Debouncer.UpdateConfig SearchMsg (SearchPageModel SearchMsg)
updateDebouncerProbeConfig =
    { mapMsg = DebouncerCapturedProbeRequest
    , getDebouncer = .probeDebouncer
    , setDebouncer = \debouncer model -> { model | probeDebouncer = debouncer }
    }


updateDebouncerSuggestConfig : Debouncer.UpdateConfig SearchMsg (SearchPageModel SearchMsg)
updateDebouncerSuggestConfig =
    { mapMsg = DebouncerCapturedQueryFacetSuggestionRequest
    , getDebouncer = \model -> .activeSuggestionDebouncer model.activeSearch
    , setDebouncer =
        \debouncer model ->
            model.activeSearch
                |> setActiveSuggestionDebouncer debouncer
                |> flip setActiveSearch model
    }
