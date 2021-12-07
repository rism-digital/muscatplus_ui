module Page.Record.Views.SourcePage.ContentsSection exposing (..)

import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, link, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Record.Views.Relationship exposing (viewRelationshipBody)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Source exposing (ContentsSectionBody, Subject, SubjectsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, sectionSpacing, valueFieldColumnAttributes, widthFillHeightFill)
import Page.UI.Components exposing (fieldValueWrapper, label, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


viewContentsSection : Language -> ContentsSectionBody -> Element msg
viewContentsSection language contents =
    let
        sectionBody =
            [ row
                (List.append widthFillHeightFill sectionBorderStyles)
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
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
            widthFillHeightFill
            [ column
                labelFieldColumnAttributes
                [ label language subjectSection.label ]
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
