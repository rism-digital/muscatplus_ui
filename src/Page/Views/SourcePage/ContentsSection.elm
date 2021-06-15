module Page.Views.SourcePage.ContentsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, link, paddingXY, row, spacing, text, width)
import Html.Attributes as HTA
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.RecordTypes.Source exposing (ContentsSectionBody, Subject, SubjectsSectionBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h5, h6, viewSummaryField)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Relationship exposing (viewRelationshipBody)


viewContentsSection : Language -> ContentsSectionBody -> Element Msg
viewContentsSection language contents =
    row
        [ width fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , spacing 10
            ]
            [ row
                [ width fill
                , htmlAttribute (HTA.id contents.sectionToc)
                ]
                [ h5 language contents.label ]
            , viewMaybe (viewRelationshipBody language) contents.creator
            , Maybe.withDefault [] contents.summary
                |> viewSummaryField language
            , viewMaybe (viewSubjectsSection language) contents.subjects
            ]
        ]


viewSubjectsSection : Language -> SubjectsSectionBody -> Element Msg
viewSubjectsSection language subjectSection =
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
                [ width fill ]
                [ h6 language subjectSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                (List.map (\l -> viewSubject language l) subjectSection.items)
            ]
        ]


viewSubject : Language -> Subject -> Element msg
viewSubject language subject =
    row
        [ width fill ]
        [ link
            [ linkColour ]
            { url = subject.id
            , label = text (extractLabelFromLanguageMap language subject.term)
            }
        ]
