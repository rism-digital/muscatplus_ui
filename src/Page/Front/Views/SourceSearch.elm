module Page.Front.Views.SourceSearch exposing (..)

import Element exposing (Element, alignTop, column, fill, height, padding, paragraph, row, scrollbarY, spacing, text, width)
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
                    [ text "Source records" ]
                ]
            , viewFrontKeywordQueryInput language msgs qText
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
                    [ viewFrontFacet "composer" language activeSearch frontBody ]
                , column
                    [ width fill
                    , alignTop
                    ]
                    [ viewFrontFacet "people" language activeSearch frontBody ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "date-range" language activeSearch frontBody ]
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
                    [ viewFrontFacet "hide-source-contents" language activeSearch frontBody
                    , viewFrontFacet "hide-source-collections" language activeSearch frontBody
                    , viewFrontFacet "hide-composite-volumes" language activeSearch frontBody
                    ]
                , column
                    [ width fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewFrontFacet "has-digitization" language activeSearch frontBody ]
                , column
                    [ width fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewFrontFacet "is-arrangement" language activeSearch frontBody
                    , viewFrontFacet "has-incipits" language activeSearch frontBody
                    ]
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
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "text-language" language activeSearch frontBody
                    , viewFrontFacet "format-extent" language activeSearch frontBody
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "subjects" language activeSearch frontBody
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "scoring" language activeSearch frontBody
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "sigla" language activeSearch frontBody
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "related-institutions" language activeSearch frontBody
                    ]
                ]
            ]
        ]
