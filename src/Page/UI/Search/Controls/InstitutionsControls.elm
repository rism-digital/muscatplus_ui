module Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)

import Element exposing (Element, alignTop, column, fill, height, padding, row, scrollbarY, width)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetSection)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)


viewFacetsForInstitutionsMode : ControlsConfig msg -> Element msg
viewFacetsForInstitutionsMode { language, activeSearch, body, panelToggleMsg, userTriggeredSearchSubmitMsg, userEnteredTextInKeywordQueryBoxMsg, facetMsgConfig, numberOfSelectColumns } =
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
        [ width fill
        , height fill
        , alignTop
        , padding 10
        ]
        [ column
            [ width fill
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
                panelToggleMsg
                [ viewFacet (facetConfig "has-siglum") facetMsgConfig ]
            , viewFacetSection language
                panelToggleMsg
                [ viewFacet (facetConfig "city") facetMsgConfig
                ]
            ]
        ]
