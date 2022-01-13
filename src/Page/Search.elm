module Page.Search exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setExpandedFacets, setKeyboard, setRangeFacetValues, toActiveSearch, toExpandedFacets, toKeyboard, toRangeFacetValues, toggleExpandedFacets)
import Browser.Navigation as Nav
import Dict exposing (Dict)
import List.Extra as LE
import Page.Query exposing (buildQueryParameters, defaultQueryArgs, resetPage, setFacetBehaviours, setFacetSorts, setFilters, setKeywordQuery, setMode, setNationalCollection, setNextQuery, setSort, toFacetBehaviours, toFacetSorts, toFilters, toMode, toNextQuery)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetData(..), FacetItem(..), FacetSorts(..), RangeFacetValue(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Request exposing (createErrorMessage, createProbeRequestWithDecoder, createRequestWithDecoder, createSuggestRequestWithDecoder)
import Page.Route exposing (Route)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.Search.Utilities exposing (createRangeString, parseRangeFilterValue)
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
    , probeResponse = Nothing
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
    , probeResponse = Nothing
    , applyFilterPrompt = False
    }


searchPageRequest : Url -> Cmd SearchMsg
searchPageRequest requestUrl =
    createRequestWithDecoder ServerRespondedWithSearchData (Url.toString requestUrl)


searchPagePreviewRequest : String -> Cmd SearchMsg
searchPagePreviewRequest previewUrl =
    createRequestWithDecoder ServerRespondedWithSearchPreview previewUrl


addNationalCollectionFilter : Maybe String -> SearchPageModel -> SearchPageModel
addNationalCollectionFilter ncFilter model =
    let
        oldQuery =
            toActiveSearch model
                |> toNextQuery

        newQuery =
            oldQuery
                |> setNationalCollection ncFilter

        newModel =
            toActiveSearch model
                |> setNextQuery newQuery
                |> flip setActiveSearch model
    in
    newModel


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


probeSubmit : Session -> SearchPageModel -> ( SearchPageModel, Cmd SearchMsg )
probeSubmit session model =
    let
        newModel =
            addNationalCollectionFilter session.restrictedToNationalCollection model

        notationQueryParameters =
            toActiveSearch newModel
                |> toKeyboard
                |> toKeyboardQuery
                |> buildNotationQueryParameters

        textQueryParameters =
            toActiveSearch newModel
                |> toNextQuery
                |> buildQueryParameters

        probeUrl =
            List.append textQueryParameters notationQueryParameters
                |> serverUrl [ "probe" ]
    in
    ( newModel
    , createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl
    )


updateQueryFacetValues : Session -> SearchPageModel -> String -> FacetBehaviours -> ( SearchPageModel, Cmd SearchMsg )
updateQueryFacetValues session model alias currentBehaviour =
    let
        activeFilters =
            toNextQuery model.activeSearch
                |> toFilters

        newActiveFilters =
            Dict.update alias
                (\existingValues ->
                    case existingValues of
                        Just [] ->
                            Just []

                        Just (x :: xs) ->
                            Just ("" :: x :: xs)

                        Nothing ->
                            Just []
                )
                activeFilters

        newActiveBehaviours =
            toNextQuery model.activeSearch
                |> toFacetBehaviours
                |> Dict.insert alias currentBehaviour
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> setFacetBehaviours newActiveBehaviours
        |> flip setNextQuery model.activeSearch
        |> setActiveSuggestion Nothing
        |> flip setActiveSearch model
        |> probeSubmit session


