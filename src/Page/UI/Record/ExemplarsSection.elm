module Page.UI.Record.ExemplarsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, link, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourcesSectionBody)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (ExemplarBody, ExemplarsSectionBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewExemplarsSection : Language -> ExemplarsSectionBody -> Element msg
viewExemplarsSection language exemplarSection =
    List.map (\l -> viewExemplar language l) exemplarSection.items
        |> sectionTemplate language exemplarSection


viewExemplar : Language -> ExemplarBody -> Element msg
viewExemplar language exemplar =
    let
        heldBy =
            fieldValueWrapper
                [ wrappedRow
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ column
                        labelFieldColumnAttributes
                        [ renderLabel language exemplar.label ]
                    , column
                        valueFieldColumnAttributes
                        [ textColumn
                            [ spacing lineSpacing ]
                            [ viewHeldBy language exemplar.heldBy ]
                        ]
                    ]
                ]
    in
    row
        ([ width fill
         , height fill
         , alignTop
         , spacing lineSpacing
         ]
            ++ sectionBorderStyles
        )
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            [ heldBy
            , viewMaybe (viewSummaryField language) exemplar.summary
            , viewMaybe (viewParagraphField language) exemplar.notes
            , viewMaybe (viewExternalResourcesSection language) exemplar.externalResources
            , viewMaybe (viewExemplarRelationships language) exemplar.relationships
            ]
        ]


viewHeldBy : Language -> BasicInstitutionBody -> Element msg
viewHeldBy language body =
    link
        [ linkColour
        ]
        { url = body.id
        , label = text (extractLabelFromLanguageMap language body.label)
        }


viewExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExternalResourcesSection language linkSection =
    fieldValueWrapper
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language linkSection.label ]
            , column
                valueFieldColumnAttributes
                [ textColumn
                    [ spacing lineSpacing ]
                    (List.map (\l -> viewExternalResource language l) linkSection.items)
                ]
            ]
        ]


viewExternalResource : Language -> ExternalResourceBody -> Element msg
viewExternalResource language extLink =
    link
        [ linkColour ]
        { url = extLink.url
        , label = text (extractLabelFromLanguageMap language extLink.label)
        }


viewExemplarRelationships : Language -> RelationshipsSectionBody -> Element msg
viewExemplarRelationships language body =
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
            (List.map (\l -> viewRelationshipBody language l) body.items)
        ]
