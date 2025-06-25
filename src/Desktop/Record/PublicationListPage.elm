module Desktop.Record.PublicationListPage exposing (viewPublicationListPage)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, fillPortion, height, htmlAttribute, indexedTable, link, none, padding, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Publication exposing (PublicationBasic, PublicationBody)
import Page.RecordTypes.PublicationList exposing (PublicationListBody)
import Page.RecordTypes.Relationship exposing (RelatedToBody)
import Page.UI.Attributes exposing (cycleTableBackground, linkColour, minimalDropShadow, sectionSpacing, tableHeaderStyles)
import Page.UI.Components exposing (h2, h3s)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.PageTemplate exposing (pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
import Session exposing (Session)


viewPublicationListPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationListBody
    -> Element RecordMsg
viewPublicationListPage session model body =
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
                (peopleSvg colourScheme.darkBlue)

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
            , row
                [ width fill
                , height fill
                , alignTop
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , padding 20
                    , alignTop
                    , spacing sectionSpacing
                    ]
                    [ indexedTable
                        [ Border.width 1
                        , Border.color colourScheme.midGrey
                        ]
                        { columns =
                            [ { header = el tableHeaderStyles (text "Composer")
                              , width = fillPortion 1
                              , view = \i w -> viewComposerCell session.language i w.composer
                              }
                            , { header = el tableHeaderStyles (text "(Abbreviation) and Catalog Title")
                              , width = fillPortion 3
                              , view = \i w -> viewCatalogTitleCell session.language i w
                              }
                            ]
                        , data = body.items
                        }
                    ]
                ]
            ]
        ]


viewCatalogTitleCell : Language -> Int -> PublicationBasic -> Element RecordMsg
viewCatalogTitleCell language rowNum publication =
    let
        cellBg =
            cycleTableBackground rowNum
    in
    link
        [ cellBg, linkColour, padding 10 ]
        { url = publication.id
        , label = text (extractLabelFromLanguageMap language publication.label)
        }


viewComposerCell : Language -> Int -> Maybe RelatedToBody -> Element RecordMsg
viewComposerCell language rowNum composer =
    let
        cellBg =
            cycleTableBackground rowNum
    in
    case composer of
        Just c ->
            link
                [ cellBg, linkColour, padding 10 ]
                { url = c.id
                , label = text (extractLabelFromLanguageMap language c.label)
                }

        Nothing ->
            el [ cellBg, padding 10 ] (text "[No composer]")
