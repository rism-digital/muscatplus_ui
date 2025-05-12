module Desktop.Record.HoldingPage exposing (viewFullHoldingPage)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, none, padding, paddingXY, px, row, scrollbarY, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMap)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Holding exposing (HoldingBody)
import Page.RecordTypes.Relationship exposing (RelationshipBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (minimalDropShadow, sectionSpacing)
import Page.UI.Components exposing (pageBodyOrEmpty, viewParagraphField, viewPreRenderedSummaryField, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (holdingSvg)
import Page.UI.Record.ExemplarsSection exposing (viewBoundWithSection, viewExemplarExternalResourcesSection)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Record.PartOfSection exposing (viewHoldingPartOfSection)
import Page.UI.Record.Relationship exposing (viewRelationshipBody, viewRelationshipsSection)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
import Session exposing (Session)


viewFullHoldingPage :
    Session
    -> RecordPageModel RecordMsg
    -> HoldingBody
    -> Element RecordMsg
viewFullHoldingPage session model body =
    let
        headerHeight =
            if session.isFramed then
                px (recordTitleHeight + searchSourcesLinkHeight)

            else
                px (tabBarHeight + recordTitleHeight)

        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (holdingSvg colourScheme.darkBlue)

        pageHeader =
            if session.isFramed then
                subHeaderTemplate session.language (Just icon) body

            else
                pageHeaderTemplate session.language (Just icon) body
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
                , height headerHeight
                , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.midGrey
                ]
                [ column
                    [ width fill
                    , height fill
                    , centerY
                    , alignLeft
                    , paddingXY 20 0
                    , minimalDropShadow
                    ]
                    [ pageHeader
                    ]
                ]
            , viewHoldingBody
                { language = session.language
                , paragraphFormatter = viewParagraphField
                , preRenderedFormatter = viewPreRenderedSummaryField
                , relationshipFormatter = viewRelationshipBody
                , summaryFormatter = viewSummaryField
                }
                body
            , case body.recordHistory of
                Just rh ->
                    pageFooterTemplateRouter session session.language { id = body.id, recordHistory = rh }

                Nothing ->
                    none
            ]
        ]


viewHoldingBody :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    , preRenderedFormatter : Language -> List { label : LanguageMap, value : List (Element msg) } -> Element msg
    , relationshipFormatter : Language -> LanguageMap -> List RelationshipBody -> Element msg
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> HoldingBody
    -> Element msg
viewHoldingBody { language, paragraphFormatter, preRenderedFormatter, relationshipFormatter, summaryFormatter } body =
    let
        pageBody =
            pageBodyOrEmpty language
                False
                [ viewMaybe (viewHoldingPartOfSection language) body.partOf
                , Maybe.withDefault [] body.summary
                    |> summaryFormatter language
                , viewMaybe (paragraphFormatter language) body.notes
                , viewMaybe
                    (viewRelationshipsSection
                        { language = language
                        , relationshipFormatter = relationshipFormatter
                        }
                    )
                    body.relationships
                , viewMaybe
                    (viewBoundWithSection
                        { language = language
                        , relationshipFormatter = relationshipFormatter
                        }
                    )
                    body.boundWith
                , viewMaybe
                    (viewExemplarExternalResourcesSection
                        { language = language
                        , preRenderedFormatter = preRenderedFormatter
                        }
                    )
                    body.externalResources
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        , scrollbarY
        , htmlAttribute (HA.style "min-height" "unset")
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            , padding 20
            ]
            pageBody
        ]
