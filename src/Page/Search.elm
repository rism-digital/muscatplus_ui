module Page.Search exposing (..)

import ActiveSearch exposing (setActiveSearch, setExpandedFacets, setKeyboard, toActiveSearch, toExpandedFacets, toKeyboard, toSelectedMode, toggleExpandedFacets)
import Browser.Navigation as Nav
import Page.Converters exposing (convertFacetToResultMode)
import Page.Query exposing (Filter(..), buildQueryParameters, resetPage, setFilters, setMode, setQuery, setQueryArgs, setSort, toFilters, toMode, toQueryArgs, toggleFilters)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Page.Route exposing (Route)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Keyboard as Keyboard exposing (buildNotationRequestQuery, setNotation, toNotation)
import Page.UI.Keyboard.Model exposing (toKeyboardQuery)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Request exposing (serverUrl)
import Response exposing (Response(..), ServerData)
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

        resetQueryArgs =
            activeSearch
                |> toQueryArgs
                |> resetPage

        -- when submitting a new search, reset the page
        -- to the first page.
        pageResetModel =
            activeSearch
                |> setQueryArgs resetQueryArgs
                |> flip setActiveSearch model

        notationQueryParameters =
            pageResetModel
                |> toActiveSearch
                |> toKeyboard
                |> toKeyboardQuery
                |> buildNotationQueryParameters

        textQueryParameters =
            pageResetModel
                |> toActiveSearch
                |> toQueryArgs
                |> buildQueryParameters

        newModel =
            { pageResetModel
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


update : Session -> SearchMsg -> SearchPageModel -> ( SearchPageModel, Cmd SearchMsg )
update session msg model =
    case msg of
        ServerRespondedWithSearchData (Ok ( _, response )) ->
            let
                currentMode =
                    toActiveSearch model
                        |> toQueryArgs
                        |> toMode

                keyboardQuery =
                    toActiveSearch model
                        |> toKeyboard
                        |> toKeyboardQuery

                notationRenderCmd =
                    case currentMode of
                        IncipitsMode ->
                            Cmd.map UserInteractedWithPianoKeyboard (buildNotationRequestQuery keyboardQuery)

                        _ ->
                            Cmd.none
            in
            ( { model
                | response = Response response
              }
            , notationRenderCmd
            )

        ServerRespondedWithSearchData (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        ServerRespondedWithSearchPreview (Ok ( metadata, response )) ->
            ( { model
                | preview = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithSearchPreview (Err error) ->
            ( { model
                | response = Error (createErrorMessage error)
              }
            , Cmd.none
            )

        ClientJumpedToId ->
            ( model, Cmd.none )

        ClientResetViewport ->
            ( model, Cmd.none )

        UserChangedFacetBehaviour facetBehaviour ->
            ( model, Cmd.none )

        UserChangedFacetSort facetSort ->
            ( model, Cmd.none )

        UserChangedFacetMode facetMode ->
            ( model, Cmd.none )

        UserClickedFacetPanelToggle ->
            ( model, Cmd.none )

        UserClickedFacetExpand alias ->
            let
                newExpandedFacets =
                    toActiveSearch model
                        |> toExpandedFacets
                        |> toggleExpandedFacets alias

                newModel =
                    toActiveSearch model
                        |> setExpandedFacets newExpandedFacets
                        |> flip setActiveSearch model
            in
            ( newModel, Cmd.none )

        UserClickedFacetItem facet item isClicked ->
            ( model, Cmd.none )

        UserClickedFacetToggle label ->
            let
                newFilter =
                    Filter label "true"

                newFilters =
                    toActiveSearch model
                        |> toQueryArgs
                        |> toFilters
                        |> toggleFilters newFilter

                newQueryArgs =
                    toActiveSearch model
                        |> toQueryArgs
                        |> setFilters newFilters

                newModel =
                    toActiveSearch model
                        |> setQueryArgs newQueryArgs
                        |> flip setActiveSearch model
            in
            searchSubmit session newModel

        UserMovedRangeSlider facet slider ->
            ( model, Cmd.none )

        UserChangedResultSorting sort ->
            let
                sortValue =
                    Just sort

                newQueryArgs =
                    toActiveSearch model
                        |> toQueryArgs
                        |> setSort sortValue

                newModel =
                    toActiveSearch model
                        |> setQueryArgs newQueryArgs
                        |> flip setActiveSearch model
            in
            searchSubmit session newModel

        UserClickedModeItem facet item isClicked ->
            let
                newMode =
                    convertFacetToResultMode item

                newQuery =
                    toActiveSearch model
                        |> toQueryArgs
                        |> setMode newMode

                newModel =
                    toActiveSearch model
                        |> setQueryArgs newQuery
                        |> flip setActiveSearch model
            in
            searchSubmit session newModel

        UserClickedRemoveActiveFilter activeAlias activeValue ->
            let
                activeSearch =
                    toActiveSearch model

                oldFilters =
                    activeSearch
                        |> toQueryArgs
                        |> toFilters

                newFilters =
                    List.filter
                        (\(Filter filterAlias filterValue) ->
                            not ((filterAlias == activeAlias) && (filterValue == activeValue))
                        )
                        oldFilters

                newQueryArgs =
                    activeSearch
                        |> toQueryArgs
                        |> setFilters newFilters

                newModel =
                    activeSearch
                        |> setQueryArgs newQueryArgs
                        |> flip setActiveSearch model
            in
            searchSubmit session newModel

        UserClickedClearSearchQueryBox ->
            let
                newQuery =
                    toActiveSearch model
                        |> toQueryArgs
                        |> setQuery Nothing

                newModel =
                    toActiveSearch model
                        |> setQueryArgs newQuery
                        |> flip setActiveSearch model
            in
            searchSubmit session newModel

        UserClickedSearchResultsPagination url ->
            ( model
            , Cmd.batch
                [ Nav.pushUrl session.key url
                ]
            )

        UserTriggeredSearchSubmit ->
            searchSubmit session model

        UserInputTextInQueryBox queryText ->
            let
                newText =
                    if String.isEmpty queryText then
                        Nothing

                    else
                        Just queryText

                newQueryArgs =
                    toActiveSearch model
                        |> toQueryArgs
                        |> setQuery newText

                newModel =
                    toActiveSearch model
                        |> setQueryArgs newQueryArgs
                        |> flip setActiveSearch model
            in
            ( newModel
            , Cmd.none
            )

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
                    toActiveSearch model
                        |> toKeyboard

                ( keyboardModel, keyboardCmd ) =
                    Keyboard.update keyboardMsg oldKeyboard

                newModel =
                    toActiveSearch model
                        |> setKeyboard keyboardModel
                        |> flip setActiveSearch model
            in
            ( newModel
            , Cmd.map UserInteractedWithPianoKeyboard keyboardCmd
            )

        UserClickedPianoKeyboardSearchSubmitButton ->
            searchSubmit session model

        UserClickedPianoKeyboardSearchClearButton ->
            let
                newModel =
                    toActiveSearch model
                        |> setKeyboard Keyboard.initModel
                        |> flip setActiveSearch model
            in
            searchSubmit session newModel

        NothingHappened ->
            ( model, Cmd.none )
