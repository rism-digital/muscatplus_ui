module Desktop.Record.InventoryItemPage exposing (viewInventoryItemPage)

import Element exposing (Element, alignTop, centerY, clipY, column, el, fill, height, htmlAttribute, padding, px, row, scrollbarY, spacing, width)
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (Language)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Inventory exposing (InventoryItemBody)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.Components exposing (viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (sourcesSvg)
import Page.UI.Record.ContentsSection exposing (viewContentsSection)
import Page.UI.Record.ExternalResources exposing (viewExternalResourcesSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplateNoToc, recordHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.ReferencesNotesSection exposing (viewReferencesNotesSection)
import Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewInventoryItemPage : Session -> RecordPageModel RecordMsg -> InventoryItemBody -> Element RecordMsg
viewInventoryItemPage session _ body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerY
                ]
                (sourcesSvg colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplateNoToc session.language (Just icon) body
    in
    row
        [ width fill
        , height fill
        , Region.mainContent
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , clipY
            ]
            [ recordHeaderTemplate True [ pageHeader ]
            , viewInventoryItemBody session.language body
            , pageFooterTemplateRouter session session.language body
            ]
        ]


viewInventoryItemBody : Language -> InventoryItemBody -> Element RecordMsg
viewInventoryItemBody language body =
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , spacing sectionSpacing
            , alignTop
            , padding 20
            ]
            [ viewMaybe
                (viewContentsSection
                    { creator = body.creator
                    , language = language
                    , preRenderedFormatter = viewPreRenderedSummaryField
                    , relationshipFormatter = viewRelationshipBody
                    , summaryFormatter = viewSummaryField
                    }
                )
                body.contents
            , viewMaybe
                (viewRelationshipsSection
                    { language = language
                    , relationshipFormatter = viewRelationshipBody
                    }
                )
                body.relationships
            , viewMaybe
                (viewReferencesNotesSection
                    { language = language
                    , paragraphFormatter = viewParagraphField
                    , preRenderedFormatter = viewPreRenderedSummaryField
                    }
                )
                body.referencesNotes
            , viewMaybe
                (viewExternalResourcesSection
                    { language = language
                    , recordId = body.id
                    }
                )
                body.externalResources
            ]
        ]
