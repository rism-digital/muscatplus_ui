module Page.UI.Record.Previews.ExternalPerson exposing (viewExternalPersonPreview)

import Element exposing (Element, alignRight, alignTop, centerY, column, el, fill, fillPortion, height, htmlAttribute, inFront, none, paddingXY, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Page.RecordTypes.ExternalRecord exposing (ExternalPersonRecord, ExternalProject(..))
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplateNoToc)
import Page.UI.Record.Previews.ExternalShared exposing (viewExternalRelationshipsSection)
import Page.UI.Style exposing (colourScheme)


viewExternalPersonPreview : Language -> ExternalProject -> ExternalPersonRecord -> Element msg
viewExternalPersonPreview language project body =
    let
        recordIcon =
            el
                [ width (px 25)
                , height (px 25)
                , centerY
                ]
                (peopleSvg colourScheme.darkBlue)

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
                    [ viewMaybe (viewBiographicalDetailsSection language) body.biographicalDetails
                    , viewMaybe (viewExternalRelationshipsSection language) body.relationships
                    ]
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
        , htmlAttribute (HA.style "min-height" "unset")
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
                    [ pageHeaderTemplateNoToc language (Just recordIcon) body
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
