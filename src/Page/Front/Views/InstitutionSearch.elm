module Page.Front.Views.InstitutionSearch exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, padding, paragraph, row, scrollbarY, spacing, text, width)
import Element.Font as Font
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Front.Views.SearchControls exposing (viewFrontKeywordQueryInput, viewFrontSearchButtons)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.UI.Attributes exposing (headingHero, lineSpacing, sectionSpacing)
import Session exposing (Session)


institutionSearchPanelView : Session -> FrontPageModel -> FrontBody -> Element FrontMsg
institutionSearchPanelView session model body =
    let
        language =
            session.language

        msgs =
            { submitMsg = FrontMsg.UserTriggeredSearchSubmit
            , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
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
                    [ text "Institution authorities" ]
                ]
            , viewFrontKeywordQueryInput language msgs qText
            ]
        ]
