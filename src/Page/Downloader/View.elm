module Page.Downloader.View exposing (..)

import Css
import Element exposing (Element, alignBottom, alignRight, centerY, column, fill, height, html, none, padding, paddingXY, pointer, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Styled as HT exposing (toUnstyled)
import Html.Styled.Attributes as HA
import Http exposing (Error(..))
import Language exposing (Language)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloadProgressTracker(..), DownloadState(..), DownloaderMsg(..))
import Page.UI.Attributes exposing (headingMD)
import Page.UI.Style exposing (colourScheme, rgbaFloatToInt, toCssColors)


view :
    { language : Language
    , model : DownloaderModel
    }
    -> Element DownloaderMsg
view { language, model } =
    let
        progressView =
            case model.progress of
                Progress num all ->
                    ((toFloat num / toFloat all) * 100)
                        |> ceiling
                        |> progressBar

                NoProgress ->
                    none

        errorMessage =
            case model.downloadState of
                ErrorDownloading err ->
                    row
                        [ width fill ]
                        [ errorMessageConverter err
                            |> text
                        ]

                _ ->
                    none
    in
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
                [ width fill ]
                [ Input.checkbox []
                    { onChange = UserChangedIncludeSearchUrl
                    , icon = Input.defaultCheckbox
                    , checked = model.includeSearchUrlInResults
                    , label =
                        Input.labelRight []
                            (text "Include Search URL in Results")
                    }
                ]
            , row
                [ width fill ]
                [ progressView ]
            , errorMessage
            , row
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


progressBar : Int -> Element msg
progressBar pctProgress =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ HT.div
                    [ HA.css
                        [ Css.backgroundColor (toCssColors colourScheme.lightGrey)
                        , Css.width (Css.pct 100)
                        , Css.height <| Css.px 30
                        ]
                    ]
                    [ HT.div
                        [ HA.css
                            [ Css.displayFlex
                            , Css.alignItems Css.center
                            , Css.justifyContent Css.center
                            , Css.backgroundColor <| toCssColors colourScheme.lightBlue
                            , Css.color (toCssColors colourScheme.white)

                            --, Css.borderRadius <| Css.px 9999
                            , Css.overflow Css.hidden
                            , Css.width <| Css.pct (toFloat pctProgress)
                            , Css.height <| Css.pct 100
                            ]
                        ]
                        [ HT.text (String.fromInt pctProgress ++ "%") ]
                    ]
                    |> toUnstyled
                    |> html
                ]
            ]
        ]


errorMessageConverter : Http.Error -> String
errorMessageConverter err =
    case err of
        BadUrl u ->
            "Bad URL: " ++ u

        Timeout ->
            "Timeout"

        NetworkError ->
            "Network Error"

        BadStatus s ->
            "Bad Status" ++ String.fromInt s

        BadBody _ ->
            "Bad Request Body"
