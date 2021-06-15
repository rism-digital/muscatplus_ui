module Page.Views.SourcePage.ReferencesNotesSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, link, paddingXY, row, spacing, text, width)
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody)
import Page.RecordTypes.Relationship exposing (RelatedToBody, RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (LiturgicalFestivalsSectionBody, PerformanceLocationsSectionBody, ReferencesNotesSectionBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h5, h6, viewParagraphField)
import Page.Views.Helpers exposing (viewMaybe)


viewReferencesNotesSection : Language -> ReferencesNotesSectionBody -> Element msg
viewReferencesNotesSection language refNotesSection =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            , alignTop
            ]
            [ row
                [ width fill
                , htmlAttribute (HTA.id refNotesSection.sectionToc)
                ]
                [ h5 language refNotesSection.label ]
            , viewMaybe (viewNotesSection language) refNotesSection.notes
            , viewMaybe (viewPerformanceLocationsSection language) refNotesSection.performanceLocations
            , viewMaybe (viewLiturgicalFestivalsSection language) refNotesSection.liturgicalFestivals
            ]
        ]


viewNotesSection : Language -> List LabelValue -> Element msg
viewNotesSection language notes =
    row
        [ width fill
        , spacing 20
        , alignTop
        ]
        [ viewParagraphField language notes
        ]


viewPerformanceLocationsSection : Language -> PerformanceLocationsSectionBody -> Element msg
viewPerformanceLocationsSection language body =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , paddingXY 0 10
                ]
                [ h6 language body.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\l -> viewPerformanceLocation language l) body.items)
                ]
            ]
        ]


viewLiturgicalFestivalsSection : Language -> LiturgicalFestivalsSectionBody -> Element msg
viewLiturgicalFestivalsSection language body =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , paddingXY 0 10
                ]
                [ h6 language body.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing 20
                    ]
                    (List.map (\l -> viewLiturgicalFestival language l) body.items)
                ]
            ]
        ]


viewLiturgicalFestival : Language -> LiturgicalFestivalBody -> Element msg
viewLiturgicalFestival language festival =
    row
        [ width fill ]
        [ link
            [ linkColour ]
            { url = festival.id
            , label = text (extractLabelFromLanguageMap language festival.label)
            }
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
