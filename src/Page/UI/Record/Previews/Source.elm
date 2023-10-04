module Page.UI.Record.Previews.Source exposing (viewSourcePreview)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, paddingXY, px, row, scrollbarY, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (sourceIconChooser)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.ExemplarsSection exposing (viewExemplarsSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.Incipits exposing (viewIncipitsSection)
import Page.UI.Record.MaterialGroupsSection exposing (viewMaterialGroupsSection)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, subHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewPartOfSection)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipsSection)
import Page.UI.Record.SourceItemsSection exposing (viewSourceItemsSection)
import Page.UI.Style exposing (colourScheme)
import Set exposing (Set)


viewSourcePreview : Language -> Bool -> msg -> Set String -> (String -> msg) -> FullSourceBody -> Element msg
viewSourcePreview language itemsExpanded expandMsg incipitInfoExpanded incipitInfoToggleMsg body =
    let
        sourceIcon =
            sourceIconChooser (.type_ (.recordType body.record))

        sourceIconView =
            el
                [ width (px 30)
                , height (px 30)
                , centerY
                ]
                (sourceIcon colourScheme.midGrey)

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
                    [ viewMaybe (viewPartOfSection language) body.partOf
                    , viewMaybe (viewContentsSection language body.creator) body.contents
                    , viewMaybe
                        (viewIncipitsSection
                            { language = language
                            , infoToggleMsg = incipitInfoToggleMsg
                            , expandedIncipits = incipitInfoExpanded
                            }
                        )
                        body.incipits
                    , viewMaybe (viewMaterialGroupsSection language) body.materialGroups
                    , viewMaybe (viewRelationshipsSection language) body.relationships
                    , viewMaybe (viewReferencesNotesSection language) body.referencesNotes
                    , viewMaybe (viewSourceItemsSection language itemsExpanded expandMsg) body.sourceItems
                    , viewMaybe (viewExternalResourcesSection language) body.externalResources
                    , viewMaybe (viewExemplarsSection language) body.exemplars
                    ]
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , paddingXY 20 10
        , scrollbarY
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
                    [ subHeaderTemplate language (Just sourceIconView) body
                    , pageFullRecordTemplate language body
                    ]
                ]
            , pageBodyView
            ]
        ]
