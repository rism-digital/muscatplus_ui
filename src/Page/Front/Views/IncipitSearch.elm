module Page.Front.Views.IncipitSearch exposing (..)

import Element exposing (Element, alignTop, column, fill, paragraph, row, spacing, text, width)
import Element.Font as Font
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg)
import Page.Front.Views.Facets exposing (viewFrontFacet)
import Page.Front.Views.SearchControls exposing (viewFrontSearchButtons)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.Search.Views.Facets.KeywordQuery exposing (searchKeywordInput)
import Page.UI.Attributes exposing (headingHero, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Session exposing (Session)


incipitSearchPanelView : Session -> FrontPageModel -> FrontBody -> Element FrontMsg
incipitSearchPanelView session model body =
    let
        language =
            session.language

        qText =
            toNextQuery model.activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

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
                    [ text "Incipit records" ]
                ]
            , viewFrontFacet "notation" language model.activeSearch body
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
                    [ searchKeywordInput language msgs qText ]
                ]
            , row
                [ width fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    [ viewFrontFacet "composer" language model.activeSearch body
                    ]
                , column
                    [ width fill
                    , alignTop
                    ]
                    [ viewFrontFacet "date-range" language model.activeSearch body ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ viewFrontFacet "has-notation" language model.activeSearch body
                    , viewFrontFacet "is-mensural" language model.activeSearch body
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "clef" language model.activeSearch body ]
                ]
            ]
        ]
