module Page.UI.Record.Previews.ExternalInstitution exposing (viewExternalInstitutionPreview)

import Element exposing (Element, alignRight, alignTop, column, el, fill, fillPortion, height, inFront, none, paddingXY, px, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.ExternalRecord exposing (ExternalInstitutionRecord, ExternalProject(..))
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplateNoToc)


viewExternalInstitutionPreview : Language -> ExternalProject -> ExternalInstitutionRecord -> Element msg
viewExternalInstitutionPreview language project body =
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
