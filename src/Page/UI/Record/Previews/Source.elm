module Page.UI.Record.Previews.Source exposing (viewMobileSourcePreview, viewSourcePreview)

import Dict
import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, paddingXY, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (sourceIconView, viewMobileParagraphField, viewMobileSummaryField, viewParagraphField, viewPreRenderedMobileSummaryField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (mobileSubHeaderTemplate, pageFullMobileRecordTemplate, pageFullRecordTemplate, subHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody, viewRelationshipBody, viewRelationshipsSection)
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
                    [ subHeaderTemplate cfg.language (Just sourceIcon) body
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
                            , preRenderedFormatter = viewPreRenderedSummaryField
                            , relationshipFormatter = viewRelationshipBody
                            , summaryFormatter = viewSummaryField
                            }
                        )
                        body.contents
                    , viewMaybe
                        (viewIncipitsSection
                            { language = cfg.language
                            , infoToggleMsg = cfg.incipitInfoToggleMsg
                            , expandedIncipits = cfg.incipitInfoExpanded
                            , summaryFormatter = viewSummaryField
                            }
                        )
                        body.incipits
                    , viewMaybe
                        (viewMaterialGroupsSection
                            { language = cfg.language
                            , paragraphFormatter = viewParagraphField
                            , relationshipFormatter = viewRelationshipBody
                            , summaryFormatter = viewSummaryField
                            }
                        )
                        body.materialGroups
                    , viewMaybe
                        (viewRelationshipsSection
                            { language = cfg.language
                            , relationshipFormatter = viewRelationshipBody
                            }
                        )
                        body.relationships
                    , viewMaybe
                        (viewSourceWorksSection
                            { language = cfg.language
                            , preRenderedFormatter = viewPreRenderedSummaryField
                            }
                        )
                        body.works
                    , viewMaybe
                        (viewReferencesNotesSection
                            { language = cfg.language
                            , paragraphFormatter = viewParagraphField
                            , preRenderedFormatter = viewPreRenderedSummaryField
                            }
                        )
                        body.referencesNotes
                    , viewMaybe
                        (viewSourceItemsSection
                            { expandMsg = cfg.expandMsg
                            , expanded = cfg.itemsExpanded
                            , language = cfg.language
                            , summaryFormatter = viewSummaryField
                            }
                        )
                        body.sourceItems
                    , viewMaybe (viewExternalResourcesSection cfg.language) body.externalResources
                    , viewMaybe
                        (viewExemplarsSection
                            { language = cfg.language
                            , paragraphFormatter = viewParagraphField
                            , preRenderedFormatter = viewPreRenderedSummaryField
                            , relationshipFormatter = viewRelationshipBody
                            , summaryFormatter = viewSummaryField
                            }
                        )
                        body.exemplars
                    ]
                ]
            ]
        ]


viewMobileSourcePreview :
    { expandMsg : msg
    , expandedDigitizedCopiesCallout : Bool
    , expandedDigitizedCopiesMsg : msg
    , incipitInfoExpanded : Set String
    , incipitInfoToggleMsg : String -> msg
    , itemsExpanded : Bool
    , language : Language
    }
    -> FullSourceBody
    -> Element msg
viewMobileSourcePreview cfg body =
    let
        sourceIcon =
            .recordType body.sourceTypes
                |> .type_
                |> sourceIconView

        allExternals =
            gatherAllDigitizationLinksForCallout cfg.language body

        pageBodyView =
            row
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
                        (not (Dict.isEmpty allExternals))
                    , viewMaybe
                        (viewContentsSection
                            { creator = body.creator
                            , language = cfg.language
                            , preRenderedFormatter = viewPreRenderedMobileSummaryField
                            , relationshipFormatter = viewMobileRelationshipBody
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.contents
                    , viewMaybe
                        (viewIncipitsSection
                            { language = cfg.language
                            , infoToggleMsg = cfg.incipitInfoToggleMsg
                            , expandedIncipits = cfg.incipitInfoExpanded
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.incipits
                    , viewMaybe
                        (viewMaterialGroupsSection
                            { language = cfg.language
                            , paragraphFormatter = viewMobileParagraphField
                            , relationshipFormatter = viewMobileRelationshipBody
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.materialGroups
                    , viewMaybe
                        (viewRelationshipsSection
                            { language = cfg.language
                            , relationshipFormatter = viewMobileRelationshipBody
                            }
                        )
                        body.relationships
                    , viewMaybe
                        (viewReferencesNotesSection
                            { language = cfg.language
                            , paragraphFormatter = viewMobileParagraphField
                            , preRenderedFormatter = viewPreRenderedMobileSummaryField
                            }
                        )
                        body.referencesNotes
                    , viewMaybe
                        (viewSourceItemsSection
                            { expandMsg = cfg.expandMsg
                            , expanded = cfg.itemsExpanded
                            , language = cfg.language
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.sourceItems
                    , viewMaybe (viewExternalResourcesSection cfg.language) body.externalResources
                    , viewMaybe
                        (viewExemplarsSection
                            { language = cfg.language
                            , paragraphFormatter = viewMobileParagraphField
                            , preRenderedFormatter = viewPreRenderedMobileSummaryField
                            , relationshipFormatter = viewMobileRelationshipBody
                            , summaryFormatter = viewMobileSummaryField
                            }
                        )
                        body.exemplars
                    ]
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 10 10
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
                    [ mobileSubHeaderTemplate cfg.language (Just sourceIcon) body
                    , pageFullMobileRecordTemplate cfg.language body
                    ]
                ]
            , pageBodyView
            ]
        ]
