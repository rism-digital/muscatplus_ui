module Mobile.Record.Views.PersonPage exposing (viewFullMobilePersonPage)

import Element exposing (Element, alignTop, centerX, clipY, column, el, fill, height, htmlAttribute, paddingXY, px, row, width)
import Element.Background as Background
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
viewFullMobilePersonPage session _ body =
    let
        icon =
            el
                [ width (px 25)
                , height (px 25)
                , centerX
                , alignTop
                ]
                (peopleSvg colourScheme.darkBlue)
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
                , Border.widthEach { bottom = 4, left = 0, right = 0, top = 0 }
                , htmlAttribute (HA.style "border-bottom-style" "double")
                , Border.color colourScheme.midGrey
                ]
                [ mobilePageHeaderTemplate session.language (Just icon) body ]
            ]
        ]
