module Page.Record.Views.SourcePage.MaterialGroupsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.Record.Views.Relationship exposing (viewRelationshipBody)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (MaterialGroupBody, MaterialGroupsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


viewMaterialGroupsSection : Language -> MaterialGroupsSectionBody -> Element msg
viewMaterialGroupsSection language mgSection =
    let
        sectionBody =
            List.map (\l -> viewMaterialGroup language l) mgSection.items
    in
    sectionTemplate language mgSection sectionBody


viewMaterialGroup : Language -> MaterialGroupBody -> Element msg
viewMaterialGroup language mg =
    row
        (List.append
            [ width fill
            , height fill
            , alignTop
            ]
            sectionBorderStyles
        )
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing sectionSpacing
            ]
            [ viewMaybe (viewSummaryField language) mg.summary
            , viewMaybe (viewParagraphField language) mg.notes
            , viewMaybe (viewMaterialGroupRelationships language) mg.relationships
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
