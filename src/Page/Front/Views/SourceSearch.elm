module Page.Front.Views.SourceSearch exposing (sourceSearchPanelView)

import Element exposing (Element, alignTop, column, fill, height, padding, paragraph, row, scrollbarY, spacing, text, width)
import Element.Font as Font
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Front.Views.Facets exposing (facetFrontMsgConfig)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.UI.Attributes exposing (headingHero, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.KeywordQuery exposing (viewFrontKeywordQueryInput)
import Session exposing (Session)


sourceSearchPanelView : Session -> FrontPageModel FrontMsg -> FrontBody -> Element FrontMsg
sourceSearchPanelView session model frontBody =
    let
        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = model.activeSearch
            , selectColumns = 4
            , body = frontBody
            }

        language =
            session.language

        activeSearch =
            model.activeSearch

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""
    in
    row
        [ padding 10
        , scrollbarY
        , width fill
        , alignTop
        , height fill
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            ]
            [ row
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ paragraph
                    [ headingHero, Font.semiBold ]
                    [ text (extractLabelFromLanguageMap language localTranslations.sources) ]
                ]
            , viewFrontKeywordQueryInput
                { language = language
                , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                , queryText = qText
                }
            , row
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    [ viewFacet (facetConfig "composer") facetFrontMsgConfig ]
                , column
                    [ width fill
                    , alignTop
                    ]
                    [ viewFacet (facetConfig "people") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "date-range") facetFrontMsgConfig ]
                ]
            , row
                [ width fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewFacet (facetConfig "hide-source-contents") facetFrontMsgConfig
                    , viewFacet (facetConfig "hide-source-collections") facetFrontMsgConfig
                    , viewFacet (facetConfig "hide-composite-volumes") facetFrontMsgConfig
                    ]
                , column
                    [ width fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewFacet (facetConfig "has-digitization") facetFrontMsgConfig
                    , viewFacet (facetConfig "has-iiif") facetFrontMsgConfig
                    ]
                , column
                    [ width fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewFacet (facetConfig "is-arrangement") facetFrontMsgConfig
                    , viewFacet (facetConfig "has-incipits") facetFrontMsgConfig
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    ]
                    [ viewFacet (facetConfig "record-type") facetFrontMsgConfig
                    , viewFacet (facetConfig "content-types") facetFrontMsgConfig
                    , viewFacet (facetConfig "material-types") facetFrontMsgConfig
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    ]
                    [ viewFacet (facetConfig "text-language") facetFrontMsgConfig
                    , viewFacet (facetConfig "format-extent") facetFrontMsgConfig
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "subjects") facetFrontMsgConfig
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "scoring") facetFrontMsgConfig
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "sigla") facetFrontMsgConfig
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "related-institutions") facetFrontMsgConfig
                    ]
                ]
            ]
        ]
