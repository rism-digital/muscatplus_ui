module Mobile.Record.Views.PersonPage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, paddingXY, px, row, width)
import Element.Border as Border
import Html.Attributes as HA
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.UI.Images exposing (peopleSvg)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobilePersonPage :
    Session
    -> RecordPageModel RecordMsg
    -> PersonBody
    -> Element RecordMsg
viewFullMobilePersonPage session model body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , centerY
                ]
                (peopleSvg colourScheme.darkBlue)
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill
                , paddingXY 10 10
                , Border.widthEach { bottom = 4, left = 0, right = 0, top = 0 }
                , htmlAttribute <| HA.style "border-bottom-style" "double"
                , Border.color colourScheme.midGrey
                ]
                [ mobilePageHeaderTemplate session.language (Just icon) body ]
            ]
        ]
