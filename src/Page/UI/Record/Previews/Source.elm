module Page.UI.Record.Previews.Source exposing (viewSourcePreview)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, paddingXY, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Components exposing (sourceIconView)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Bodies.Source exposing (viewSourceSections)
import Page.UI.Record.PageTemplate exposing (pageFullRecordTemplate, pageHeaderTemplate)
import Page.UI.Record.SourceItemsSection exposing (viewSourceItemsSection)
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

        sourceItemsSection =
            viewMaybe
                (viewSourceItemsSection
                    { expandMsg = cfg.expandMsg
                    , expanded = cfg.itemsExpanded
                    , language = cfg.language
                    , summaryFormatter = cfg.summaryFormatter
                    }
                )
                body.sourceItems
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
                    (viewSourceSections
                        { expandedDigitizedCopiesCallout = cfg.expandedDigitizedCopiesCallout
                        , expandedDigitizedCopiesMsg = cfg.expandedDigitizedCopiesMsg
                        , expandedIncipits = cfg.incipitInfoExpanded
                        , extraSectionsAfterReferencesNotes = [ sourceItemsSection ]
                        , includeDigitalObjects = False
                        , incipitInfoToggleMsg = cfg.incipitInfoToggleMsg
                        , language = cfg.language
                        , paragraphFormatter = cfg.paragraphFormatter
                        , preRenderedFormatter = cfg.preRenderedFormatter
                        , recordId = body.id
                        , relationshipFormatter = cfg.relationshipFormatter
                        , summaryFormatter = cfg.summaryFormatter
                        }
                        body
                    )
                ]
            ]
        ]
