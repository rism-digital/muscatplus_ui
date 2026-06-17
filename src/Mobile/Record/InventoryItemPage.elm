module Mobile.Record.InventoryItemPage exposing (viewMobileInventoryItemPage)

import Element exposing (Element, alignTop, centerX, column, el, fill, height, htmlAttribute, none, padding, px, row, scrollbarY, spacing, width)
import Html.Attributes as HA
import Language exposing (Language)
import Mobile.Record.PageShell exposing (viewMobileRecordPage)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Inventory exposing (InventoryItemBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.Relationship exposing (viewMobileRelationshipBody)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewMobileInventoryItemPage : Session -> RecordPageModel RecordMsg -> InventoryItemBody -> Element RecordMsg
viewMobileInventoryItemPage session _ body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                ]
                (sourcesSvg colourScheme.darkBlue)
    in
    viewMobileRecordPage
        { session = session
        , body = body
        , icon = icon
        , topBar = none
        , bodyView = viewMobileInventoryItemBody session.language body
        }


viewMobileInventoryItemBody : Language -> InventoryItemBody -> Element RecordMsg
viewMobileInventoryItemBody language body =
    row
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
            [ viewMaybe
                (viewContentsSection
                    { creator = body.creator
                    , language = language
                    , preRenderedFormatter = viewPreRenderedMobileSummaryField
                    , relationshipFormatter = viewMobileRelationshipBody
                    , summaryFormatter = viewMobileSummaryField
                    }
                )
                body.contents
            ]
        ]
