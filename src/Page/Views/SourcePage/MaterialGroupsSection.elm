module Page.Views.SourcePage.MaterialGroupsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, none, paddingXY, row, spacing, text, width)
import Element.Border as Border
import Language exposing (Language)
import Page.RecordTypes.Source exposing (FullSourceBody, MaterialGroupBody, MaterialGroupsSectionBody, RelationshipsSectionBody)
import Page.UI.Components exposing (h5, h6, viewSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.Views.Relationship exposing (viewRelationshipBody)


viewMaterialGroupsRouter : FullSourceBody -> Language -> Element msg
viewMaterialGroupsRouter body language =
    case body.materialGroups of
        Just materialGroupsSection ->
            viewMaterialGroupsSection materialGroupsSection language

        Nothing ->
            none


viewMaterialGroupsSection : MaterialGroupsSectionBody -> Language -> Element msg
viewMaterialGroupsSection mgSection language =
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
                ]
                [ h5 language mgSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                (List.map (\l -> viewMaterialGroup l language) mgSection.items)
            ]
        ]


viewMaterialGroup : MaterialGroupBody -> Language -> Element msg
viewMaterialGroup mg language =
    let
        summary =
            case mg.summary of
                Just sum ->
                    viewSummaryField sum language

                Nothing ->
                    none

        relationships =
            case mg.relationships of
                Just rel ->
                    viewMaterialGroupRelationships rel language

                Nothing ->
                    none
    in
    row
        [ width fill
        , height fill
        , Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }
        , Border.color colourScheme.midGrey
        , paddingXY 10 0
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , spacing 10
            , alignTop
            ]
            [ summary
            , relationships
            ]
        ]


viewMaterialGroupRelationships : RelationshipsSectionBody -> Language -> Element msg
viewMaterialGroupRelationships relSection language =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ h6 language relSection.label ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (\t -> viewRelationshipBody t language) relSection.items)
                ]
            ]
        ]
