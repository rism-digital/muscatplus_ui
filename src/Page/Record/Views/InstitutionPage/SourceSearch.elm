module Page.Record.Views.InstitutionPage.SourceSearch exposing (..)

import Element exposing (Element, alignTop, clipY, column, fill, height, htmlAttribute, inFront, none, row, scrollbarY, shrink, text, width)
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.RecordTypes.Search exposing (SearchBody, SearchResult(..), SourceResultBody)
import Page.Search.Views.Previews exposing (viewPreviewRouter)
import Page.Search.Views.Results exposing (resultIsSelected, resultTemplate)
import Page.Search.Views.Results.SourceResult exposing (viewSourceFlags, viewSourcePartOf, viewSourceSummary)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))


viewSourceSearchTab : Language -> RecordPageModel -> InstitutionBody -> Element RecordMsg
viewSourceSearchTab language model body =
    row
        [ width fill
        , height fill
        , alignTop
        , clipY
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ searchResultsViewRouter language model ]
        ]


searchResultsViewRouter : Language -> RecordPageModel -> Element RecordMsg
searchResultsViewRouter language model =
    case model.searchResults of
        Loading (Just (SearchData oldData)) ->
            viewSearchResultsSection language model oldData True

        Loading _ ->
            viewSearchResultsLoading language model

        Response (SearchData body) ->
            viewSearchResultsSection language model body False

        NoResponseToShow ->
            -- In case we're just booting the app up, show
            -- the loading message.
            viewSearchResultsLoading language model

        _ ->
            viewSearchResultsError language model


viewSearchResultsLoading : Language -> RecordPageModel -> Element RecordMsg
viewSearchResultsLoading language model =
    none


viewSearchResultsError : Language -> RecordPageModel -> Element RecordMsg
viewSearchResultsError language model =
    none


viewSearchResultsSection : Language -> RecordPageModel -> SearchBody -> Bool -> Element RecordMsg
viewSearchResultsSection language model body isLoading =
    let
        renderedPreview =
            case model.preview of
                Loading Nothing ->
                    none

                Loading (Just oldData) ->
                    viewPreviewRouter language RecordMsg.UserClickedClosePreviewWindow oldData

                Response resp ->
                    viewPreviewRouter language RecordMsg.UserClickedClosePreviewWindow resp

                Error _ ->
                    none

                NoResponseToShow ->
                    none
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , Border.widthEach { bottom = 0, top = 0, left = 0, right = 2 }
            , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
            ]
            [ viewSearchResultsListPanel language model body isLoading
            , viewPagination language body.pagination RecordMsg.UserClickedSearchResultsPagination
            ]
        , column
            [ width fill
            , height fill
            , alignTop
            , inFront renderedPreview
            ]
            [ text "world" ]
        ]


viewSearchResultsListPanel : Language -> RecordPageModel -> SearchBody -> Bool -> Element RecordMsg
viewSearchResultsListPanel language model body isLoading =
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.id "search-results-list")
        ]
        [ column
            [ width fill
            , height shrink
            , alignTop
            ]
            [ viewSearchResultsList language model body ]
        ]


viewSearchResultsList : Language -> RecordPageModel -> SearchBody -> Element RecordMsg
viewSearchResultsList language model body =
    row
        [ width fill
        , height shrink
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            ]
            (List.map (\result -> viewSearchResultRouter language model.selectedResult result) body.items)
        ]


viewSearchResultRouter : Language -> Maybe String -> SearchResult -> Element RecordMsg
viewSearchResultRouter language selectedResult res =
    case res of
        SourceResult body ->
            viewSourceSearchResult language selectedResult body

        _ ->
            none


viewSourceSearchResult : Language -> Maybe String -> SourceResultBody -> Element RecordMsg
viewSourceSearchResult language selectedResult body =
    let
        resultColours =
            resultIsSelected selectedResult body.id

        resultBody =
            [ viewMaybe (viewSourceSummary language resultColours.iconColour) body.summary
            , viewMaybe (viewSourcePartOf language resultColours.fontLinkColour) body.partOf
            , viewMaybe (viewSourceFlags language) body.flags
            ]
    in
    resultTemplate
        { id = body.id
        , language = language
        , resultTitle = body.label
        , colours = resultColours
        , resultBody = resultBody
        , clickMsg = RecordMsg.UserClickedSearchResultForPreview
        }
