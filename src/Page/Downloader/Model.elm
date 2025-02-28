module Page.Downloader.Model exposing (..)

import Page.Keyboard as Keyboard
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Query exposing (QueryArgs)
import Session exposing (Session)


type alias DownloaderModel =
    { queryToDownload : QueryArgs
    , keyboardQueryToDownload : Maybe (Keyboard.Model KeyboardMsg)
    , session : Session
    }
