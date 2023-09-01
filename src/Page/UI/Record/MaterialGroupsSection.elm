module Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)

import Element exposing (Element, alignTop, column, el, fill, height, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipsSectionBody)
import Page.RecordTypes.Source exposing (MaterialGroupBody, MaterialGroupsSectionBody)
import Page.UI.Attributes exposing (headingLG, lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (h3, h4, viewParagraphField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipBody)
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
                [ h3 language mg.label
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    , height fill
                    , alignTop
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
            (List.map (viewRelationshipBody language) relSection.items)
        ]


viewMaterialGroupsSection : Language -> MaterialGroupsSectionBody -> Element msg
viewMaterialGroupsSection language mgSection =
    List.map (viewMaterialGroup language) mgSection.items
        |> sectionTemplate language mgSection
