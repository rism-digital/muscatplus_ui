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

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setAliasLabelMap, setKeyboard, setRangeFacetValues, toKeyboard)
import Basics.Extra exposing (flip)
import Browser.Navigation as Nav
import Config as C
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Maybe.Extra as ME
import Page.Keyboard as Keyboard exposing (buildNotationRequestQuery)
import Page.Keyboard.Model exposing (KeyboardQuery, toKeyboardQuery)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs, buildQueryParameters, defaultQueryArgs, resetPage, setFilters, setMode, setNextQuery, toMode, toNextQuery)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..), toFacetLabel)
import Page.Request exposing (createProbeRequestWithDecoder, createRequestWithDecoder)
import Page.Route exposing (Route)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Animations exposing (PreviewAnimationStatus(..))
import Page.UpdateHelpers exposing (addNationalCollectionFilter, chooseResponse, createProbeUrl, probeSubmit, textQuerySuggestionSubmit, updateActiveFiltersWithLangMapResultsFromServer, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedResultSorting, userChangedResultsPerPage, userChangedSelectFacetSort, userClickedClosePreviewWindow, userClickedFacetPanelToggle, userClickedResultForPreview, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInKeywordQueryBox, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userFocusedRangeFacet, userLostFocusOnRangeFacet, userPressedArrowKeysInSearchResultsList, userRemovedItemFromActiveFilters)
import Request exposing (serverUrl)
import Response exposing (Response(..), ServerData(..))
import SearchPreferences exposing (SearchPreferences)
import Session exposing (Session)
import Set
import Url exposing (Url)
import Utilities exposing (convertNodeIdToPath, toggle)
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
    , searchPreferences : Maybe SearchPreferences
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
            .fragment cfg.incomingUrl
                |> Maybe.map (\frg -> C.serverUrl ++ "/" ++ convertNodeIdToPath frg)
    in
    { response = Loading Nothing
    , activeSearch =
        ActiveSearch.init
            { queryArgs = cfg.queryArgs
            , keyboardQueryArgs = Just cfg.keyboardQueryArgs
            , searchPreferences = cfg.searchPreferences
            }
    , preview = NoResponseToShow
    , sourceItemsExpanded = False
    , incipitInfoExpanded = Set.empty
    , selectedResult = selectedResult
    , showFacetPanel = False
    , probeResponse = NoResponseToShow
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , applyFilterPrompt = False
    , digitizedCopiesCalloutExpanded = False
    , previewAnimationStatus = NoAnimation
    }


load : SearchConfig -> SearchPageModel SearchMsg -> SearchPageModel SearchMsg
load cfg oldModel =
    let
        newActiveSearch =
            ActiveSearch.load oldModel.activeSearch
                |> setNextQuery cfg.queryArgs

        ( previewResp, selectedResult ) =
            .fragment cfg.incomingUrl
                |> ME.unwrap ( NoResponseToShow, Nothing ) (\f -> ( oldModel.preview, Just (C.serverUrl ++ "/" ++ convertNodeIdToPath f) ))

        newKeyboard =
            Maybe.map (Keyboard.load cfg.keyboardQueryArgs) newActiveSearch.keyboard

        newActiveSearchWithKeyboard =
            setKeyboard newKeyboard newActiveSearch
    in
    { oldModel
        | activeSearch = newActiveSearchWithKeyboard
        , preview = previewResp
        , selectedResult = selectedResult
        , applyFilterPrompt = False
    }


