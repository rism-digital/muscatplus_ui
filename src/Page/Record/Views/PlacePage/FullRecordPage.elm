module Page.Record.Views.PlacePage.FullRecordPage exposing (..)

import Element exposing (Element, alignTop, column, fill, height, padding, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Record.Views.PageTemplate exposing (pageHeaderTemplate, pageUriTemplate)
import Page.RecordTypes.Place exposing (PlaceBody)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Session exposing (Session)


viewFullPlacePage :
    Session
    -> RecordPageModel
    -> PlaceBody
    -> Element RecordMsg
viewFullPlacePage session model body =
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
                , alignTop
                ]
                [ column
                    [ spacing lineSpacing
                    , width fill
                    , height fill
                    , alignTop
                    , padding 20
                    , Border.widthEach { top = 0, bottom = 2, left = 0, right = 0 }
                    , Border.color (colourScheme.slateGrey |> convertColorToElementColor)
                    , Background.color (colourScheme.cream |> convertColorToElementColor)
                    ]
                    [ pageHeaderTemplate session.language body
                    , pageUriTemplate session.language body
                    ]
                ]
            ]
        ]
