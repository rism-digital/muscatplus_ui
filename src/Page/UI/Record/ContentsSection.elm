module Page.UI.Record.ContentsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, link, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, Subject, SubjectsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewMinimalContentsSection : Language -> ContentsSectionBody -> Element msg
viewMinimalContentsSection language contents =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            [ viewMaybe (viewRelationshipBody language) contents.creator
            , Maybe.withDefault [] contents.summary
                |> viewSummaryField language
            ]
        ]


viewContentsSection : Language -> ContentsSectionBody -> Element msg
viewContentsSection language contents =
    let
        sectionBody =
            [ row
                ([ width fill
                 , height fill
                 , alignTop
                 ]
                    ++ sectionBorderStyles
                )
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewMaybe (viewRelationshipBody language) contents.creator
                    , Maybe.withDefault [] contents.summary
                        |> viewSummaryField language
                    , viewMaybe (viewSubjectsSection language) contents.subjects
                    ]
                ]
            ]
    in
    sectionTemplate language contents sectionBody


viewSubjectsSection : Language -> SubjectsSectionBody -> Element msg
viewSubjectsSection language subjectSection =
    fieldValueWrapper
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language subjectSection.label ]
            , column
                valueFieldColumnAttributes
                [ textColumn
                    [ spacing lineSpacing ]
                    (List.map (\l -> viewSubject language l) subjectSection.items)
                ]
            ]
        ]


viewSubject : Language -> Subject -> Element msg
viewSubject language subject =
    link
        [ linkColour ]
        { url = subject.id
        , label = text (extractLabelFromLanguageMap language subject.term)
        }
