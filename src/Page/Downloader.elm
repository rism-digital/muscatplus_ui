module Page.Downloader exposing (..)

import Element exposing (Element, centerX, centerY, column, fill, height, htmlAttribute, row, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, toLanguageMap)
import Page.Downloader.Model exposing (DownloaderModel)
import Page.Downloader.Msg exposing (DownloaderMsg)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Components exposing (viewWindowTitleBar)
import Page.UI.Style exposing (colourScheme)


init : DownloaderModel
init =
    {}


update : DownloaderMsg -> DownloaderModel -> ( DownloaderModel, Cmd DownloaderMsg )
update msg model =
    ( model, Cmd.none )


view :
    { language : Language
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
            , Background.color colourScheme.white
            , Border.color colourScheme.darkBlue
            , Border.width 3
            , htmlAttribute (HA.style "z-index" "10")
            , minimalDropShadow
            ]
            [ viewWindowTitleBar cfg.language (toLanguageMap "Download Search Results") cfg.closeMsg ]
        ]
