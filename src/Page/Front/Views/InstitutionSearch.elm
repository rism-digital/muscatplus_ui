module Page.Front.Views.InstitutionSearch exposing (institutionSearchPanelView)

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
import Page.UI.Facets.Facets exposing (viewFacet)
import Page.UI.Facets.KeywordQuery exposing (viewFrontKeywordQueryInput)
import Session exposing (Session)


institutionSearchPanelView : Session -> FrontPageModel FrontMsg -> FrontBody -> Element FrontMsg
institutionSearchPanelView session model frontBody =
    let
        activeSearch =
            model.activeSearch

        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , selectColumns = 4
            , body = frontBody
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
                    [ text <| extractLabelFromLanguageMap language localTranslations.institutions ]
                ]
            , viewFrontKeywordQueryInput
                { language = language
                , submitMsg = FrontMsg.UserTriggeredSearchSubmit
                , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
                , queryText = qText
                }
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "has-siglum") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "city") facetFrontMsgConfig ]
                ]
            ]
        ]
