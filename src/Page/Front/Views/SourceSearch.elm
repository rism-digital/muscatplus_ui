module Page.Front.Views.SourceSearch exposing (..)

import Element exposing (Element, alignTop, column, fill, paragraph, row, spacing, text, width)
import Element.Font as Font
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg(..))
import Page.Front.Views.Facets exposing (viewFrontFacet)
import Page.Front.Views.SearchControls exposing (viewFrontKeywordQueryInput, viewFrontSearchButtons)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.UI.Attributes exposing (headingHero, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Session exposing (Session)


sourceSearchPanelView : Session -> FrontPageModel -> FrontBody -> Element FrontMsg
sourceSearchPanelView session model frontBody =
    let
        activeSearch =
            model.activeSearch

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

        language =
            session.language

        msgs =
            { submitMsg = FrontMsg.UserTriggeredSearchSubmit
            , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
            }
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
                    [ text "Source records" ]
                ]
            , viewFrontKeywordQueryInput language msgs qText
            , viewFrontSearchButtons language model
            , row
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "composer" language activeSearch frontBody ]
                , column
                    [ width fill ]
                    [ viewFrontFacet "people" language activeSearch frontBody ]
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
                    [ viewFrontFacet "source-type" language activeSearch frontBody
                    , viewFrontFacet "content-types" language activeSearch frontBody
                    , viewFrontFacet "material-group-types" language activeSearch frontBody
                    ]
                ]
            ]
        ]
