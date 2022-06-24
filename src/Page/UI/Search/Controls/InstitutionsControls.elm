module Page.UI.Search.Controls.InstitutionsControls exposing (viewFacetsForInstitutionsMode)

import Element exposing (Element, alignTop, column, fill, height, none, padding, paddingEach, row, scrollbarY, width)
import Language.LocalTranslations exposing (facetPanelTitles)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetSection, viewFacetsControlPanel)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)


institutionFacetPanels =
    { locationPanel =
        { alias = "institution-location-panel"
        , label = facetPanelTitles.location
        }
    }


viewFacetsForInstitutionsMode : ControlsConfig msg -> Element msg
viewFacetsForInstitutionsMode cfg =
    let
        facetConfig alias =
            { alias = alias
            , language = cfg.language
            , activeSearch = cfg.activeSearch
            , selectColumns = cfg.numberOfSelectColumns
            , body = cfg.body
            }

        qText =
            toNextQuery cfg.activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

        city =
            viewFacet (facetConfig "city") cfg.facetMsgConfig
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
                [ width fill ]
                [ searchKeywordInput
                    { language = cfg.language
                    , submitMsg = cfg.userTriggeredSearchSubmitMsg
                    , changeMsg = cfg.userEnteredTextInKeywordQueryBoxMsg
                    , queryText = qText
                    }
                ]
            , row
                [ width fill
                , paddingEach { top = 10, bottom = 0, left = 0, right = 0 }
                ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , viewFacetsControlPanel
                (.alias institutionFacetPanels.locationPanel)
                (.label institutionFacetPanels.locationPanel)
                cfg
                [ city
                ]
            ]
        ]
