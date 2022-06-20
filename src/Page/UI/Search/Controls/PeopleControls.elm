module Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)

import Element exposing (Element, alignTop, column, fill, height, padding, row, scrollbarY, spacing, width)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (FacetConfig, viewFacet, viewFacetSection)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)


viewFacetsForPeopleMode : ControlsConfig msg -> Element msg
viewFacetsForPeopleMode { language, activeSearch, body, sectionToggleMsg, userTriggeredSearchSubmitMsg, userEnteredTextInKeywordQueryBoxMsg, facetMsgConfig, numberOfSelectColumns } =
    let
        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , selectColumns = numberOfSelectColumns
            , body = body
            }

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""
    in
    row
        [ padding 10
        , width fill
        , alignTop
        , height fill
        ]
        [ column
            [ spacing lineSpacing
            , width fill
            , alignTop
            ]
            [ row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    [ searchKeywordInput
                        { language = language
                        , submitMsg = userTriggeredSearchSubmitMsg
                        , changeMsg = userEnteredTextInKeywordQueryBoxMsg
                        , queryText = qText
                        }
                    ]
                ]
            , row
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "roles") facetMsgConfig ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "date-range") facetMsgConfig ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "associated-place") facetMsgConfig ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "gender") facetMsgConfig ]
            , viewFacetSection language
                sectionToggleMsg
                [ viewFacet (facetConfig "profession") facetMsgConfig ]
            ]
        ]
