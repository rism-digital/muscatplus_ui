module Page.Downloader exposing (..)

import Element exposing (Element, centerX, centerY, column, fill, height, htmlAttribute, px, row, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, toLanguageMap)
import List.Extra as LE
import Maybe.Extra as ME
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloaderMsg(..))
import Page.Downloader.View
import Page.Keyboard as Keyboard
import Page.Keyboard.Model exposing (toKeyboardQuery)
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs, buildQueryParameters, setPage, setRows)
import Page.Request exposing (createProbeRequestWithDecoder)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Components exposing (viewWindowTitleBar)
import Page.UI.Style exposing (colourScheme)
import Page.UpdateHelpers exposing (createProbeUrl)
import Request exposing (serverUrl)
import Session exposing (Session)


init : { queryArgs : QueryArgs, keyboard : Maybe (Keyboard.Model KeyboardMsg), session : Session } -> DownloaderModel
init cfg =
    { queryToDownload = cfg.queryArgs
    , keyboardQueryToDownload = cfg.keyboard
    , session = cfg.session
    }


downloadQueryParameters : Int -> { queryToDownload : QueryArgs, keyboardQueryToDownload : Maybe (Keyboard.Model KeyboardMsg) } -> String
downloadQueryParameters pageNumber { queryToDownload, keyboardQueryToDownload } =
    let
        notationQueryParameters =
            keyboardQueryToDownload
                |> ME.unwrap []
                    (\kq ->
                        toKeyboardQuery kq
                            |> buildNotationQueryParameters
                    )

        textQueryParameters =
            setPage pageNumber queryToDownload
                |> setRows 100
                |> buildQueryParameters
    in
    serverUrl [ "search" ] (List.append textQueryParameters notationQueryParameters)


update : DownloaderMsg -> DownloaderModel -> ( DownloaderModel, Cmd DownloaderMsg )
update msg model =
    case msg of
        ServerRespondedWithProbeData (Ok ( _, response )) ->
            let
                _ =
                    Debug.log "Probe response" response

                requestUrls =
                    LE.initialize (.totalPages response.pagination + 1)
                        (\pageNum ->
                            downloadQueryParameters pageNum
                                { queryToDownload = model.queryToDownload
                                , keyboardQueryToDownload = model.keyboardQueryToDownload
                                }
                        )

                _ =
                    Debug.log "Request Urls" requestUrls
            in
            ( model, Cmd.none )

        ServerRespondedWithProbeData (Err error) ->
            ( model, Cmd.none )

        NothingHappenedWithTheDownloader ->
            ( model, Cmd.none )

        UserClickedDownloadButton ->
            let
                -- increasing the rows to 100 helps with the download speed.
                newQuery =
                    model.queryToDownload
                        |> setRows 100

                probeUrl =
                    createProbeUrl model.session
                        { nextQuery = newQuery
                        , keyboard = model.keyboardQueryToDownload
                        }

                _ =
                    Debug.log "probe url" probeUrl
            in
            ( model, createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl )


view :
    { language : Language
    , model : DownloaderModel
    , closeMsg : msg
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
            , height (px 300)
            , Background.color colourScheme.white
            , Border.color colourScheme.darkBlue
            , Border.width 3
            , htmlAttribute (HA.style "z-index" "10")
            , minimalDropShadow
            ]
            [ viewWindowTitleBar cfg.language (toLanguageMap "Download Search Results") cfg.closeMsg
            , Page.Downloader.View.view
                { language = cfg.language
                , model = cfg.model
                }
                |> Element.map cfg.userInteractedWithDownloaderMsg
            ]
        ]
