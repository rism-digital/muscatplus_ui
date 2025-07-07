module Page.UI.Record.ContentsSection exposing (viewContentsSection, viewCreator)

import Element exposing (Element, alignTop, column, fill, height, none, row, spacing, text, width)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, SubjectsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
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
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ContentsSectionBody
    -> Element msg
viewContentsSection { creator, language, preRenderedFormatter, relationshipFormatter, summaryFormatter } contents =
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
                , viewMaybe
                    (viewSubjectsSection
                        { language = language
                        , preRenderedFormatter = preRenderedFormatter
                        }
                    )
                    contents.subjects
                ]
            ]
        ]


viewSubjectsSection :
    { language : Language
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    }
    -> SubjectsSectionBody
    -> Element msg
viewSubjectsSection { language, preRenderedFormatter } subjectSection =
    preRenderedFormatter language
        [ { label = subjectSection.label
          , value = List.map (\it -> text (extractLabelFromLanguageMap language it.label)) subjectSection.items
          }
        ]
