module Page.Downloader.View exposing (..)

import Css
import Element exposing (Element, alignBottom, alignRight, centerY, column, fill, height, html, none, padding, paddingXY, paragraph, pointer, px, row, shrink, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Styled as HT exposing (toUnstyled)
import Html.Styled.Attributes as HA
import Http exposing (Error(..))
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloadProgressTracker(..), DownloadState(..), DownloaderMsg(..))
import Page.UI.Attributes exposing (bodySM, headingMD, lineSpacing, sectionSpacing)
import Page.UI.Style exposing (colourScheme, rgbaFloatToInt, toCssColors)


view :
    { language : Language
    , model : DownloaderModel
    }
    -> Element DownloaderMsg
view { language, model } =
    let
        downloadStatusView =
            case model.downloadState of
                ErrorDownloading err ->
                    row
                        [ width fill ]
                        [ errorMessageConverter err
                            |> text
                        ]

                DownloadCompleted _ ->
                    row
                        [ width fill ]
                        [ text "Download completed!" ]

                _ ->
                    none

        ( cancelColour, cancelFontColour, cancelMsg ) =
            case model.downloadState of
                Downloading _ ->
                    ( colourScheme.red, colourScheme.white, Just UserClickedCancelDownloadButton )

                _ ->
                    ( colourScheme.lightGrey, colourScheme.darkGrey, Nothing )

        ( downloadColour, downloadFontColour, downloadMsg ) =
            case model.downloadState of
                Downloading _ ->
                    ( colourScheme.lightGrey, colourScheme.darkGrey, Nothing )

                _ ->
                    ( colourScheme.lightBlue, colourScheme.white, Just UserClickedDownloadButton )
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , spacing sectionSpacing
            ]
            [ row
                [ width fill ]
                [ textColumn
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ paragraph [ width fill ] [ text (extractLabelFromLanguageMap language localTranslations.downloadsHelpOne) ]
                    , paragraph [ width fill, Font.semiBold ] [ text (extractLabelFromLanguageMap language localTranslations.downloadsHelpTwo) ]
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing lineSpacing
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
                        [ paragraph
                            [ bodySM ]
                            [ text (extractLabelFromLanguageMap language localTranslations.downloadsSearchUrlHelp) ]
                        ]
                    ]
                ]
            , row
                [ width fill ]
                [ progressView model ]
            , downloadStatusView
            , row
                [ width fill
                , alignBottom
                , spacing 10
                ]
                [ Input.button
                    [ Background.color downloadColour
                    , Font.color downloadFontColour
                    , height (px 35)
                    , width shrink
                    , Font.center
                    , headingMD
                    , pointer
                    , alignRight
                    , paddingXY 10 0
                    ]
                    { label = text "Download", onPress = downloadMsg }
                , Input.button
                    [ Background.color cancelColour
                    , Font.color cancelFontColour
                    , height (px 35)
                    , width shrink
                    , Font.center
                    , headingMD
                    , pointer
                    , alignRight
                    , paddingXY 10 0
                    ]
                    { label = text "Cancel Download", onPress = cancelMsg }
                ]
            ]
        ]


progressView : DownloaderModel -> Element msg
progressView model =
    let
        progressPct =
            case model.progress of
                Progress num all ->
                    ((toFloat num / toFloat all) * 100)
                        |> ceiling

                NoProgress ->
                    0
    in
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
                            , Css.width <| Css.pct (toFloat progressPct)
                            , Css.height <| Css.pct 100
                            ]
                        ]
                        [ HT.text (String.fromInt progressPct ++ "%") ]
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
