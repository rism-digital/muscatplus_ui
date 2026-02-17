module Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, spacing, width)
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody, RelationshipsSectionBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (MaterialGroupBody, MaterialGroupsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (h3s)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Relationship exposing (gatherRelationshipItems)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewMaterialGroupsSection :
    { language : Language
    , currentUrl : String
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> MaterialGroupsSectionBody
    -> Element msg
viewMaterialGroupsSection { language, currentUrl, paragraphFormatter, relationshipFormatter, summaryFormatter } mgSection =
    List.map
        (viewMaterialGroup
            { language = language
            , currentUrl = currentUrl
            , paragraphFormatter = paragraphFormatter
            , relationshipFormatter = relationshipFormatter
            , summaryFormatter = summaryFormatter
            }
        )
        mgSection.items
        |> sectionTemplate language mgSection


viewMaterialGroup :
    { language : Language
    , currentUrl : String
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> MaterialGroupBody
    -> Element msg
viewMaterialGroup { language, currentUrl, paragraphFormatter, relationshipFormatter, summaryFormatter } mg =
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
                    [ viewMaybe (summaryFormatter language) mg.summary
                    , viewMaybe (paragraphFormatter language) mg.notes
                    , viewMaybe
                        (viewMaterialGroupRelationships
                            { language = language
                            , relationshipFormatter = relationshipFormatter
                            }
                        )
                        mg.relationships
                    , viewMaybe
                        (viewExternalResourcesSection
                            { language = language
                            , currentUrl = currentUrl
                            }
                        )
                        mg.externalResources
                    ]
                ]
            ]
        ]


viewMaterialGroupRelationships :
    { language : Language
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    }
    -> RelationshipsSectionBody
    -> Element msg
viewMaterialGroupRelationships { language, relationshipFormatter } relSection =
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
                |> List.map (\( label, items ) -> relationshipFormatter language label items)
            )
        ]
