module Page.Views.SourcePage.RelationshipsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, none, paddingXY, row, spacing, width)
import Html.Attributes as HTA
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Components exposing (h5)
import Page.Views.Relationship exposing (viewRelationshipBody)


viewRelationshipsSection : Language -> RelationshipsSectionBody -> Element msg
viewRelationshipsSection language relSection =
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
                [ width fill
                , htmlAttribute (HTA.id relSection.sectionToc)
                ]
                [ h5 language relSection.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\t -> viewRelationshipBody language t) relSection.items)
                ]
            ]
        ]
