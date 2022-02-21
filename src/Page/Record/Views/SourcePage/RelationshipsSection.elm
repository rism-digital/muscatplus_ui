module Page.Record.Views.SourcePage.RelationshipsSection exposing (..)

import Element exposing (Element, column, row, spacing)
import Language exposing (Language)
import Page.Record.Views.Relationship exposing (viewRelationshipBody)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, widthFillHeightFill)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionBody =
            [ row
                (List.concat [ widthFillHeightFill, sectionBorderStyles ])
                [ column
                    (List.concat [ widthFillHeightFill, [ spacing lineSpacing ] ])
                    (List.map (\t -> viewRelationshipBody language t) relSection.items)
                ]
            ]
    in
    sectionTemplate language relSection sectionBody
