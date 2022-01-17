module Page.Record.Views.InstitutionPage.SourcesTab exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, link, maximum, minimum, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Msg as RecordMsg exposing (RecordMsg(..))
import Page.RecordTypes.Search exposing (SearchBody, SearchResult)
import Page.Search.Views.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.Search.Views.Results exposing (viewResultFlags)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (h5)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Pagination exposing (viewPagination)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))


viewInstitutionSourcesTab : Language -> String -> ActiveSearch -> Response -> Element RecordMsg
viewInstitutionSourcesTab language sourcesUrl pageSearch searchData =
    let
        msgs =
            { submitMsg = RecordMsg.UserClickedPageSearchSubmitButton
            , changeMsg = RecordMsg.UserInputTextInPageQueryBox
            }

        pageQuery =
            pageSearch.nextQuery

        qText =
            Maybe.withDefault "" pageQuery.keywordQuery

        resultsView =
            case searchData of
                Response (SearchData body) ->
                    viewInstitutionSourceResultsSection language body

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
                    [ searchKeywordInput language msgs qText ]
                ]
            , resultsView
            ]
        ]


viewInstitutionSourceResultsSection : Language -> SearchBody -> Element RecordMsg
viewInstitutionSourceResultsSection language body =
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
                []

            -- [ text ("Found " ++ String.fromInt body.totalItems ++ " results") ]
            , viewInstitutionSourceResultsList language body
            , viewPagination language body.pagination UserClickedRecordViewTabPagination
            ]
        ]


viewInstitutionSourceResultsList : Language -> SearchBody -> Element msg
viewInstitutionSourceResultsList language body =
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
            (List.map (\result -> viewInstitutionSearchResult language result) body.items)
        ]


viewInstitutionSearchResult : Language -> SearchResult -> Element msg
viewInstitutionSearchResult language result =
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
