module Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)

import Element exposing (Element, alignTop, column, el, fill, height, row, spacing, text, textColumn, width, wrappedRow)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.ExternalResource exposing (ExternalResourcesSectionBody)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (MaterialGroupBody, MaterialGroupsSectionBody)
import Page.UI.Attributes exposing (headingLG, headingMD, labelFieldColumnAttributes, lineSpacing, sectionBorderStyles, sectionSpacing, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalResources exposing (viewExternalResource)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


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


viewMaterialGroup : Language -> MaterialGroupBody -> Element msg
viewMaterialGroup language mg =
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , spacing 5
                ]
                [ el
                    [ headingLG
                    , Font.medium
                    ]
                    (text (extractLabelFromLanguageMap language mg.label))
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    , height fill
                    , alignTop
                    ]
                    [ viewMaybe (viewSummaryField language) mg.summary
                    , viewMaybe (viewParagraphField language) mg.notes
                    , viewMaybe (viewMaterialGroupRelationships language) mg.relationships
                    , viewMaybe (viewExternalResourcesSection language) mg.externalResources
                    ]
                ]
            ]
        ]


viewMaterialGroupRelationships : Language -> RelationshipsSectionBody -> Element msg
viewMaterialGroupRelationships language relSection =
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
            (List.map (\t -> viewRelationshipBody language t) relSection.items)
        ]


viewMaterialGroupsSection : Language -> MaterialGroupsSectionBody -> Element msg
viewMaterialGroupsSection language mgSection =
    let
        sectionBody =
            List.map (\l -> viewMaterialGroup language l) mgSection.items
    in
    sectionTemplate language mgSection sectionBody