requestPreviewIfSelected : Maybe String -> Cmd SearchMsg
requestPreviewIfSelected selected =
    Maybe.map searchPagePreviewRequest selected
        |> Maybe.withDefault Cmd.none


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
            chooseResponse model.response

        newModel =
            { nationalCollectionSetModel
                | response = Loading oldData
                , preview = NoResponseToShow
            }

        notationQueryParameters =
            toKeyboard pageResetModel.activeSearch
                |> ME.unwrap []
                    (\kq ->
                        toKeyboardQuery kq
                            |> buildNotationQueryParameters
                    )

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
                    .fragment session.url
                        |> ME.unwrap Cmd.none (jumpToIdIfNotVisible ClientCompletedViewportJump "search-results-list")

                currentMode =
                    toNextQuery model.activeSearch
                        |> toMode

                notationRenderCmd =
                    case currentMode of
                        IncipitsMode ->
                            toKeyboard model.activeSearch
                                |> ME.unwrap Cmd.none
                                    (\kq ->
                                        toKeyboardQuery kq
                                            |> buildNotationRequestQuery
                                            |> Cmd.map UserInteractedWithPianoKeyboard
                                    )

                        _ ->
                            Cmd.none

                aliasLabelMap =
                    case response of
                        SearchData body ->
                            Dict.map (\_ v -> toFacetLabel v) body.facets

                        _ ->
                            Dict.empty

                activeFilters =
                    toNextQuery model.activeSearch
                        |> .filters

                updatedFiltersWithCorrectLanguageMaps =
                    case response of
                        SearchData body ->
                            updateActiveFiltersWithLangMapResultsFromServer activeFilters body.facets

                        _ ->
                            activeFilters

                newNextQuery =
                    toNextQuery model.activeSearch
                        |> setFilters updatedFiltersWithCorrectLanguageMaps

                newActiveSearch =
                    model.activeSearch
                        |> setAliasLabelMap aliasLabelMap
                        |> setNextQuery newNextQuery

                totalItems =
                    case response of
                        SearchData body ->
                            Response
                                { totalItems = body.totalItems
                                , modes = body.modes
                                }

                        _ ->
                            NoResponseToShow
            in
            ( { model
                | response = Response response
                , activeSearch = newActiveSearch
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
                | response = Error error
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Ok ( _, response )) ->
            let
                newActiveSearch =
                    .keyboard model.activeSearch
                        |> Maybe.map (\km -> { km | needsProbe = False })
                        |> flip setKeyboard model.activeSearch
            in
            ( { model
                | activeSearch = newActiveSearch
                , probeResponse = Response response
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
                | preview = Error error
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

        ClientCompletedViewportReset ->
            ( model, Cmd.none )

        ClientCompletedViewportJump ->
            ( model, Cmd.none )

        ClientStartedAnimatingPreviewWindowClose ->
            ( { model | previewAnimationStatus = MovingOut }
            , Cmd.none
            )

        ClientFinishedAnimatingPreviewWindowShow ->
            ( { model | previewAnimationStatus = ShownAndNotMoving }
            , Cmd.none
            )

        DebouncerCapturedProbeRequest searchMsg ->
            Debouncer.update (update session) updateDebouncerProbeConfig searchMsg model

        DebouncerSettledToSendProbeRequest ->
            probeSubmit ServerRespondedWithProbeData session model

        DebouncerCapturedQueryFacetSuggestionRequest suggestMsg ->
            Debouncer.update (update session) updateDebouncerSuggestConfig suggestMsg model

        DebouncerSettledToSendQueryFacetSuggestionRequest suggestionUrl ->
            ( model
            , textQuerySuggestionSubmit suggestionUrl ServerRespondedWithSuggestionData
            )

        UserClickedModeItem item ->
            let
                newQuery =
                    toNextQuery model.activeSearch
                        |> setMode (convertFacetToResultMode item)
            in
            setNextQuery newQuery model.activeSearch
                |> flip setActiveSearch model
                |> searchSubmit session

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

        UserRemovedActiveFilter alias value ->
            userRemovedItemFromActiveFilters alias value model
                |> probeSubmit ServerRespondedWithProbeData session

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
                                createProbeUrl session newModel.activeSearch
                                    |> createProbeRequestWithDecoder ServerRespondedWithProbeData

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

        UserTriggeredSearchSubmit ->
            searchSubmit session model

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

        UserChangedResultSorting sort ->
            userChangedResultSorting sort model
                |> searchSubmit session

        UserChangedResultsPerPage num ->
            userChangedResultsPerPage num model
                |> searchSubmit session

        UserClickedSearchResultsPagination url ->
            let
                oldData =
                    chooseResponse model.response
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

        UserClickedSearchResultForPreview result ->
            userClickedResultForPreview result session model

        UserClickedExpandSourceItemsSectionInPreview ->
            ( { model
                | sourceItemsExpanded = not model.sourceItemsExpanded
              }
            , Cmd.none
            )

        UserClickedExpandIncipitInfoSectionInPreview incipitIdent ->
            let
                newExpandedSet =
                    toggle incipitIdent model.incipitInfoExpanded
            in
            ( { model
                | incipitInfoExpanded = newExpandedSet
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

        UserPressedAnArrowKey arrowDirection ->
            userPressedArrowKeysInSearchResultsList arrowDirection session model

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
