module Page.Front.Views.PeopleSearch exposing (..)

import Element exposing (Element, alignTop, column, fill, height, padding, paragraph, row, scrollbarY, spacing, text, width)
import Element.Font as Font
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Front.Views.Facets exposing (viewFrontFacet)
import Page.Front.Views.SearchControls exposing (viewFrontKeywordQueryInput, viewFrontSearchButtons)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.UI.Attributes exposing (headingHero, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Session exposing (Session)


peopleSearchPanelView : Session -> FrontPageModel -> FrontBody -> Element FrontMsg
peopleSearchPanelView session model frontBody =
    let
        language =
            session.language

        activeSearch =
            model.activeSearch

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
                    [ text "Person authorities" ]
                ]
            , viewFrontKeywordQueryInput language msgs qText
            , row
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters" ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "person-role" language activeSearch frontBody ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "date-range" language activeSearch frontBody ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "associated-place" language activeSearch frontBody ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "gender" language activeSearch frontBody ]
                ]
            ]
        ]