updateQueryFacetFilters : FacetAlias -> String -> SearchPageModel -> SearchPageModel
updateQueryFacetFilters alias text model =
    let
        activeFacets =
            toNextQuery model.activeSearch
                |> toFilters

        newActiveFilters =
            Dict.update alias
                (\existingValues ->
                    case existingValues of
                        Just [] ->
                            Just [ text ]

                        Just (_ :: xs) ->
                            Just (text :: xs)

                        Nothing ->
                            Just [ text ]
                )
                activeFacets
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> flip setNextQuery model.activeSearch
        |> setActiveSuggestion Nothing
        |> flip setActiveSearch model


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
                            Just { totalItems = body.totalItems }

                        _ ->
                            Nothing
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
                | probeResponse = Just response
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
            toNextQuery model.activeSearch
                |> toFacetBehaviours
                |> Dict.insert alias facetBehaviour
                |> flip setFacetBehaviours (toNextQuery model.activeSearch)
                |> flip setNextQuery model.activeSearch
                |> flip setActiveSearch model
                |> probeSubmit session

        UserChangedFacetSort alias facetSort ->
            let
                newFacetSorts =
                    toNextQuery model.activeSearch
                        |> toFacetSorts
                        |> Dict.insert alias facetSort

                newModel =
                    toNextQuery model.activeSearch
                        |> setFacetSorts newFacetSorts
                        |> flip setNextQuery model.activeSearch
                        |> flip setActiveSearch model
            in
            ( newModel, Cmd.none )

        UserClickedFacetPanelToggle ->
            ( model, Cmd.none )

        UserEnteredTextInQueryFacet alias text suggestionUrl ->
            let
                newModel =
                    updateQueryFacetFilters alias text model

                ( suggestModel, suggestionCmd ) =
                    if String.length text > 2 then
                        ( newModel, createSuggestRequestWithDecoder ServerRespondedWithSuggestionData (String.append suggestionUrl text) )

                    else if String.length text == 0 then
                        let
                            clearSuggestionModel =
                                setActiveSuggestion Nothing newModel.activeSearch
                                    |> flip setActiveSearch newModel
                        in
                        ( clearSuggestionModel, Cmd.none )

                    else
                        ( newModel, Cmd.none )
            in
            ( suggestModel, suggestionCmd )

        UserChoseOptionFromQueryFacetSuggest alias selectedValue currentBehaviour ->
            let
                newModel =
                    updateQueryFacetFilters alias selectedValue model
            in
            updateQueryFacetValues session newModel alias currentBehaviour

        UserHitEnterInQueryFacet alias currentBehaviour ->
            updateQueryFacetValues session model alias currentBehaviour

        UserRemovedItemFromQueryFacet alias query ->
            let
                activeFilters =
                    toNextQuery model.activeSearch
                        |> toFilters

                newActiveFilters =
                    Dict.update alias
                        (\existingValues ->
                            case existingValues of
                                Just list ->
                                    Just (List.filter (\s -> s /= query) list)

                                Nothing ->
                                    Nothing
                        )
                        activeFilters
            in
            toNextQuery model.activeSearch
                |> setFilters newActiveFilters
                |> flip setNextQuery model.activeSearch
                |> flip setActiveSearch model
                |> probeSubmit session

        UserEnteredTextInRangeFacet alias inputBox value ->
            let
                rangeFacetValues =
                    toRangeFacetValues model.activeSearch

                newRangeFacetValues =
                    Dict.update alias
                        (\existingValues ->
                            case existingValues of
                                Just ( lower, upper ) ->
                                    case inputBox of
                                        LowerRangeValue ->
                                            Just ( value, upper )

                                        UpperRangeValue ->
                                            Just ( lower, value )

                                Nothing ->
                                    case inputBox of
                                        LowerRangeValue ->
                                            Just ( value, "*" )

                                        UpperRangeValue ->
                                            Just ( "*", value )
                        )
                        rangeFacetValues

                newModel =
                    setRangeFacetValues newRangeFacetValues model.activeSearch
                        |> flip setActiveSearch model
            in
            ( newModel, Cmd.none )

        UserFocusedRangeFacet alias valueType ->
            ( model, Cmd.none )

        UserLostFocusRangeFacet alias valueType ->
            let
                rangeFacetValues =
                    toRangeFacetValues model.activeSearch

                ( lowerValue, upperValue ) =
                    Dict.get alias rangeFacetValues
                        |> Maybe.withDefault ( "*", "*" )

                newLowerValue =
                    if lowerValue == "" then
                        "*"

                    else
                        lowerValue

                newUpperValue =
                    if upperValue == "" then
                        "*"

                    else
                        upperValue

                rangeString =
                    createRangeString newLowerValue newUpperValue

                newActiveFilters =
                    toNextQuery model.activeSearch
                        |> toFilters
                        |> Dict.insert alias [ rangeString ]

                -- ensure the range facet also displays the correct value
                newRangeFacetValues =
                    toRangeFacetValues model.activeSearch
                        |> Dict.insert alias ( newLowerValue, newUpperValue )
            in
            toNextQuery model.activeSearch
                |> setFilters newActiveFilters
                |> flip setNextQuery model.activeSearch
                |> setRangeFacetValues newRangeFacetValues
                |> flip setActiveSearch model
                |> probeSubmit session

        UserClickedFacetExpand alias ->
            let
                newExpandedFacets =
                    toExpandedFacets model.activeSearch
                        |> toggleExpandedFacets alias

                newModel =
                    setExpandedFacets newExpandedFacets model.activeSearch
                        |> flip setActiveSearch model
            in
            ( newModel, Cmd.none )

        UserClickedFacetItem alias facetValue isClicked ->
            let
                activeFilters =
                    toNextQuery model.activeSearch
                        |> toFilters

                newActiveFilters =
                    Dict.update alias
                        (\existingValues ->
                            case existingValues of
                                Just list ->
                                    if List.member facetValue list == False then
                                        Just (facetValue :: list)

                                    else
                                        Just (LE.remove facetValue list)

                                Nothing ->
                                    Just [ facetValue ]
                        )
                        activeFilters
            in
            toNextQuery model.activeSearch
                |> setFilters newActiveFilters
                |> flip setNextQuery model.activeSearch
                |> flip setActiveSearch model
                |> probeSubmit session

        UserClickedFacetToggle alias ->
            let
                oldFilters =
                    toNextQuery model.activeSearch
                        |> toFilters

                newFilters =
                    if Dict.member alias oldFilters == True then
                        Dict.remove alias oldFilters

                    else
                        Dict.insert alias [ "true" ] oldFilters

                newQueryArgs =
                    toNextQuery model.activeSearch
                        |> setFilters newFilters
            in
            setNextQuery newQueryArgs model.activeSearch
                |> flip setActiveSearch model
                |> probeSubmit session

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

        UserInputTextInKeywordQueryBox queryText ->
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
            in
            probeSubmit session newModel

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
                oldKeyboard =
                    toKeyboard model.activeSearch

                ( keyboardModel, keyboardCmd ) =
                    Keyboard.update keyboardMsg oldKeyboard

                newModel =
                    setKeyboard keyboardModel model.activeSearch
                        |> flip setActiveSearch model
            in
            ( newModel
            , Cmd.map UserInteractedWithPianoKeyboard keyboardCmd
            )

        UserClickedPianoKeyboardSearchSubmitButton ->
            searchSubmit session model

        UserClickedPianoKeyboardSearchClearButton ->
            setKeyboard Keyboard.initModel model.activeSearch
                |> flip setActiveSearch model
                |> searchSubmit session

        UserResetAllFilters ->
            setNextQuery defaultQueryArgs model.activeSearch
                |> setRangeFacetValues Dict.empty
                |> flip setActiveSearch model
                |> probeSubmit session

        NothingHappened ->
            ( model, Cmd.none )
