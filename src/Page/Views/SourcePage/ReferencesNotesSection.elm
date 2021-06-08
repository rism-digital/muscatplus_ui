module Page.Views.SourcePage.ReferencesNotesSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, link, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (FullSourceBody, LiturgicalFestivalsSectionBody, PerformanceLocationsSectionBody, ReferencesNotesSectionBody)
import Page.UI.Components exposing (h5, h6, viewParagraphField, viewSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.Views.Relationship exposing (viewRelationshipBody)


viewReferencesNotesRouter : FullSourceBody -> Language -> Element msg
viewReferencesNotesRouter body language =
    case body.referencesNotes of
        Just refNotesSection ->
            viewReferencesNotesSection refNotesSection language

        Nothing ->
            none


viewReferencesNotesSection : ReferencesNotesSectionBody -> Language -> Element msg
viewReferencesNotesSection refNotesSection language =
    let
        performanceLocations =
            case refNotesSection.performanceLocations of
                Just section ->
                    viewPerformanceLocationsSection section language

                Nothing ->
                    none

        liturgicalFestivals =
            case refNotesSection.liturgicalFestivals of
                Just section ->
                    viewLiturgicalFestivalsSection section language

                Nothing ->
                    none

        notesSection =
            case refNotesSection.notes of
                Just notes ->
                    viewNotesSection notes language

                Nothing ->
                    none
    in
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
            , notesSection
            , performanceLocations
            , liturgicalFestivals
            ]
        ]


viewNotesSection : List LabelValue -> Language -> Element msg
viewNotesSection notes language =
    row
        [ width fill
        , spacing 20
        , alignTop
        ]
        [ viewParagraphField language notes
        ]


viewPerformanceLocationsSection : PerformanceLocationsSectionBody -> Language -> Element msg
viewPerformanceLocationsSection body language =
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
                    (List.map (\l -> viewPerformanceLocation l language) body.items)
                ]
            ]
        ]


viewLiturgicalFestivalsSection : LiturgicalFestivalsSectionBody -> Language -> Element msg
viewLiturgicalFestivalsSection body language =
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
                    (List.map (\l -> viewLiturgicalFestival l language) body.items)
                ]
            ]
        ]


viewLiturgicalFestival : LiturgicalFestivalBody -> Language -> Element msg
viewLiturgicalFestival festival language =
    row
        [ width fill ]
        [ link
            [ Font.color colourScheme.lightBlue ]
            { url = festival.id
            , label = text (extractLabelFromLanguageMap language festival.label)
            }
        ]


viewPerformanceLocation : RelationshipBody -> Language -> Element msg
viewPerformanceLocation location language =
    let
        perfLocation =
            case location.relatedTo of
                Just relationship ->
                    row
                        [ width fill ]
                        [ link
                            [ Font.color colourScheme.lightBlue ]
                            { url = relationship.id
                            , label = text (extractLabelFromLanguageMap language relationship.label)
                            }
                        ]

                Nothing ->
                    none
    in
    perfLocation
