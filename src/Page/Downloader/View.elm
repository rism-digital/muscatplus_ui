module Page.Downloader.View exposing (view)

import Element exposing (Element, alignBottom, alignLeft, alignRight, centerX, centerY, clip, column, el, fill, height, htmlAttribute, padding, paddingXY, paragraph, pointer, px, row, shrink, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloadProgressTracker(..), DownloadState(..), DownloaderMsg(..))
import Page.UI.Attributes exposing (bodySM, headingMD, lineSpacing, minimalDropShadow)
import Page.UI.Components exposing (viewWindowTitleBar)
import Page.UI.Errors exposing (createErrorMessage)
import Page.UI.Style exposing (colourScheme)


view :
    { closeMsg : msg
    , language : Language
    , model : DownloaderModel
    , userInteractedWithDownloaderMsg : DownloaderMsg -> msg
    }
    -> Element msg
view cfg =
    row
        [ width fill
        , height fill
        , Background.color colourScheme.translucentGrey
        , htmlAttribute (HA.attribute "style" "backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px); z-index:200;")
        ]
        [ column
            [ centerX
            , centerY
            , width (px 900)
            , height (px 380)
            , Background.color colourScheme.white
            , Border.color colourScheme.darkBlue
            , Border.width 3
            , htmlAttribute (HA.style "z-index" "10")
            , minimalDropShadow
            ]
            [ viewWindowTitleBar cfg.language (toLanguageMap "Download Search Results") cfg.closeMsg
            , viewWindowContent
                { language = cfg.language
                , model = cfg.model
                }
                |> Element.map cfg.userInteractedWithDownloaderMsg
            ]
        ]


viewWindowContent :
    { language : Language
    , model : DownloaderModel
    }
    -> Element DownloaderMsg
viewWindowContent { language, model } =
    let
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
            , spacing lineSpacing

            --, explain Debug.todo
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
                            { checked = model.includeSearchUrlInResults
                            , icon = Input.defaultCheckbox
                            , label =
                                Input.labelRight []
                                    (text "Include Search URL in Results")
                            , onChange = UserChangedIncludeSearchUrl
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
                [ progressView language model ]
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


progressView : Language -> DownloaderModel -> Element msg
progressView language model =
    let
        ( progressFinished, progressTotal ) =
            case model.progress of
                NoProgress ->
                    ( 0, 0 )

                Progress fin tot ->
                    ( fin, tot )

        downloadStatusMessage =
            case model.downloadState of
                Downloading _ ->
                    "Downloading (" ++ String.fromInt progressFinished ++ " of " ++ String.fromInt progressTotal ++ ") result pages"

                ErrorDownloading err ->
                    createErrorMessage language err
                        |> Tuple.first

                DownloadCompleted ->
                    "Download completed, assembling CSV file"

                DownloadCancelled ->
                    "Download cancelled"

                _ ->
                    ""

        progressPct =
            if progressTotal == 0 then
                0

            else
                ((toFloat progressFinished / toFloat progressTotal) * 100)
                    |> ceiling

        progressPctStr =
            String.fromInt progressPct ++ "%"
    in
    row
        [ width fill ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , Border.width 1
                , Border.color colourScheme.darkGrey
                ]
                [ el
                    [ Background.color colourScheme.lightGrey
                    , width fill
                    , height (px 30)
                    ]
                    (el
                        [ alignLeft
                        , Font.center
                        , Background.color colourScheme.lightBlue
                        , Font.color colourScheme.white
                        , clip
                        , htmlAttribute (HA.style "width" progressPctStr)
                        , height fill
                        ]
                        (el [ centerY, centerX ] (text progressPctStr))
                    )
                ]
            , row
                [ width fill ]
                [ text downloadStatusMessage ]
            ]
        ]
