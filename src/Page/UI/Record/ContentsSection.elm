module Page.UI.Record.ContentsSection exposing (viewContentsSection, viewMobileContentsSection)

import Element exposing (Element, alignTop, column, el, fill, height, none, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, Subject, SubjectsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (renderLabel, viewMobileSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (gatherRelationshipItems, viewMobileRelationshipBody, viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (mobileSectionTemplate, sectionTemplate)


viewCreatorImpl :
    (Language -> LanguageMap -> List RelationshipBody -> Element msg)
    -> Language
    -> Maybe RelationshipBody
    -> Element msg
viewCreatorImpl formatter language creator =
    Maybe.map
        (\rb ->
            gatherRelationshipItems [ rb ]
                |> List.map (\( label, items ) -> formatter language label items)
                |> List.head
                |> Maybe.withDefault none
        )
        creator
        |> Maybe.withDefault none


viewCreator : Language -> Maybe RelationshipBody -> Element msg
viewCreator language creator =
    viewCreatorImpl viewRelationshipBody language creator


viewMobileCreator : Language -> Maybe RelationshipBody -> Element msg
viewMobileCreator language creator =
    viewCreatorImpl viewMobileRelationshipBody language creator


viewContentsSection : Language -> Maybe RelationshipBody -> ContentsSectionBody -> Element msg
viewContentsSection language creator contents =
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
                [ viewCreator language creator
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


viewMobileContentsSection : Language -> Maybe RelationshipBody -> ContentsSectionBody -> Element msg
viewMobileContentsSection language creator contents =
    mobileSectionTemplate
        language
        contents
        [ row
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
                [ viewMobileCreator language creator
                , Maybe.withDefault [] contents.summary
                    |> viewMobileSummaryField language
                ]
            ]
        ]
