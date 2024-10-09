module Page.UI.Record.Previews.Source exposing (viewMobileSourcePreview, viewSourcePreview)

import Dict
import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, paddingXY, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (sourceIconChooser)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (mobileSubHeaderTemplate, pageFullMobileRecordTemplate, pageFullRecordTemplate, subHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.SourceItemsSection exposing (viewSourceItemsSection)
import Page.UI.Style exposing (colourScheme)
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
            sourceIconChooser (.type_ (.recordType body.sourceTypes))

        sourceIconView =
            el
                [ width (px 25)
                , height (px 25)
                , centerY
                ]
                (sourceIcon colourScheme.darkBlue)

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
                        (Dict.size allExternals > 0)
                    , viewMaybe (viewContentsSection cfg.language body.creator) body.contents
                    , viewMaybe
                        (viewIncipitsSection
                            { language = cfg.language
                            , infoToggleMsg = cfg.incipitInfoToggleMsg
                            , expandedIncipits = cfg.incipitInfoExpanded
                            }
                        )
                        body.incipits
                    , viewMaybe (viewMaterialGroupsSection cfg.language) body.materialGroups
                    , viewMaybe (viewRelationshipsSection cfg.language) body.relationships
                    , viewMaybe (viewReferencesNotesSection cfg.language) body.referencesNotes
                    , viewMaybe (viewSourceItemsSection cfg.language cfg.itemsExpanded cfg.expandMsg) body.sourceItems
                    , viewMaybe (viewExternalResourcesSection cfg.language) body.externalResources
                    , viewMaybe (viewExemplarsSection cfg.language) body.exemplars
                    ]
                ]
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
                    [ subHeaderTemplate cfg.language (Just sourceIconView) body
                    , pageFullRecordTemplate cfg.language body
                    ]
                ]
            , pageBodyView
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
            sourceIconChooser (.type_ (.recordType body.sourceTypes))

        sourceIconView =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , alignTop
                ]
                (sourceIcon colourScheme.darkBlue)

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
                        (Dict.size allExternals > 0)
                    , viewMaybe (viewContentsSection cfg.language body.creator) body.contents
                    , viewMaybe
                        (viewIncipitsSection
                            { language = cfg.language
                            , infoToggleMsg = cfg.incipitInfoToggleMsg
                            , expandedIncipits = cfg.incipitInfoExpanded
                            }
                        )
                        body.incipits
                    , viewMaybe (viewMaterialGroupsSection cfg.language) body.materialGroups
                    , viewMaybe (viewRelationshipsSection cfg.language) body.relationships
                    , viewMaybe (viewReferencesNotesSection cfg.language) body.referencesNotes
                    , viewMaybe (viewSourceItemsSection cfg.language cfg.itemsExpanded cfg.expandMsg) body.sourceItems
                    , viewMaybe (viewExternalResourcesSection cfg.language) body.externalResources
                    , viewMaybe (viewExemplarsSection cfg.language) body.exemplars
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
                    [ mobileSubHeaderTemplate cfg.language (Just sourceIconView) body
                    , pageFullMobileRecordTemplate cfg.language body
                    ]
                ]
            , pageBodyView
            ]
        ]
