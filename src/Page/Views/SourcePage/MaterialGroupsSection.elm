module Page.Views.SourcePage.MaterialGroupsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, paddingXY, row, spacing, width)
import Element.Border as Border
import Html.Attributes as HTA
import Language exposing (Language)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (MaterialGroupBody, MaterialGroupsSectionBody)
import Page.UI.Components exposing (h5, h6, viewSummaryField)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Relationship exposing (viewRelationshipBody)


viewMaterialGroupsSection : Language -> MaterialGroupsSectionBody -> Element msg
viewMaterialGroupsSection language mgSection =
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
                , htmlAttribute (HTA.id mgSection.sectionToc)
                ]
                [ h5 language mgSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                (List.map (\l -> viewMaterialGroup language l) mgSection.items)
            ]
        ]


viewMaterialGroup : Language -> MaterialGroupBody -> Element msg
viewMaterialGroup language mg =
    row
        [ width fill
        , height fill
        , Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , paddingXY 10 0
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , spacing 10
            , alignTop
            ]
            [ viewMaybe (viewSummaryField language) mg.summary
            , viewMaybe (viewMaterialGroupRelationships language) mg.relationships
            ]
        ]


viewMaterialGroupRelationships : Language -> RelationshipsSectionBody -> Element msg
viewMaterialGroupRelationships language relSection =
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
                    (List.map (\t -> viewRelationshipBody language t) relSection.items)
                ]
            ]
        ]
