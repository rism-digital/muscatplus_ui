module Page.UI.Record.Previews.ExternalSource exposing (..)

import Element exposing (Element, above, alignRight, alignTop, column, el, fill, fillPortion, height, inFront, link, newTabLink, none, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalInstitutionRecord, ExternalProject(..), ExternalSourceContents, ExternalSourceExemplar, ExternalSourceExemplarsSection, ExternalSourceRecord, ExternalSourceReferencesNotesSection)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (headingLG, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (viewParagraphField, viewSummaryField)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (institutionSvg)
import Page.UI.Record.PageTemplate exposing (externalLinkTemplate, pageFullRecordTemplate, pageHeaderTemplateNoToc)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewExternalSourcePreview : Language -> ExternalProject -> ExternalSourceRecord -> Element msg
viewExternalSourcePreview language project body =
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
                    [ viewMaybe (viewExternalSourceContentsSection language) body.contents
                    , viewMaybe (viewExternalSourceReferencesNotesSection language) body.referencesNotes
                    , viewMaybe (viewExternalSourceExemplarsSection language) body.exemplars
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


viewExternalSourceExemplarsSection : Language -> ExternalSourceExemplarsSection -> Element msg
viewExternalSourceExemplarsSection language body =
    List.map (viewExternalSourceExemplar language) body.items
        |> sectionTemplate language body


viewExternalSourceExemplar : Language -> ExternalSourceExemplar -> Element msg
viewExternalSourceExemplar language body =
    row
        (width fill
            :: height fill
            :: alignTop
            :: spacing lineSpacing
            :: sectionBorderStyles
        )
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , spacing 5
                ]
                [ viewExternalHeldBy language body.heldBy ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ viewMaybe (viewSummaryField language) body.summary

                    --, viewMaybe (viewParagraphField language) body.notes
                    --, viewMaybe (viewExternalResourcesSection language) exemplar.externalResources
                    --, viewMaybe (viewExemplarRelationships language) exemplar.relationships
                    --, viewMaybe (viewBoundWithSection language) exemplar.boundWith
                    ]
                ]
            ]
        ]


viewExternalSourceContentsSection : Language -> ExternalSourceContents -> Element msg
viewExternalSourceContentsSection language body =
    let
        sectionBody =
            [ row
                (width fill
                    :: height fill
                    :: alignTop
                    :: sectionBorderStyles
                )
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ Maybe.withDefault [] body.summary
                        |> viewSummaryField language
                    ]
                ]
            ]
    in
    sectionTemplate language body sectionBody


viewExternalHeldBy : Language -> ExternalInstitutionRecord -> Element msg
viewExternalHeldBy language body =
    row
        [ width fill
        , spacing 5
        ]
        [ el
            [ width (px 20)
            , height (px 20)
            , tooltip above
                (el
                    tooltipStyle
                    (text (extractLabelFromLanguageMap language localTranslations.heldBy))
                )
            ]
            (institutionSvg colourScheme.slateGrey)
        , newTabLink
            [ linkColour
            , headingLG
            , Font.medium
            ]
            { label = text (extractLabelFromLanguageMap language body.label)
            , url = body.id
            }
        , externalLinkTemplate body.id
        ]


viewExternalSourceReferencesNotesSection : Language -> ExternalSourceReferencesNotesSection -> Element msg
viewExternalSourceReferencesNotesSection language body =
    let
        sectionBody =
            [ row
                (List.append
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    sectionBorderStyles
                )
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewMaybe (viewExternalNotesSection language) body.notes
                    ]
                ]
            ]
    in
    sectionTemplate language body sectionBody


viewExternalNotesSection : Language -> List LabelValue -> Element msg
viewExternalNotesSection language notes =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ viewParagraphField language notes
        ]
