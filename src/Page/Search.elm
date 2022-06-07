module Page.Search exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setKeyboard, setRangeFacetValues, toKeyboard)
import Browser.Navigation as Nav
import Config as C
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Flip exposing (flip)
import Page.Keyboard as Keyboard
    exposing
        ( buildNotationRequestQuery
        )
import Page.Keyboard.Model exposing (KeyboardQuery, toKeyboardQuery)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs, buildQueryParameters, defaultQueryArgs, resetPage, setKeywordQuery, setMode, setNextQuery, setSort, toFilters, toMode, toNextQuery)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..))
import Page.Request exposing (createErrorMessage, createProbeRequestWithDecoder, createRequestWithDecoder)
import Page.Route exposing (Route)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UpdateHelpers exposing (addNationalCollectionFilter, createProbeUrl, probeSubmit, rangeStringParser, textQuerySuggestionSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedSelectFacetSort, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Request exposing (serverUrl)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Url exposing (Url)
import Utlities exposing (convertNodeIdToPath, convertPathToNodeId)
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
            ActiveSearch.init
                { queryArgs = cfg.queryArgs
                , keyboardQueryArgs = Just cfg.keyboardQueryArgs
                }
        , preview = previewResp
        , selectedResult = selectedResult
        , applyFilterPrompt = False
    }


searchPageRequest : Url -> Cmd SearchMsg
searchPageRequest requestUrl =
    createRequestWithDecoder ServerRespondedWithSearchData (Url.toString requestUrl)


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


searchSubmit : Session -> SearchPageModel SearchMsg -> ( SearchPageModel SearchMsg, Cmd SearchMsg )
searchSubmit session model =
    let
        resetPageInQueryArgs =
            toNextQuery model.activeSearch
                |> resetPage

        -- when submitting a new search, reset the page
        -- to the first page.
        pageResetModel =
            setNextQuery resetPageInQueryArgs model.activeSearch
                |> flip setActiveSearch model

        notationQueryParameters =
            case toKeyboard pageResetModel.activeSearch of
                Just kq ->
                    toKeyboardQuery kq
                        |> buildNotationQueryParameters

                Nothing ->
                    []

        nationalCollectionSetModel =
            addNationalCollectionFilter session.restrictedToNationalCollection pageResetModel

        textQueryParameters =
            toNextQuery nationalCollectionSetModel.activeSearch
                |> buildQueryParameters

        oldData =
            case model.response of
                Response d ->
                    Just d

                _ ->
                    Nothing

        newModel =
            { nationalCollectionSetModel
                | preview = NoResponseToShow
                , response = Loading oldData
            }

        searchUrl =
            serverUrl [ "search" ] (List.append textQueryParameters notationQueryParameters)
    in
    ( newModel
    , Nav.pushUrl session.key searchUrl
    )


convertFacetToResultMode : FacetItem -> ResultMode
convertFacetToResultMode facet =
    let
        (FacetItem qval _ _) =
            facet
    in
    parseStringToResultMode qval


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


update : Session -> SearchMsg -> SearchPageModel SearchMsg -> ( SearchPageModel SearchMsg, Cmd SearchMsg )
update session msg model =
    case msg of
        ServerRespondedWithSearchData (Ok ( _, response )) ->
            let
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

                jumpCmd =
                    case .fragment session.url of
                        Just frag ->
                            jumpToIdIfNotVisible NothingHappened "search-results-list" frag

                        Nothing ->
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
              }
            , Cmd.none
            )

        ServerRespondedWithSearchPreview (Err error) ->
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
            ( newModel
            , Cmd.none
            )

        ServerRespondedWithSuggestionData (Err error) ->
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

        UserClickedFacetPanelToggle ->
            ( model, Cmd.none )

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

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromQueryFacet alias query model
                |> probeSubmit ServerRespondedWithProbeData session

        UserEnteredTextInRangeFacet alias inputBox value ->
            ( userEnteredTextInRangeFacet alias inputBox value model
            , Cmd.none
            )

        UserFocusedRangeFacet alias ->
            let
                -- when the user focuses the range facet, we ensure that any query parameters are
                -- immediately transferred to the place where we keep range facet values so that we
                -- can edit them.
                nextQueryFilters =
                    toNextQuery model.activeSearch
                        |> toFilters

                maybeRangeValue =
                    case Dict.get alias nextQueryFilters of
                        Just (m :: []) ->
                            rangeStringParser m

                        _ ->
                            Nothing

                -- if we have an existing value here, prefer that. If not, choose the query value
                newRangeValues =
                    Dict.update alias
                        (\v ->
                            case v of
                                Just m ->
                                    Just m

                                Nothing ->
                                    maybeRangeValue
                        )
                        (.rangeFacetValues model.activeSearch)

                newActiveSearch =
                    setRangeFacetValues newRangeValues model.activeSearch
            in
            ( { model
                | activeSearch = newActiveSearch
              }
            , Cmd.none
            )

        UserLostFocusRangeFacet alias ->
            userLostFocusOnRangeFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

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

        UserChangedResultSorting sort ->
            let
                sortValue =
                    Just sort

                newQueryArgs =
                    toNextQuery model.activeSearch
                        |> setSort sortValue
            in
            setNextQuery newQueryArgs model.activeSearch
                |> flip setActiveSearch model
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
                | preview = NoResponseToShow
                , response = Loading oldData
              }
            , Cmd.batch
                [ Nav.pushUrl session.key url
                , resetViewportOf NothingHappened "search-results-list"
                ]
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
                , preview = Loading Nothing
              }
            , Nav.pushUrl session.key newUrlStr
            )

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

        NothingHappened ->
            ( model, Cmd.none )
