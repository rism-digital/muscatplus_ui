module Page.UI.Record.Previews.ExternalSource exposing (viewExternalSourcePreview)

import Element exposing (Element, above, alignLeft, alignRight, alignTop, centerY, column, el, fill, fillPortion, height, inFront, link, none, paddingXY, px, row, scrollbarY, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalInstitutionRecord, ExternalProject(..), ExternalSourceContents, ExternalSourceExemplar, ExternalSourceExemplarsSection, ExternalSourceExternalResource, ExternalSourceExternalResourcesSection, ExternalSourceRecord, ExternalSourceReferencesNotesSection)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing, valueFieldColumnAttributes)
import Page.UI.CantusLogo exposing (cantusLogo)
import Page.UI.Components exposing (externalLinkTemplate, h2, renderLabel, renderParagraph, resourceLink, viewParagraphField, viewSummaryField)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (bookSvg, institutionSvg)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplateNoToc)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewExternalSourcePreview : Language -> ExternalProject -> ExternalSourceRecord -> Element msg
viewExternalSourcePreview language project body =
    let
        recordIcon =
            el
                [ width (px 25)
                , height (px 25)
                , centerY
                ]
                (bookSvg colourScheme.darkBlue)

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

                Cantus ->
                    el
                        [ width (px 175) ]
                        cantusLogo

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
                    , viewMaybe (viewExternalSourceExternalResourcesSection language) body.externalResources
                    ]
                ]
            ]
        ]


viewExternalSourceContentsSection : Language -> ExternalSourceContents -> Element msg
viewExternalSourceContentsSection language body =
    let
        sectionTmpl =
            sectionTemplate language body
    in
    sectionTmpl
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
            (institutionSvg colourScheme.midGrey)
        , link
            [ linkColour
            ]
            { label = h2 language body.label
            , url = body.id
            }
        ]


viewExternalSourceReferencesNotesSection : Language -> ExternalSourceReferencesNotesSection -> Element msg
viewExternalSourceReferencesNotesSection language body =
    let
        sectionTmpl =
            sectionTemplate language body
    in
    sectionTmpl
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


viewExternalNotesSection : Language -> List LabelValue -> Element msg
viewExternalNotesSection language notes =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ viewParagraphField language notes
        ]


viewExternalSourceExternalResourcesSection : Language -> ExternalSourceExternalResourcesSection -> Element msg
viewExternalSourceExternalResourcesSection language linkSection =
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            labelFieldColumnAttributes
            [ renderLabel language linkSection.label ]
        , column
            valueFieldColumnAttributes
            [ textColumn
                [ spacing lineSpacing ]
                (List.map (viewExternalResource language) linkSection.items)
            ]
        ]


viewExternalResource : Language -> ExternalSourceExternalResource -> Element msg
viewExternalResource language body =
    wrappedRow
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                ]
                [ column
                    [ width fill
                    , spacing 5
                    ]
                    [ row
                        [ width fill
                        , alignLeft
                        , spacing 5
                        ]
                        [ resourceLink body.url
                            [ linkColour ]
                            { label = renderParagraph language body.label
                            , url = body.url
                            }
                        , externalLinkTemplate body.url
                        ]
                    ]
                ]
            ]
        ]
