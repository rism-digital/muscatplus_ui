module Desktop.Record.PublicationPage exposing (..)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, clipY, column, el, fill, height, none, paddingXY, px, row, width)
import Element.Background as Background
import Element.Border as Border
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Publication exposing (PublicationBody)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.PageTemplate exposing (pageFooterTemplateRouter, pageHeaderTemplate, subHeaderTemplate)
import Page.UI.Style exposing (colourScheme, recordTitleHeight, searchSourcesLinkHeight, tabBarHeight)
import Session exposing (Session)


viewFullPublicationPage :
    Session
    -> RecordPageModel RecordMsg
    -> PublicationBody
    -> Element RecordMsg
viewFullPublicationPage session model body =
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

                    --, tabBar
                    ]
                ]

            --, pageBodyView
            , pageFooterTemplateRouter session session.language body
            ]
        ]
