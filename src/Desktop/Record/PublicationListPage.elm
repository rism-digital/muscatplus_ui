module Desktop.Record.PublicationListPage exposing (viewPublicationListPage)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, htmlAttribute, link, none, padding, paddingXY, px, row, scrollbarY, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (extractLabelFromLanguageMap)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Publication exposing (PublicationBody)
import Page.RecordTypes.PublicationList exposing (PublicationListBody)
import Page.UI.Attributes exposing (linkColour, minimalDropShadow, sectionSpacing)
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

                    --, tabBar
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
                    (List.map (\b -> viewPublication session b) body.items)
                ]

            --, pageBodyView
            --, pageFooterTemplateRouter session session.language body
            ]
        ]


viewPublication : Session -> PublicationBody -> Element RecordMsg
viewPublication session body =
    row
        [ width fill ]
        [ link
            [ linkColour ]
            { label = h3s session.language body.label
            , url = body.id
            }
        ]
