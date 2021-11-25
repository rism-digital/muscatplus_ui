module Page.Record.Views.SourcePage.RelationshipsSection exposing (..)

import Element exposing (Element)
import Language exposing (Language)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.UI.Relationship exposing (viewRelationshipBody)
import Page.UI.SectionTemplate exposing (sectionTemplate)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
    let
        sectionBody =
            List.map (\t -> viewRelationshipBody language t) relSection.items
    in
    sectionTemplate language relSection sectionBody
