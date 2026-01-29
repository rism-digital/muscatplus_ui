module Page.Downloader.View exposing (view)

import Element exposing (Element, alignBottom, alignLeft, alignRight, centerX, centerY, clip, column, el, fill, height, htmlAttribute, maximum, padding, paragraph, pointer, px, row, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloadProgressTracker(..), DownloadState(..), DownloaderMsg(..))
import Page.UI.Attributes exposing (bodySM, buttonBaseStyles, lineSpacing)
import Page.UI.Components exposing (viewModalOverlay)
import Page.UI.Errors exposing (createErrorMessage, errorMessageString)
import Page.UI.Style exposing (colourScheme)


view :
    { closeMsg : msg
    , language : Language
    , model : DownloaderModel
    , userInteractedWithDownloaderMsg : DownloaderMsg -> msg
    }
    -> Element msg
view cfg =
    viewModalOverlay
        { body =
            viewWindowContent
                { language = cfg.language
                , model = cfg.model
                }
                |> Element.map cfg.userInteractedWithDownloaderMsg
        , cardAttributes =
            [ width (fill |> maximum 900)
            ]
        , closeMsg = cfg.closeMsg
        , language = cfg.language
        , title = toLanguageMap "Download Search Results"
        }


viewWindowContent :
    { language : Language
    , model : DownloaderModel
    }
    -> Element DownloaderMsg
viewWindowContent { language, model } =
    let
        cancelButtonCfg =
            case model.downloadState of
                Downloading _ ->
                    { colour = colourScheme.red
                    , fontColour = colourScheme.white
                    , msg = Just UserClickedCancelDownloadButton
                    , pointer = pointer
                    }

                _ ->
                    { colour = colourScheme.lightGrey
                    , fontColour = colourScheme.darkGrey
                    , msg = Nothing
                    , pointer = htmlAttribute (HA.style "cursor" "not-allowed")
                    }

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
                    (Background.color downloadColour
                        :: Font.color downloadFontColour
                        :: pointer
                        :: alignRight
                        :: buttonBaseStyles
                    )
                    { label = text "Download", onPress = downloadMsg }
                , Input.button
                    (Background.color cancelButtonCfg.colour
                        :: Font.color cancelButtonCfg.fontColour
                        :: Font.center
                        :: cancelButtonCfg.pointer
                        :: alignRight
                        :: buttonBaseStyles
                    )
                    { label = text "Cancel Download", onPress = cancelButtonCfg.msg }
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
                    createErrorMessage err
                        |> errorMessageString language

                DownloadCompleted ->
                    "Download completed, assembling CSV file"

                DownloadCancelled ->
                    "Download cancelled"

                _ ->
                    -- a space will not display anything but will reserve the line
                    -- so that it doesn't jump around when a message appears
                    " "

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
                        (el
                            [ centerY, centerX ]
                            (text progressPctStr)
                        )
                    )
                ]
            , row
                [ width fill ]
                [ text downloadStatusMessage ]
            ]
        ]
