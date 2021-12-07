module Page.Record.Views.SourcePage.RelationshipsSection exposing (..)

import Element exposing (Element)
import Language exposing (Language)
import Page.Record.Views.Relationship exposing (viewRelationshipBody)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionBody =
            List.map (\t -> viewRelationshipBody language t) relSection.items
    in
    sectionTemplate language relSection sectionBody
