module Page.UI.Record.Previews.ExternalSource exposing (viewExternalSourcePreview)

import Element exposing (Element, above, alignLeft, alignRight, alignTop, centerY, column, el, fill, fillPortion, height, htmlAttribute, inFront, link, none, paddingXY, paragraph, px, row, scrollbarY, spacing, text, width, wrappedRow)
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalInstitutionRecord, ExternalProject(..), ExternalSourceContents, ExternalSourceExemplar, ExternalSourceExemplarsSection, ExternalSourceExternalResource, ExternalSourceExternalResourcesSection, ExternalSourceRecord, ExternalSourceReferencesNotesSection)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.CantusLogo exposing (cantusLogo)
import Page.UI.Components exposing (externalLinkTemplate, h2, resourceLink)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (bookSvg, institutionSvg)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplateNoToc)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewExternalSourcePreview :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter :
        Language
        ->
            List
                { label : LanguageMap
                , value : List (Element msg)
                }
        -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ExternalProject
    -> ExternalSourceRecord
    -> Element msg
viewExternalSourcePreview { language, paragraphFormatter, preRenderedFormatter, summaryFormatter } project body =
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
                    [ viewMaybe
                        (viewExternalSourceContentsSection
                            { language = language
                            , summaryFormatter = summaryFormatter
                            }
                        )
                        body.contents
                    , viewMaybe
                        (viewExternalSourceReferencesNotesSection
                            { language = language
                            , paragraphFormatter = paragraphFormatter
                            }
                        )
                        body.referencesNotes
                    , viewMaybe
                        (viewExternalSourceExemplarsSection
                            { language = language
                            , preRenderedFormatter = preRenderedFormatter
                            , summaryFormatter = summaryFormatter
                            }
                        )
                        body.exemplars
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


viewExternalSourceExemplarsSection :
    { language : Language
    , preRenderedFormatter :
        Language
        ->
            List
                { label : LanguageMap
                , value : List (Element msg)
                }
        -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ExternalSourceExemplarsSection
    -> Element msg
viewExternalSourceExemplarsSection { language, preRenderedFormatter, summaryFormatter } body =
    List.map
        (viewExternalSourceExemplar
            { language = language
            , preRenderedFormatter = preRenderedFormatter
            , summaryFormatter = summaryFormatter
            }
        )
        body.items
        |> sectionTemplate language body


viewExternalSourceExemplar :
    { language : Language
    , preRenderedFormatter :
        Language
        ->
            List
                { label : LanguageMap
                , value : List (Element msg)
                }
        -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ExternalSourceExemplar
    -> Element msg
viewExternalSourceExemplar { language, preRenderedFormatter, summaryFormatter } body =
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
                    [ viewMaybe (summaryFormatter language) body.summary
                    , viewMaybe
                        (viewExternalSourceExternalResourcesSection
                            { language = language
                            , preRenderedFormatter = preRenderedFormatter
                            }
                        )
                        body.externalResources
                    ]
                ]
            ]
        ]


viewExternalSourceContentsSection :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ExternalSourceContents
    -> Element msg
viewExternalSourceContentsSection { language, summaryFormatter } body =
    sectionTemplate language
        body
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
                    |> summaryFormatter language
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
            { url = body.id
            , label = h2 language body.label
            }
        ]


viewExternalSourceReferencesNotesSection :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    }
    -> ExternalSourceReferencesNotesSection
    -> Element msg
viewExternalSourceReferencesNotesSection { language, paragraphFormatter } body =
    sectionTemplate language
        body
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
                [ viewMaybe
                    (viewExternalNotesSection
                        { language = language
                        , paragraphFormatter = paragraphFormatter
                        }
                    )
                    body.notes
                ]
            ]
        ]


viewExternalNotesSection :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    }
    -> List LabelValue
    -> Element msg
viewExternalNotesSection { language, paragraphFormatter } notes =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ paragraphFormatter language notes
        ]


viewExternalSourceExternalResourcesSection :
    { language : Language
    , preRenderedFormatter :
        Language
        ->
            List
                { label : LanguageMap
                , value : List (Element msg)
                }
        -> Element msg
    }
    -> ExternalSourceExternalResourcesSection
    -> Element msg
viewExternalSourceExternalResourcesSection { language, preRenderedFormatter } body =
    preRenderedFormatter language
        [ { label = body.label
          , value = List.map (viewExternalResource language) body.items
          }
        ]



--wrappedRow
--[ width fill
--, height fill
--, alignTop
--]
--[ column
--    labelFieldColumnAttributes
--    [ renderLabel language linkSection.label ]
--, column
--    valueFieldColumnAttributes
--    [ textColumn
--        [ spacing lineSpacing ]
--        (List.map (viewExternalResource language) linkSection.items)
--    ]
--]


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
                            { url = body.url
                            , label = paragraph [] [ text (extractLabelFromLanguageMap language body.label) ]
                            }
                        , externalLinkTemplate body.url
                        ]
                    ]
                ]
            ]
        ]
