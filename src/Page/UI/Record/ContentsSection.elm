module Page.UI.Record.ContentsSection exposing (viewContentsSection)

import Element exposing (Element, alignTop, column, el, fill, height, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, Subject, SubjectsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewContentsSection : Language -> Maybe RelationshipBody -> ContentsSectionBody -> Element msg
viewContentsSection language creator contents =
    let
        sectionTmpl =
            sectionTemplate language contents
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
                [ viewMaybe (viewRelationshipBody language) creator
                , Maybe.withDefault [] contents.summary
                    |> viewSummaryField language
                , viewMaybe (viewSubjectsSection language) contents.subjects
                ]
            ]
        ]


viewSubject : Language -> Subject -> Element msg
viewSubject language subject =
    row
        [ width fill
        , spacing 5
        ]
        [ el
            [ width fill ]
            (text (extractLabelFromLanguageMap language subject.label))
        ]


viewSubjectsSection : Language -> SubjectsSectionBody -> Element msg
viewSubjectsSection language subjectSection =
    fieldValueWrapper []
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
                    (List.map (viewSubject language) subjectSection.items)
                ]
            ]
        ]
