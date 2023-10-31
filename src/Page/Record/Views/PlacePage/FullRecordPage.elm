module Page.Record.Views.PlacePage.FullRecordPage exposing (viewFullPlacePage)

import Element exposing (Element, alignTop, centerX, centerY, column, el, fill, height, paddingXY, px, row, spacingXY, width)
import Element.Background as Background
import Element.Border as Border
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.RecordTypes.Place exposing (PlaceBody)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Images exposing (mapMarkerSvg)
import Page.UI.Record.PageTemplate exposing (pageHeaderTemplate)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewFullPlacePage :
    Session
    -> RecordPageModel RecordMsg
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
                , Border.widthEach { bottom = 2, left = 0, right = 0, top = 0 }
                , Border.color colourScheme.midGrey
                ]
                [ column
                    [ width (px 80) ]
                    [ el
                        [ width (px 45)
                        , height (px 45)
                        , centerX
                        , centerY
                        ]
                        (mapMarkerSvg colourScheme.midGrey)
                    ]
                , column
                    [ spacingXY 0 lineSpacing
                    , width fill
                    , height fill
                    , alignTop
                    , paddingXY 5 20
                    ]
                    [ pageHeaderTemplate session.language Nothing body

                    --, viewRecordTopBarDescriptionOnly session.language
                    ]
                ]
            ]
        ]
