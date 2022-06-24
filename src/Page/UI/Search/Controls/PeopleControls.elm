module Page.UI.Search.Controls.PeopleControls exposing (viewFacetsForPeopleMode)

import Element exposing (Element, alignTop, column, fill, height, padding, paddingEach, row, width)
import Language.LocalTranslations exposing (facetPanelTitles)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (viewFacet, viewFacetsControlPanel)
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Search.Controls.ControlsConfig exposing (ControlsConfig)


personFacetPanels =
    { biographicalInfoPanel =
        { alias = "person-biography-panel"
        , label = facetPanelTitles.biographicalDetails
        }
    , roleAndProfession =
        { alias = "person-role-profession-panel"
        , label = facetPanelTitles.roleAndProfession
        }
    }


viewFacetsForPeopleMode : ControlsConfig msg -> Element msg
viewFacetsForPeopleMode cfg =
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

        dates =
            viewFacet (facetConfig "date-range") cfg.facetMsgConfig

        gender =
            viewFacet (facetConfig "gender") cfg.facetMsgConfig

        places =
            viewFacet (facetConfig "associated-place") cfg.facetMsgConfig

        role =
            viewFacet (facetConfig "roles") cfg.facetMsgConfig

        profession =
            viewFacet (facetConfig "profession") cfg.facetMsgConfig
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
                (.alias personFacetPanels.biographicalInfoPanel)
                (.label personFacetPanels.biographicalInfoPanel)
                cfg
                [ dates
                , gender
                , places
                ]
            , viewFacetsControlPanel
                (.alias personFacetPanels.roleAndProfession)
                (.label personFacetPanels.roleAndProfession)
                cfg
                [ role
                , profession
                ]
            ]
        ]
