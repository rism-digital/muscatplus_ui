module Mobile.Record.SourcePage exposing (viewFullMobileSourcePage)

import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, none, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Html.Attributes as HA
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg as RecordMsg exposing (RecordMsg)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (minimalDropShadow, sectionSpacing)
import Page.UI.Components exposing (sourceIconChooser, viewMobileParagraphField, viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Bodies.Source exposing (viewSourceSections)
import Page.UI.Record.InventoryItemsSection exposing (viewInventoryItemsSection)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody)
import Page.UI.Record.SourceItemsSection exposing (viewSourceItemsSection)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..))
import Session exposing (Session)


viewFullMobileSourcePage :
    Session
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
viewFullMobileSourcePage session model body =
    let
        sourceIcon =
            .recordType body.sourceTypes
                |> .type_
                |> sourceIconChooser

        sourceIconView =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , alignTop
                ]
                (sourceIcon colourScheme.darkBlue)

        sourceItemsSection =
            viewMaybe
                (viewSourceItemsSection
                    { expandMsg = RecordMsg.UserClickedExpandSourceItemsSectionInPreview
                    , expanded = model.sourceItemsExpanded
                    , language = session.language
                    , summaryFormatter = viewMobileSummaryField
                    }
                )
                body.sourceItems

        inventoryItemsSection =
            viewInventoryItemsSectionRouter session model body
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            , Background.color colourScheme.white
            ]
            [ row
                [ width fill
                , paddingXY 10 10
                , minimalDropShadow
                ]
                [ mobilePageHeaderTemplate session.language (Just sourceIconView) body ]
            , row
                [ width fill
                , height fill
                , alignTop
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , padding 20
                    , spacing sectionSpacing
                    ]
                    (viewSourceSections
                        { expandedDigitizedCopiesCallout = model.digitizedCopiesCalloutExpanded
                        , expandedDigitizedCopiesMsg = RecordMsg.UserClickedExpandDigitalCopiesCallout
                        , expandedIncipits = model.incipitInfoExpanded
                        , extraSectionsAfterReferencesNotes = [ sourceItemsSection, inventoryItemsSection ]
                        , includeDigitalObjects = True
                        , incipitInfoToggleMsg = RecordMsg.UserClickedExpandIncipitInfoSectionInPreview
                        , language = session.language
                        , paragraphFormatter = viewMobileParagraphField
                        , preRenderedFormatter = viewPreRenderedMobileSummaryField
                        , recordId = body.id
                        , relationshipFormatter = viewMobileRelationshipBody
                        , summaryFormatter = viewMobileSummaryField
                        }
                        body
                    )
                ]
            ]
        ]


viewInventoryItemsSectionRouter : Session -> RecordPageModel RecordMsg -> FullSourceBody -> Element RecordMsg
viewInventoryItemsSectionRouter session model _ =
    case model.inventoryItems of
        Response inventoryItems ->
            viewInventoryItemsSection
                { expandMsg = RecordMsg.UserClickedExpandInventoryItemsSection
                , expanded = model.inventoryItemsExpanded
                , language = session.language
                }
                inventoryItems

        _ ->
            none
