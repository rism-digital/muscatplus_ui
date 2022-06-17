module Page.Front.Views.IncipitSearch exposing (incipitSearchPanelView)

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
import Page.UI.Facets.KeywordQuery exposing (searchKeywordInput)
import Session exposing (Session)


incipitSearchPanelView : Session -> FrontPageModel FrontMsg -> FrontBody -> Element FrontMsg
incipitSearchPanelView session model body =
    let
        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = model.activeSearch
            , selectColumns = 4
            , body = body
            }

        language =
            session.language

        qText =
            toNextQuery model.activeSearch
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
                    [ text <| extractLabelFromLanguageMap language localTranslations.incipits ]
                ]
            , viewFacet (facetConfig "notation") facetFrontMsgConfig
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
                    [ searchKeywordInput
                        { language = language
                        , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                        , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                        , queryText = qText
                        }
                    ]
                ]
            , row
                [ width fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    [ viewFacet (facetConfig "composer") facetFrontMsgConfig
                    ]
                , column
                    [ width fill
                    , alignTop
                    ]
                    [ viewFacet (facetConfig "date-range") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ viewFacet (facetConfig "has-notation") facetFrontMsgConfig
                    , viewFacet (facetConfig "is-mensural") facetFrontMsgConfig
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "clef") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "key-signature") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "time-signature") facetFrontMsgConfig ]
                ]
            ]
        ]
