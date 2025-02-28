module Page.Downloader.View exposing (..)

import Element exposing (Element, alignBottom, alignRight, centerY, column, fill, height, none, padding, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Language exposing (Language)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloaderMsg(..))
import Page.UI.Attributes exposing (headingMD)
import Page.UI.Style exposing (colourScheme)


view :
    { language : Language
    , model : DownloaderModel
    }
    -> Element DownloaderMsg
view cfg =
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , spacing 6
            ]
            [ row
                [ width fill
                , alignBottom
                ]
                [ Input.button
                    [ Border.color colourScheme.lightBlue
                    , Background.color colourScheme.lightBlue
                    , height (px 35)
                    , width shrink
                    , Font.center
                    , Font.color colourScheme.white
                    , headingMD
                    , pointer
                    , alignRight
                    , paddingXY 10 0
                    ]
                    { label = text "Download", onPress = Just UserClickedDownloadButton }
                ]
            ]
        ]
