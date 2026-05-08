module Mobile.Record.InventoryItemPage exposing (viewMobileInventoryItemPage)

import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Html.Attributes as HA
import Language exposing (Language)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Inventory exposing (InventoryItemBody)
import Page.UI.Attributes exposing (minimalDropShadow, sectionSpacing)
import Page.UI.Components exposing (viewMobileSummaryField, viewPreRenderedMobileSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
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
                , alignTop
                ]
                (sourcesSvg colourScheme.darkBlue)
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
                [ mobilePageHeaderTemplate session.language (Just icon) body ]
            , viewMobileInventoryItemBody session.language body
            ]
        ]


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
