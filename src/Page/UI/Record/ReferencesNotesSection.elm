module Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)

import Element exposing (Element, alignTop, column, el, fill, height, link, row, spacing, text, width)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (LiturgicalFestivalsSectionBody, PerformanceLocationsSectionBody, ReferencesNotesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewLiturgicalFestival : Language -> LiturgicalFestivalBody -> Element msg
viewLiturgicalFestival language festival =
    row
        [ width fill ]
        [ el
            [ width fill ]
            (extractLabelFromLanguageMap language festival.label |> text)
        ]


viewLiturgicalFestivalsSection :
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
    -> LiturgicalFestivalsSectionBody
    -> Element msg
viewLiturgicalFestivalsSection { language, preRenderedFormatter } body =
    preRenderedFormatter language
        [ { label = body.label
          , value = List.map (viewLiturgicalFestival language) body.items
          }
        ]


viewLocation : Language -> RelatedToBody -> Element msg
viewLocation language body =
    row
        [ width fill ]
        [ link
            [ linkColour ]
            { label = extractLabelFromLanguageMap language body.label |> text
            , url = body.id
            }
        ]


viewPerformanceLocation : Language -> RelationshipBody -> Element msg
viewPerformanceLocation language location =
    viewMaybe (viewLocation language) location.relatedTo


viewPerformanceLocationsSection :
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
    -> PerformanceLocationsSectionBody
    -> Element msg
viewPerformanceLocationsSection { language, preRenderedFormatter } body =
    preRenderedFormatter language
        [ { label = body.label
          , value = List.map (viewPerformanceLocation language) body.items
          }
        ]


viewReferencesNotesSection :
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
    }
    -> ReferencesNotesSectionBody
    -> Element msg
viewReferencesNotesSection { language, paragraphFormatter, preRenderedFormatter } refNotesSection =
    sectionTemplate language
        refNotesSection
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
                [ viewMaybe (paragraphFormatter language) refNotesSection.notes
                , viewMaybe
                    (viewPerformanceLocationsSection
                        { language = language
                        , preRenderedFormatter = preRenderedFormatter
                        }
                    )
                    refNotesSection.performanceLocations
                , viewMaybe
                    (viewLiturgicalFestivalsSection
                        { language = language
                        , preRenderedFormatter = preRenderedFormatter
                        }
                    )
                    refNotesSection.liturgicalFestivals
                ]
            ]
        ]
