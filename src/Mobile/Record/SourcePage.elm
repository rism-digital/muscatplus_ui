module Mobile.Record.SourcePage exposing (viewFullMobileSourcePage)

import Element exposing (Element, alignTop, clipY, column, el, fill, height, htmlAttribute, padding, paddingXY, px, row, scrollbarY, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Components exposing (sourceIconChooser)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ContentsSection exposing (viewMobileContentsSection)
import Page.UI.Record.PageTemplate exposing (mobilePageHeaderTemplate)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullMobileSourcePage :
    Session
    -> RecordPageModel RecordMsg
    -> FullSourceBody
    -> Element RecordMsg
viewFullMobileSourcePage session _ body =
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
                [ mobilePageHeaderTemplate session.language (Just sourceIconView) body ]
            , row
                [ width fill
                , height fill
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , height fill
                    , alignTop
                    , padding 20
                    ]
                    [ viewMaybe (viewMobileContentsSection session.language body.creator) body.contents ]
                ]
            ]
        ]
