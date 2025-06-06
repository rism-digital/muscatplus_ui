module Page.UI.Record.Previews.Source exposing (viewSourcePreview)

import Dict
import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, paddingXY, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (sourceIconView)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.SourceItemsSection exposing (viewSourceItemsSection)
import Page.UI.Record.WorksSection exposing (viewSourceWorksSection)
import Set exposing (Set)


viewSourcePreview :
    { expandMsg : msg
    , expandedDigitizedCopiesCallout : Bool
    , expandedDigitizedCopiesMsg : msg
    , incipitInfoExpanded : Set String
    , incipitInfoToggleMsg : String -> msg
    , itemsExpanded : Bool
    , language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> FullSourceBody
    -> Element msg
viewSourcePreview cfg body =
    let
        sourceIcon =
            .recordType body.sourceTypes
                |> .type_
                |> sourceIconView

        allExternals =
            gatherAllDigitizationLinksForCallout cfg.language body
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 20 10
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            ]
            [ row
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
                    [ pageHeaderTemplate cfg.language (Just sourceIcon) body
                    , pageFullRecordTemplate cfg.language body
                    ]
                ]
            , row
                [ width fill
                , height fill
                , alignTop
                ]
                [ column
                    [ width fill
                    , spacing sectionSpacing
                    ]
                    [ viewMaybe (viewPartOfSection cfg.language) body.partOf
                    , viewIf
                        (viewDigitizedCopiesCalloutSection
                            { expandMsg = cfg.expandedDigitizedCopiesMsg
                            , expanded = cfg.expandedDigitizedCopiesCallout
                            , language = cfg.language
                            }
                            allExternals
                        )
                        (Dict.size allExternals > 0)
                    , viewMaybe
                        (viewContentsSection
                            { creator = body.creator
                            , language = cfg.language
                            , preRenderedFormatter = cfg.preRenderedFormatter
                            , relationshipFormatter = cfg.relationshipFormatter
                            , summaryFormatter = cfg.summaryFormatter
                            }
                        )
                        body.contents
                    , viewMaybe
                        (viewIncipitsSection
                            { language = cfg.language
                            , infoToggleMsg = cfg.incipitInfoToggleMsg
                            , expandedIncipits = cfg.incipitInfoExpanded
                            , summaryFormatter = cfg.summaryFormatter
                            }
                        )
                        body.incipits
                    , viewMaybe
                        (viewMaterialGroupsSection
                            { language = cfg.language
                            , paragraphFormatter = cfg.paragraphFormatter
                            , relationshipFormatter = cfg.relationshipFormatter
                            , summaryFormatter = cfg.summaryFormatter
                            }
                        )
                        body.materialGroups
                    , viewMaybe
                        (viewRelationshipsSection
                            { language = cfg.language
                            , relationshipFormatter = cfg.relationshipFormatter
                            }
                        )
                        body.relationships
                    , viewMaybe
                        (viewSourceWorksSection
                            { language = cfg.language
                            , preRenderedFormatter = cfg.preRenderedFormatter
                            }
                        )
                        body.works
                    , viewMaybe
                        (viewReferencesNotesSection
                            { language = cfg.language
                            , paragraphFormatter = cfg.paragraphFormatter
                            , preRenderedFormatter = cfg.preRenderedFormatter
                            }
                        )
                        body.referencesNotes
                    , viewMaybe
                        (viewSourceItemsSection
                            { expandMsg = cfg.expandMsg
                            , expanded = cfg.itemsExpanded
                            , language = cfg.language
                            , summaryFormatter = cfg.summaryFormatter
                            }
                        )
                        body.sourceItems
                    , viewMaybe (viewExternalResourcesSection cfg.language) body.externalResources
                    , viewMaybe
                        (viewExemplarsSection
                            { language = cfg.language
                            , paragraphFormatter = cfg.paragraphFormatter
                            , preRenderedFormatter = cfg.preRenderedFormatter
                            , relationshipFormatter = cfg.relationshipFormatter
                            , summaryFormatter = cfg.summaryFormatter
                            }
                        )
                        body.exemplars
                    ]
                ]
            ]
        ]
