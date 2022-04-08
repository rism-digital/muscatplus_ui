module Page.Front.Views.PeopleSearch exposing (..)

import Element exposing (Element, alignTop, column, fill, height, padding, paragraph, row, scrollbarY, spacing, text, width)
import Element.Font as Font
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


peopleSearchPanelView : Session -> FrontPageModel FrontMsg -> FrontBody -> Element FrontMsg
peopleSearchPanelView session model frontBody =
    let
        language =
            session.language

        activeSearch =
            model.activeSearch

        facetConfig alias =
            { alias = alias
            , language = language
            , activeSearch = activeSearch
            , body = frontBody
            , selectColumns = 4
            }

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
                    [ text "Person authorities" ]
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
                [ dividerWithText "Additional filters" ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "roles") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "date-range") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "associated-place") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "gender") facetFrontMsgConfig ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFacet (facetConfig "profession") facetFrontMsgConfig ]
                ]
            ]
        ]
