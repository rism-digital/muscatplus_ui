module Page.UI.Record.Previews.ExternalPerson exposing (..)

import Element exposing (Element, alignRight, alignTop, column, el, fill, fillPortion, height, inFront, none, paddingXY, px, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.ExternalRecord exposing (ExternalPersonRecord, ExternalProject(..))
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplateNoToc)


viewExternalPersonPreview : Language -> ExternalProject -> ExternalPersonRecord -> Element msg
viewExternalPersonPreview language project body =
    let
        pageBodyView =
            row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    ]
                    []
                ]

        projectLogo =
            case project of
                DIAMM ->
                    el
                        [ width (px 175)
                        ]
                        diammLogo

                _ ->
                    none
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 20 10
        , scrollbarY
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            ]
            [ row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width (fillPortion 3)
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ pageHeaderTemplateNoToc language body
                    , pageFullRecordTemplate language body
                    ]
                , column
                    [ inFront projectLogo
                    , alignRight
                    , width (fillPortion 1)
                    , height fill
                    ]
                    []
                ]
            , pageBodyView
            ]
        ]
