module Page.Search exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setExpandedFacets, setKeyboard, setRangeFacetValues, toActiveSearch, toExpandedFacets, toKeyboard, toggleExpandedFacets)
import Browser.Navigation as Nav
import Dict exposing (Dict)
import List.Extra as LE
import Page.Query exposing (buildQueryParameters, defaultQueryArgs, resetPage, setFacetSorts, setFilters, setKeywordQuery, setMode, setNextQuery, setSort, toFacetSorts, toFilters, toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetData(..), FacetItem(..), FacetSorts(..), RangeFacetValue(..))
import Page.Request exposing (createErrorMessage, createProbeRequestWithDecoder, createRequestWithDecoder)
import Page.Route exposing (Route)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.Search.UpdateHelpers exposing (addNationalCollectionFilter, createProbeUrl, probeSubmit, updateQueryFacetFilters, updateQueryFacetValues, userChangedFacetBehaviour, userChangedSelectFacetSort, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Page.UI.Keyboard as Keyboard exposing (buildNotationRequestQuery, setNotation, toNotation)
import Page.UI.Keyboard.Model exposing (toKeyboardQuery)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Request exposing (serverUrl)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Url exposing (Url)
import Utlities exposing (flip)


type alias Model =
    SearchPageModel


type alias Msg =
    SearchMsg


init : Route -> SearchPageModel
init route =
    { response = Loading Nothing
    , activeSearch = ActiveSearch.init route
    , preview = NoResponseToShow
    , selectedResult = Nothing
    , showFacetPanel = False
    , probeResponse = NoResponseToShow
    , applyFilterPrompt = False
    }


load : SearchPageModel -> SearchPageModel
load oldModel =
    let
        oldData =
            case oldModel.response of
                Response serverData ->
                    Just serverData

                _ ->
                    Nothing

        oldKeyboard =
            toActiveSearch oldModel
                |> toKeyboard

        oldRenderedNotation =
            oldKeyboard
                |> toNotation

        newKeyboard =
            oldKeyboard
                |> setNotation oldRenderedNotation

        newActiveSearch =
            toActiveSearch oldModel
                |> setKeyboard newKeyboard
    in
    { response = Loading oldData
    , activeSearch = newActiveSearch
    , preview = NoResponseToShow
    , selectedResult = Nothing
    , showFacetPanel = oldModel.showFacetPanel
    , probeResponse = NoResponseToShow
    , applyFilterPrompt = False
    }


searchPageRequest : Url -> Cmd SearchMsg
searchPageRequest requestUrl =
    createRequestWithDecoder ServerRespondedWithSearchData (Url.toString requestUrl)


searchPagePreviewRequest : String -> Cmd SearchMsg
searchPagePreviewRequest previewUrl =
    createRequestWithDecoder ServerRespondedWithSearchPreview previewUrl


searchSubmit : Session -> SearchPageModel -> ( SearchPageModel, Cmd SearchMsg )
searchSubmit session model =
    let
        activeSearch =
            toActiveSearch model

        resetPageInQueryArgs =
            activeSearch
                |> toNextQuery
                |> resetPage

        -- when submitting a new search, reset the page
        -- to the first page.
        pageResetModel =
            activeSearch
                |> setNextQuery resetPageInQueryArgs
                |> flip setActiveSearch model

        notationQueryParameters =
            toActiveSearch pageResetModel
                |> toKeyboard
                |> toKeyboardQuery
                |> buildNotationQueryParameters

        nationalCollectionSetModel =
            addNationalCollectionFilter session.restrictedToNationalCollection pageResetModel

        textQueryParameters =
            toActiveSearch nationalCollectionSetModel
                |> toNextQuery
                |> buildQueryParameters

        newModel =
            { nationalCollectionSetModel
                | preview = NoResponseToShow
            }

        searchUrl =
            serverUrl [ "search" ] (List.append textQueryParameters notationQueryParameters)
    in
    ( newModel
    , Cmd.batch
        [ Nav.pushUrl session.key searchUrl
        ]
    )


convertFacetToResultMode : FacetItem -> ResultMode
convertFacetToResultMode facet =
    let
        (FacetItem qval _ _) =
            facet
    in
    parseStringToResultMode qval


update : Session -> SearchMsg -> SearchPageModel -> ( SearchPageModel, Cmd SearchMsg )
update session msg model =
    case msg of
        ServerRespondedWithSearchData (Ok ( _, response )) ->
            let
                currentMode =
                    toNextQuery model.activeSearch
                        |> toMode

                keyboardQuery =
                    toKeyboard model.activeSearch
                        |> toKeyboardQuery

                notationRenderCmd =
                    case currentMode of
                        IncipitsMode ->
                            Cmd.map UserInteractedWithPianoKeyboard (buildNotationRequestQuery keyboardQuery)

                        _ ->
                            Cmd.none

                totalItems =
                    case response of
                        SearchData body ->
                            Response { totalItems = body.totalItems }

                        _ ->
                            NoResponseToShow
            in
            ( { model
                | response = Response response
                , probeResponse = totalItems
                , applyFilterPrompt = False
              }
            , notationRenderCmd
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

        ClientJumpedToId ->
            ( model, Cmd.none )

        ClientResetViewport ->
            ( model, Cmd.none )

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
            userEnteredTextInQueryFacet alias query suggestionUrl ServerRespondedWithSuggestionData model

        UserChoseOptionFromQueryFacetSuggest alias selectedValue currentBehaviour ->
            updateQueryFacetFilters alias selectedValue model
                |> updateQueryFacetValues alias currentBehaviour
                |> probeSubmit ServerRespondedWithProbeData session

        UserHitEnterInQueryFacet alias currentBehaviour ->
            updateQueryFacetValues alias currentBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromQueryFacet alias query model
                |> probeSubmit ServerRespondedWithProbeData session

        UserEnteredTextInRangeFacet alias inputBox value ->
            ( userEnteredTextInRangeFacet alias inputBox value model
            , Cmd.none
            )

        UserFocusedRangeFacet alias valueType ->
            ( model, Cmd.none )

        UserLostFocusRangeFacet alias valueType ->
            userLostFocusOnRangeFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        UserClickedSelectFacetExpand alias ->
            ( userClickedSelectFacetExpand alias model
            , Cmd.none
            )

        UserClickedSelectFacetItem alias facetValue isClicked ->
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

        UserClickedModeItem alias item isClicked ->
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

        UserClickedRemoveActiveFilter alias value ->
            ( model, Cmd.none )

        UserClickedClearSearchQueryBox ->
            let
                newQuery =
                    toNextQuery model.activeSearch
                        |> setKeywordQuery Nothing
            in
            setNextQuery newQuery model.activeSearch
                |> flip setActiveSearch model
                |> searchSubmit session

        UserClickedSearchResultsPagination url ->
            ( model
            , Cmd.batch
                [ Nav.pushUrl session.key url
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
            in
            setNextQuery newQueryArgs model.activeSearch
                |> flip setActiveSearch model
                |> probeSubmit ServerRespondedWithProbeData session

        UserClickedClosePreviewWindow ->
            ( { model
                | preview = NoResponseToShow
                , selectedResult = Nothing
              }
            , Cmd.none
            )

        UserClickedSearchResultForPreview result ->
            ( { model
                | selectedResult = Just result
              }
            , searchPagePreviewRequest result
            )

        UserInteractedWithPianoKeyboard keyboardMsg ->
            let
                ( keyboardModel, keyboardCmd ) =
                    toKeyboard model.activeSearch
                        |> Keyboard.update keyboardMsg

                newModel =
                    setKeyboard keyboardModel model.activeSearch
                        |> flip setActiveSearch model

                probeCmd =
                    if keyboardModel.needsProbe == True then
                        let
                            probeUrl =
                                createProbeUrl newModel.activeSearch
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

        UserClickedPianoKeyboardSearchSubmitButton ->
            searchSubmit session model

        UserClickedPianoKeyboardSearchClearButton ->
            setKeyboard Keyboard.initModel model.activeSearch
                |> flip setActiveSearch model
                |> searchSubmit session

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
                |> setKeyboard Keyboard.initModel
                |> flip setActiveSearch model
                |> searchSubmit session

        NothingHappened ->
            ( model, Cmd.none )
