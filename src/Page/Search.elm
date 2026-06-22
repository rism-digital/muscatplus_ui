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

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setAliasLabelMap, setDownloader, setKeyboard, setQueryBuilder, setRangeFacetValues, setResultsNotInCurrentMode, toKeyboard)
import Basics.Extra exposing (flip)
import Browser.Navigation as Nav
import Config as C
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Maybe.Extra as ME
import Page.Downloader as Downloader
import Page.Downloader.Model as Downloader
import Page.Downloader.Msg as DownloaderMsg
import Page.Keyboard as Keyboard exposing (buildNotationRequestQuery)
import Page.Keyboard.Model exposing (KeyboardQuery, toKeyboardQuery)
import Page.Query exposing (QueryArgs, defaultQueryArgs, resetPage, setFilters, setMode, setNextQuery, toMode, toNextQuery)
import Page.QueryBuilder as QueryBuilder
import Page.QueryBuilder.Msg as QueryBuilderMsg
import Page.RecordTypes.Probe exposing (ProbeStatus(..))
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..))
import Page.RecordTypes.SearchControl exposing (resultModeToSearchControlOption)
import Page.Request exposing (createProbeRequestWithDecoder, createRequestWithDecoder)
import Page.Route exposing (Route, routeToResultMode)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Animations exposing (PreviewAnimationStatus(..))
import Page.UI.Attributes exposing (sidebarWidth)
import Page.UI.Errors exposing (createErrorMessage)
import Page.UI.Layout as Layout
import Page.UpdateHelpers exposing (addNationalCollectionFilter, applyKeyboardUpdateWithProbe, applyKeywordInputWithProbe, applyPreviewResponse, buildSearchUrl, chooseResponse, createProbeUrl, extractSearchResponseData, probeSubmit, textQuerySuggestionSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedResultSorting, userChangedResultsPerPage, userChangedSelectFacetSort, userClickedClosePreviewWindow, userClickedFacetPanelToggle, userClickedResultForPreview, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedSingleChoiceFacetItem, userClickedToggleFacet, userEnteredTextInKeywordQueryBox, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userFocusedRangeFacet, userLostFocusOnRangeFacet, userPressedArrowKeysInSearchResultsList, userRemovedItemFromActiveFilters, userResetSingleChoiceFacet)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Response exposing (Response(..), ServerData(..))
import SearchPreferences exposing (SearchPreferences)
import SearchPreferences.SetPreferences exposing (SearchPreferenceVariant(..))
import Session exposing (Session)
import Set
import Set.Extra as SE
import Url exposing (Url)
import Utilities exposing (convertNodeIdToPath)
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
    , session : Session
    }


currentResultsPanelWidth : Session -> SearchPageModel SearchMsg -> Int
currentResultsPanelWidth session model =
    let
        windowWidth =
            session.window
                |> Tuple.first


    in
    case model.resultsPanelResize of
        Just resize ->
            Layout.clampResultsPanelWidth windowWidth sidebarWidth resize.currentResultsWidth

        Nothing ->
            let


                persistedWidth =
                    model.resultsPanelWidth
                        |> ME.orElse
                            (session.searchPreferences
                                |> Maybe.andThen .resultsPanelWidth
                            )
                        |> Maybe.withDefault (Layout.resultsPanelWidth windowWidth sidebarWidth)
            in
            Layout.clampResultsPanelWidth windowWidth sidebarWidth persistedWidth


convertFacetToResultMode : FacetItem -> ResultMode
convertFacetToResultMode (FacetItem qval _ _) =
    parseStringToResultMode qval


