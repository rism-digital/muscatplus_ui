module Page.Downloader.Model exposing (..)

import Page.Downloader.Msg exposing (DownloadProgressTracker, DownloadState)
import Page.Keyboard as Keyboard
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Query exposing (QueryArgs)
import Session exposing (Session)


type alias DownloaderModel =
    { queryToDownload : QueryArgs
    , keyboardQueryToDownload : Maybe (Keyboard.Model KeyboardMsg)
    , session : Session
    , downloadState : DownloadState
    , progress : DownloadProgressTracker
    , timestamp : String
    , includeSearchUrlInResults : Bool
    }
