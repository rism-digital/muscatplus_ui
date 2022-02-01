module Page.Front.Views.IncipitSearch exposing (..)

import Element exposing (Element, alignTop, column, fill, paragraph, row, spacing, text, width)
import Element.Font as Font
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Front.Views.Facets exposing (viewFrontFacet)
import Page.Front.Views.SearchControls exposing (viewFrontKeywordQueryInput, viewFrontSearchButtons)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.UI.Attributes exposing (headingHero, lineSpacing, sectionSpacing)
import Session exposing (Session)


incipitSearchPanelView : Session -> FrontPageModel -> FrontBody -> Element FrontMsg
incipitSearchPanelView session model body =
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
        [ width fill
        , alignTop
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
                    [ text "Incipit records" ]
                ]
            , viewFrontFacet "notation" language model.activeSearch body
            , viewFrontSearchButtons language model
            ]
        ]
