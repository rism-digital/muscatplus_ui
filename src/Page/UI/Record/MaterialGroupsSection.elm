module Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (MaterialGroupBody, MaterialGroupsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (h3s, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Relationship exposing (gatherRelationshipItems, viewRelationshipBody)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewMaterialGroup : Language -> MaterialGroupBody -> Element msg
viewMaterialGroup language mg =
    row
        (width fill :: sectionBorderStyles)
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , spacing 5
                ]
                [ h3s language mg.label
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    , paddingXY lineSpacing 10
                    ]
                    [ viewMaybe (viewSummaryField language) mg.summary
                    , viewMaybe (viewParagraphField language) mg.notes
                    , viewMaybe (viewMaterialGroupRelationships language) mg.relationships
                    , viewMaybe (viewExternalResourcesSection language) mg.externalResources
                    ]
                ]
            ]
        ]


viewMaterialGroupRelationships : Language -> RelationshipsSectionBody -> Element msg
viewMaterialGroupRelationships language relSection =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            (gatherRelationshipItems relSection.items
                |> List.map (\( label, items ) -> viewRelationshipBody language label items)
            )
        ]


viewMaterialGroupsSection : Language -> MaterialGroupsSectionBody -> Element msg
viewMaterialGroupsSection language mgSection =
    List.map (viewMaterialGroup language) mgSection.items
        |> sectionTemplate language mgSection
