module Page.Record.Views.SourcePage.MaterialGroupsSection exposing (..)

import Element exposing (Element, column, row)
import Language exposing (Language)
import Page.Record.Views.Relationship exposing (viewRelationshipBody)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (MaterialGroupBody, MaterialGroupsSectionBody)
import Page.UI.Attributes exposing (sectionBorderStyles, widthFillHeightFill)
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
        (List.append widthFillHeightFill sectionBorderStyles)
        [ column
            widthFillHeightFill
            [ viewMaybe (viewSummaryField language) mg.summary
            , viewMaybe (viewParagraphField language) mg.notes
            , viewMaybe (viewMaterialGroupRelationships language) mg.relationships
            ]
        ]


viewMaterialGroupRelationships : Language -> RelationshipsSectionBody -> Element msg
viewMaterialGroupRelationships language relSection =
    row
        widthFillHeightFill
        [ column
            widthFillHeightFill
            (List.map (\t -> viewRelationshipBody language t) relSection.items)
        ]
