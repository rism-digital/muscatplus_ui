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


viewFacetsForInstitutionsMode : ControlsConfig body msg -> List (Element msg)
viewFacetsForInstitutionsMode cfg =
    let
        facetConfig alias =
            { alias = alias
            , language = cfg.language
            , activeSearch = cfg.activeSearch
            , selectColumns = cfg.numberOfSelectColumns
            , body = cfg.body
            }

        city =
            viewFacet (facetConfig "city") cfg.facetMsgConfig
    in
    [ viewFacetsControlPanel
        (.alias institutionFacetPanels.locationPanel)
        (.label institutionFacetPanels.locationPanel)
        cfg
        [ city
        ]
    ]
