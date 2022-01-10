module Page.Search exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setExpandedFacets, setKeyboard, setNeedsProbing, toActiveSearch, toExpandedFacets, toKeyboard, toggleExpandedFacets)
import Browser.Navigation as Nav
import Dict
import List.Extra as LE
import Page.Query exposing (buildQueryParameters, defaultQueryArgs, resetPage, setFacetBehaviours, setFacetSorts, setFilters, setKeywordQuery, setMode, setNationalCollection, setNextQuery, setSort, toFacetBehaviours, toFacetSorts, toFilters, toMode, toNextQuery)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetData(..), FacetItem(..), FacetSorts(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Request exposing (createErrorMessage, createProbeRequestWithDecoder, createRequestWithDecoder, createSuggestRequestWithDecoder)
import Page.Route exposing (Route)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
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
        |> setNeedsProbing True
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
                    if String.length text > 3 then
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

        UserEnteredTextInRangeFacet alias ( lower, upper ) ->
            let
                activeFilters =
                    toNextQuery model.activeSearch
                        |> toFilters

                rangeString =
                    "[" ++ lower ++ " TO " ++ upper ++ "]"

                newActiveFilters =
                    Dict.insert alias [ rangeString ] activeFilters
            in
            toNextQuery model.activeSearch
                |> setFilters newActiveFilters
                |> flip setNextQuery model.activeSearch
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
                |> setNeedsProbing True
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
                |> flip setActiveSearch model
                |> searchSubmit session

        NothingHappened ->
            ( model, Cmd.none )
