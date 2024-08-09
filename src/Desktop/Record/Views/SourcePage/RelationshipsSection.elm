module Desktop.Record.Views.SourcePage.RelationshipsSection exposing (viewRelationshipsSection)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionTmpl =
            sectionTemplate language relSection
    in
    sectionTmpl
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
                (List.map (viewRelationshipBody language) relSection.items)
            ]
        ]
