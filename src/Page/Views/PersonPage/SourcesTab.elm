module Page.Views.PersonPage.SourcesTab exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, link, maximum, minimum, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.Model exposing (PageSearch, Response(..))
import Page.RecordTypes.Search exposing (SearchBody, SearchResult)
import Page.Response exposing (ServerData(..))
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (h5, searchKeywordInput)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Pagination exposing (viewRecordSourceResultsPagination)
import Page.Views.SearchPage.Results exposing (viewResultFlags, viewSearchResult)


viewPersonSourcesTab : Language -> String -> PageSearch -> Response -> Element Msg
viewPersonSourcesTab language sourcesUrl pageSearch searchData =
    let
        msgs =
            { submitMsg = Msg.UserClickedPageSearchSubmitButton sourcesUrl
            , changeMsg = Msg.UserInputTextInPageQueryBox
            }

        pageQuery =
            pageSearch.query

        qText =
            Maybe.withDefault "" pageQuery.query

        resultsView =
            case searchData of
                Response (SearchData body) ->
                    viewPersonSourceResultsSection language body

                Error err ->
                    text err

                _ ->
                    none
    in
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ column
                    [ width (fill |> minimum 800 |> maximum 1100)
                    , alignTop
                    , paddingXY 20 10
                    ]
                    [ searchKeywordInput msgs qText language ]
                ]
            , resultsView
            ]
        ]


viewPersonSourceResultsSection : Language -> SearchBody -> Element Msg
viewPersonSourceResultsSection language body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill ]
                [ text ("Found " ++ String.fromInt body.totalItems ++ " results") ]
            , viewPersonSourceResultsList language body
            , viewRecordSourceResultsPagination language body.pagination
            ]
        ]


viewPersonSourceResultsList : Language -> SearchBody -> Element Msg
viewPersonSourceResultsList language body =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 40
            ]
            (List.map (\result -> viewPersonSearchResult language result) body.items)
        ]


viewPersonSearchResult : Language -> SearchResult -> Element Msg
viewPersonSearchResult language result =
    let
        resultTitle =
            el
                [ Font.color (colourScheme.lightBlue |> convertColorToElementColor)
                , width fill
                ]
                (link [] { url = result.id, label = h5 language result.label })

        resultFlags : Element msg
        resultFlags =
            viewMaybe (viewResultFlags language) result.flags

        partOf =
            case result.partOf of
                Just partOfBody ->
                    let
                        source =
                            partOfBody.source
                    in
                    row
                        [ width fill
                        , bodyRegular
                        ]
                        [ column
                            [ width fill
                            ]
                            [ row
                                [ width fill ]
                                [ text "Part of " -- TODO: Translate!
                                , link
                                    [ Font.color (colourScheme.lightBlue |> convertColorToElementColor) ]
                                    { url = source.id
                                    , label = text (extractLabelFromLanguageMap language source.label)
                                    }
                                ]
                            ]
                        ]

                Nothing ->
                    none

        summary =
            case result.summary of
                Just fields ->
                    row
                        [ width fill
                        , bodyRegular
                        ]
                        [ column
                            [ width fill
                            ]
                            (List.map (\l -> el [] (text (extractLabelFromLanguageMap language l.value))) fields)
                        ]

                Nothing ->
                    none
    in
    row
        [ width fill

        --, height (px 100)
        , alignTop

        --, Border.widthEach { left = 2, right = 0, bottom = 0, top = 0 }
        --, Border.color colourScheme.midGrey
        , paddingXY 20 20
        , Font.color (colourScheme.black |> convertColorToElementColor)
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 10
            ]
            [ row
                [ width fill
                , alignLeft
                , spacing 10
                ]
                [ resultTitle
                ]
            , summary
            , partOf
            , resultFlags
            ]
        ]
