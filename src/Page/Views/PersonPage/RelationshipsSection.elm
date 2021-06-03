module Page.Views.PersonPage.RelationshipsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, paddingXY, row, spacing, width)
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.UI.Components exposing (h5)
import Page.Views.Relationship exposing (viewRelationshipBody)


viewPersonRelationshipsRouter : PersonBody -> Language -> Element Msg
viewPersonRelationshipsRouter body language =
    case body.relationships of
        Just relationships ->
            viewPersonRelationshipsSection relationships language

        Nothing ->
            none


viewPersonRelationshipsSection : RelationshipsSectionBody -> Language -> Element Msg
viewPersonRelationshipsSection relSection language =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            , alignTop
            ]
            [ row
                [ width fill ]
                [ h5 language relSection.label ]
            , row
                [ width fill
                ]
                [ column
                    [ width fill
                    ]
                    (List.map (\t -> viewRelationshipBody t language) relSection.items)
                ]
            ]
        ]