init : SearchConfig -> SearchPageModel SearchMsg
init cfg =
    let
        selectedResult =
            .fragment cfg.incomingUrl
                |> Maybe.map (\frg -> C.serverUrl ++ "/" ++ convertNodeIdToPath frg)

        searchInterface =
            routeToResultMode cfg.route
                |> resultModeToSearchControlOption
    in
    { response = Loading Nothing
    , activeSearch =
        ActiveSearch.init
            { queryArgs = cfg.queryArgs
            , keyboardQueryArgs = Just cfg.keyboardQueryArgs
            , session = cfg.session
            }
    , preview = NoResponseToShow
    , resultsPanelWidth = Nothing
    , resultsPanelResize = Nothing
    , pendingResultsScrollReset = False
    , sourceItemsExpanded = False
    , incipitInfoExpanded = Set.empty
    , selectedResult = selectedResult
    , showFacetPanel = False
    , probeResponse = NotChecked
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , applyFilterPrompt = False
    , digitizedCopiesCalloutExpanded = False
    , previewAnimationStatus = NoAnimation
    , showSearchControls = searchInterface
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
        , resultsPanelResize = Nothing
        , pendingResultsScrollReset = False
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

        newModel =
            { nationalCollectionSetModel
                | response = Loading (chooseResponse model.response)
                , preview = NoResponseToShow
            }

        searchUrl =
            buildSearchUrl
                (toNextQuery nationalCollectionSetModel.activeSearch)
                (toKeyboard pageResetModel.activeSearch)
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

                scrollResetCmd =
                    if model.pendingResultsScrollReset then
                        resetViewportOf ClientCompletedViewportReset "search-results-list"

                    else
                        Cmd.none

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

                activeFilters =
                    toNextQuery model.activeSearch
                        |> .filters

                ( aliasLabelMap, updatedFiltersWithCorrectLanguageMaps, totalItems ) =
                    case response of
                        SearchData body ->
                            let
                                searchData =
                                    extractSearchResponseData activeFilters body
                            in
                            ( searchData.aliasLabelMap
                            , searchData.updatedFilters
                            , searchData.probeStatus
                            )

                        _ ->
                            ( Dict.empty, activeFilters, NotChecked )

                resultsNotInCurrentMode =
                    case response of
                        SearchData body ->
                            if body.totalItems == 0 && ME.isJust body.modes then
                                Maybe.map .items body.modes
                                    |> Maybe.withDefault []

                            else
                                []

                        _ ->
                            []

                newNextQuery =
                    toNextQuery model.activeSearch
                        |> setFilters updatedFiltersWithCorrectLanguageMaps

                newActiveSearch =
                    model.activeSearch
                        |> setAliasLabelMap aliasLabelMap
                        |> setNextQuery newNextQuery
                        |> setResultsNotInCurrentMode resultsNotInCurrentMode
            in
            ( { model
                | response = Response response
                , activeSearch = newActiveSearch
                , pendingResultsScrollReset = False
                , probeResponse = totalItems
                , applyFilterPrompt = False
              }
            , Cmd.batch
                [ notationRenderCmd
                , scrollResetCmd
                , jumpCmd
                ]
            )

        ServerRespondedWithSearchData (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
                , pendingResultsScrollReset = False
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
                , probeResponse = ProbeSuccess response
                , applyFilterPrompt = True
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Err _) ->
            ( model, Cmd.none )

        ServerRespondedWithSearchPreview result ->
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

        ClientCompletedViewportReset ->
            ( model, Cmd.none )

        ClientCompletedViewportJump ->
            ( model, Cmd.none )

        ClientStartedAnimatingPreviewWindowClose ->
            ( { model
                | previewAnimationStatus = MovingOut
              }
            , Cmd.none
            )

        ClientFinishedAnimatingPreviewWindowShow ->
            ( { model
                | previewAnimationStatus = ShownAndNotMoving
              }
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
                resultMode =
                    convertFacetToResultMode item

                searchInterface =
                    resultModeToSearchControlOption resultMode

                newModel =
                    { model | showSearchControls = searchInterface }

                newQuery =
                    toNextQuery newModel.activeSearch
                        |> setMode resultMode
            in
            setNextQuery newQuery newModel.activeSearch
                |> flip setActiveSearch newModel
                |> searchSubmit session

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

        UserRemovedActiveFilter alias value ->
            userRemovedItemFromActiveFilters alias value model
                |> probeSubmit ServerRespondedWithProbeData session

        UserInteractedWithPianoKeyboard keyboardMsg ->
            applyKeyboardUpdateWithProbe
                { activeSearch = model.activeSearch
                , createProbeCmd =
                    \activeSearch ->
                        createProbeUrl session activeSearch
                            |> createProbeRequestWithDecoder ServerRespondedWithProbeData
                , keyboardMsg = keyboardMsg
                , mapKeyboardCmd = Cmd.map UserInteractedWithPianoKeyboard
                , maybeKeyboard = toKeyboard model.activeSearch
                , model = model
                , needsProbe = .needsProbe
                , setActiveSearch = setActiveSearch
                , setKeyboard = setKeyboard
                , updateKeyboard = Keyboard.update
                , updateModelForProbe = identity
                }

        UserInteractedWithQueryBuilder (QueryBuilderMsg.UserEnteredTextInQueryBuilder queryText) ->
            let
                -- This is the same code as when the user enters text in the
                -- non querybuilder box. The idea is that we update the "main"
                -- query, instead of tracking a specific querybuilder-only state.
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

        UserInteractedWithQueryBuilder QueryBuilderMsg.UserClickedSearchButton ->
            -- submit the search and close the query builder
            searchSubmit session { model | activeSearch = setQueryBuilder Nothing model.activeSearch }

        UserInteractedWithQueryBuilder queryBuilderMsg ->
            let
                -- all other interactions can go here
                ( _, qbCmd ) =
                    QueryBuilder.update queryBuilderMsg {}
            in
            ( model, Cmd.map UserInteractedWithQueryBuilder qbCmd )

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

                prefArgs =
                    Maybe.map .resultsPerPage session.searchPreferences
                        |> defaultQueryArgs

                adjustedQueryArgs =
                    { prefArgs | mode = currentMode }
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

        UserClickedSearchResultsPagination url ->
            ( { model
                | response = Loading (chooseResponse model.response)
                , preview = NoResponseToShow
                , pendingResultsScrollReset = True
              }
            , Nav.pushUrl session.key url
            )

        UserClickedSearchResultForPreview result ->
            userClickedResultForPreview result session model

        UserStartedSearchResultsResize clientX ->
            let
                widthAtStart =
                    currentResultsPanelWidth session model
            in
            ( { model
                | resultsPanelResize =
                    Just
                        { startClientX = clientX
                        , startResultsWidth = widthAtStart
                        , currentResultsWidth = widthAtStart
                        }
              }
            , Cmd.none
            )

        ClientMovedSearchResultsResize clientX ->
            case model.resultsPanelResize of
                Just resize ->
                    let
                        windowWidth =
                            session.window
                                |> Tuple.first

                        nextWidth =
                            resize.startResultsWidth
                                + (clientX - resize.startClientX)
                                |> Layout.clampResultsPanelWidth windowWidth sidebarWidth
                    in
                    ( { model
                        | resultsPanelResize =
                            Just
                                { resize
                                    | currentResultsWidth = nextWidth
                                }
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        ClientStoppedSearchResultsResize ->
            case model.resultsPanelResize of
                Just resize ->
                    ( { model
                        | resultsPanelWidth = Just resize.currentResultsWidth
                        , resultsPanelResize = Nothing
                      }
                    , PortSendSaveSearchPreference
                        { key = "resultsPanelWidth"
                        , value = IntPreference resize.currentResultsWidth
                        }
                        |> encodeMessageForPortSend
                        |> sendOutgoingMessageOnPort
                    )

                Nothing ->
                    ( model, Cmd.none )

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
