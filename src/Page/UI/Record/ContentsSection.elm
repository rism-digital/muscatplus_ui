module Page.UI.Record.ContentsSection exposing (..)

import Dict
import Element exposing (Element, above, alignTop, centerY, column, el, fill, height, link, padding, px, row, spacing, text, textColumn, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Query exposing (buildQueryParameters, defaultQueryArgs, setFilters)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.SourceShared exposing (ContentsSectionBody, Subject, SubjectsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (searchSvg)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)
import Request exposing (serverUrl)


viewContentsSection : Language -> Maybe RelationshipBody -> ContentsSectionBody -> Element msg
viewContentsSection language creator contents =
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
                    [ viewMaybe (viewRelationshipBody language) creator
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
    let
        facetDict =
            Dict.fromList [ ( "subjects", [ subject.value ] ) ]

        searchQueryArgs =
            setFilters facetDict defaultQueryArgs
                |> buildQueryParameters

        subjectSearchUrl =
            serverUrl [ "search" ] searchQueryArgs
    in
    row
        [ width fill
        , spacing 5
        ]
        [ el
            []
            (text (extractLabelFromLanguageMap language subject.label))
        , link
            [ centerY
            , linkColour
            , Border.width 1
            , Border.color (colourScheme.lightBlue |> convertColorToElementColor)
            , padding 2
            , Background.color (colourScheme.lightBlue |> convertColorToElementColor)
            ]
            { url = subjectSearchUrl
            , label =
                el
                    [ width (px 12)
                    , height (px 12)
                    , centerY
                    , el tooltipStyle (text "New search with this term")
                        |> tooltip above
                    ]
                    (searchSvg colourScheme.white)
            }
        ]



--
--link
--    [ linkColour ]
--    { url = subject.id
--    , label =
--    }
