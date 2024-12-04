module Page.UI.Record.ContentsSection exposing (viewContentsSection)

import Element exposing (Element, alignTop, column, el, fill, height, none, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, Subject, SubjectsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (renderLabel)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (gatherRelationshipItems)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewCreatorImpl :
    (Language -> LanguageMap -> List RelationshipBody -> Element msg)
    -> Language
    -> RelationshipBody
    -> Element msg
viewCreatorImpl formatter language creator =
    gatherRelationshipItems [ creator ]
        |> List.map (\( label, items ) -> formatter language label items)
        |> List.head
        |> Maybe.withDefault none


viewCreator :
    { language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    }
    -> RelationshipBody
    -> Element msg
viewCreator { language, relationshipFormatter } creator =
    viewCreatorImpl relationshipFormatter language creator


viewContentsSection :
    { creator : Maybe RelationshipBody
    , language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ContentsSectionBody
    -> Element msg
viewContentsSection { creator, language, relationshipFormatter, summaryFormatter } contents =
    sectionTemplate
        language
        contents
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
                [ viewMaybe
                    (viewCreator
                        { language = language
                        , relationshipFormatter = relationshipFormatter
                        }
                    )
                    creator
                , Maybe.withDefault [] contents.summary
                    |> summaryFormatter language
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
    wrappedRow
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
