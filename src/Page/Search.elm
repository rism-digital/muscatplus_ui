module Page.Search exposing (..)

import ActiveSearch exposing (setActiveSearch, toActiveSearch, toKeyboard)
import Browser.Navigation as Nav
import List.Extra as LE
import Page.Converters exposing (convertFacetToResultMode)
import Page.Query exposing (Filter(..), buildQueryParameters, resetPage, setFilters, setMode, setQuery, setQueryArgs, setSort, toFilters, toQueryArgs, toggleFilters)
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Page.Route exposing (Route)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg exposing (SearchMsg(..))
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
    load route Nothing


load : Route -> Maybe ServerData -> SearchPageModel
load route oldData =
    { response = Loading oldData
    , activeSearch = ActiveSearch.init route
    , preview = NoResponseToShow
    , selectedResult = Nothing
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
            ( { model
                | response = Response response
              }
            , Cmd.none
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

        UserClickedFacetExpand facet ->
            ( model, Cmd.none )

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
                newQuery =
                    toActiveSearch model
                        |> toQueryArgs
                        |> setMode (convertFacetToResultMode item)

                newModel =
                    toActiveSearch model
                        |> setQueryArgs newQuery
                        |> flip setActiveSearch model
            in
            searchSubmit session newModel

        UserClickedRemoveActiveFilter activeAlias activeValue ->
            ( model, Cmd.none )

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
            ( model, Cmd.none )

        UserClickedPianoKeyboardSearchSubmitButton ->
            ( model, Cmd.none )

        UserClickedPianoKeyboardSearchClearButton ->
            ( model, Cmd.none )

        NothingHappened ->
            ( model, Cmd.none )
