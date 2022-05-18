module Page.UI.Record.ReferencesNotesSection exposing (..)

import Element exposing (Element, alignTop, column, el, fill, height, link, row, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (LiturgicalFestivalsSectionBody, PerformanceLocationsSectionBody, ReferencesNotesSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel, viewParagraphField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewReferencesNotesSection : Language -> ReferencesNotesSectionBody -> Element msg
viewReferencesNotesSection language refNotesSection =
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
                    [ viewMaybe (viewNotesSection language) refNotesSection.notes
                    , viewMaybe (viewPerformanceLocationsSection language) refNotesSection.performanceLocations
                    , viewMaybe (viewLiturgicalFestivalsSection language) refNotesSection.liturgicalFestivals
                    ]
                ]
            ]
    in
    sectionTemplate language refNotesSection sectionBody


viewNotesSection : Language -> List LabelValue -> Element msg
viewNotesSection language notes =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ viewParagraphField language notes
        ]


viewPerformanceLocationsSection : Language -> PerformanceLocationsSectionBody -> Element msg
viewPerformanceLocationsSection language body =
    fieldValueWrapper <|
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language body.label ]
            , column
                valueFieldColumnAttributes
                (List.map (\l -> viewPerformanceLocation language l) body.items)
            ]
        ]


viewLiturgicalFestivalsSection : Language -> LiturgicalFestivalsSectionBody -> Element msg
viewLiturgicalFestivalsSection language body =
    fieldValueWrapper <|
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language body.label ]
            , column
                valueFieldColumnAttributes
                (List.map (\l -> viewLiturgicalFestival language l) body.items)
            ]
        ]


viewLiturgicalFestival : Language -> LiturgicalFestivalBody -> Element msg
viewLiturgicalFestival language festival =
    row
        [ width fill ]
        [ el
            [ width fill ]
            (text <| extractLabelFromLanguageMap language festival.label)
        ]


viewPerformanceLocation : Language -> RelationshipBody -> Element msg
viewPerformanceLocation language location =
    viewMaybe (viewLocation language) location.relatedTo


viewLocation : Language -> RelatedToBody -> Element msg
viewLocation language body =
    row
        [ width fill ]
        [ link
            [ linkColour ]
            { url = body.id
            , label = text (extractLabelFromLanguageMap language body.label)
            }
        ]
