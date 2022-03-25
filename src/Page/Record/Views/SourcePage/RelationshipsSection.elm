module Page.Record.Views.SourcePage.RelationshipsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.Record.Views.Relationship exposing (viewRelationshipBody)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
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
                    (List.map (\t -> viewRelationshipBody language t) relSection.items)
                ]
            ]
    in
    sectionTemplate language relSection sectionBody
