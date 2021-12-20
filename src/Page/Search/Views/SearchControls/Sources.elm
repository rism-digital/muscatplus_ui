module Page.Search.Views.SearchControls.Sources exposing (..)

import ActiveSearch exposing (toActiveSearch)
import Element exposing (Element, alignTop, column, el, fill, height, maximum, minimum, padding, paddingXY, px, row, scrollbarY, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Page.Query exposing (toNextQuery, toQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.Search.Model exposing (SearchPageModel)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.Search.Views.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Attributes exposing (facetBorderBottom, headingLG, headingMD, headingSM, lineSpacing, sectionSpacing, widthFillHeightFill)
import Page.UI.Components exposing (searchKeywordInput)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewProbeResponseNumbers : Language -> ProbeData -> Element SearchMsg
viewProbeResponseNumbers language probeData =
    let
        formattedNumber =
            probeData.totalItems
                |> toFloat
                |> formatNumberByLanguage language
    in
    el
        [ headingSM ]
        (text ("Results with filters applied: " ++ formattedNumber))


viewFacetsForSourcesMode : Language -> SearchPageModel -> SearchBody -> Element SearchMsg
viewFacetsForSourcesMode language model body =
    let
        msgs =
            { submitMsg = SearchMsg.UserTriggeredSearchSubmit
            , changeMsg = SearchMsg.UserInputTextInQueryBox
            }

        activeSearch =
            toActiveSearch model

        qText =
            toNextQuery activeSearch
                |> toQuery
                |> Maybe.withDefault ""
    in
    row
        (List.append
            [ padding 10
            , scrollbarY
            ]
            widthFillHeightFill
        )
        [ column
            (List.append [ spacing lineSpacing ] widthFillHeightFill)
            [ row
                widthFillHeightFill
                [ column
                    [ width fill
                    , alignTop
                    ]
                    [ searchKeywordInput language msgs qText ]
                ]
            , row
                (List.append [ width fill ] facetBorderBottom)
                [ column
                    widthFillHeightFill
                    [ el
                        [ width fill
                        , headingMD
                        ]
                        (text "Refinements")
                    ]
                ]
            , viewFacetSection language
                "People"
                [ viewFacet "composer" language activeSearch body
                , viewFacet "people" language activeSearch body
                ]
            , viewFacetSection language
                "Digitization"
                [ viewFacet "has-digitization" language activeSearch body ]
            , viewFacetSection language
                "Incipits"
                [ viewFacet "has-incipits" language activeSearch body ]
            , viewFacetSection language
                "Record types"
                [ viewFacet "hide-source-contents" language activeSearch body
                , viewFacet "hide-source-collections" language activeSearch body
                , viewFacet "hide-composite-volumes" language activeSearch body
                , viewFacet "source-type" language activeSearch body
                , viewFacet "content-types" language activeSearch body
                , viewFacet "material-group-types" language activeSearch body
                ]
            , viewFacetSection language
                "Format, Extent, Language"
                [ viewFacet "text-language" language activeSearch body
                , viewFacet "format-extent" language activeSearch body
                ]

            --, viewFacet "date-range" language activeSearch body
            --, viewFacet "num-holdings" language activeSearch body
            , viewFacetSection language
                "Subjects"
                [ viewFacet "subjects" language activeSearch body ]

            --, viewFacet "holding-institution" language activeSearch body
            ]
        ]
