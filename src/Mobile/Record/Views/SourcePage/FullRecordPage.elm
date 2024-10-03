module Mobile.Record.Views.SourcePage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, centerY, column, el, fill, height, htmlAttribute, none, paddingXY, px, row, text, width)
import Element.Border as Border
import Html.Attributes as HA
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Components exposing (sourceIconChooser)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Style exposing (colourScheme)
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
                , alignTop
                ]
                (sourceIcon colourScheme.darkBlue)
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
                [ mobilePageHeaderTemplate session.language (Just sourceIconView) body ]
            ]
        ]
