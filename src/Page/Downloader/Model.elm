module Page.Downloader.Model exposing (DownloaderModel, init)

import Http
import Http.Detailed
import Page.Downloader.Msg exposing (DownloadProgressTracker(..), DownloadState(..))
import Page.Keyboard as Keyboard
import Page.Keyboard.Msg exposing (KeyboardMsg)
import Page.Query exposing (QueryArgs)
import Page.RecordTypes.Search exposing (ResultsBody, SearchResult)
import Session exposing (Session)
import Task exposing (Task)


type alias DownloaderModel =
    { queryToDownload : QueryArgs
    , keyboardQueryToDownload : Maybe (Keyboard.Model KeyboardMsg)
    , session : Session
    , downloadState : DownloadState
    , progress : DownloadProgressTracker
    , timestamp : String
    , includeSearchUrlInResults : Bool
    , taskQueue : List (List (Task (Http.Detailed.Error String) ( Http.Metadata, ResultsBody )))
    , resultsList : List ( Int, List SearchResult )
    }


init :
    { keyboard : Maybe (Keyboard.Model KeyboardMsg)
    , queryArgs : QueryArgs
    , session : Session
    }
    -> DownloaderModel
init cfg =
    { queryToDownload = cfg.queryArgs
    , keyboardQueryToDownload = cfg.keyboard
    , session = cfg.session
    , downloadState = DownloadNotStarted
    , progress = NoProgress
    , timestamp = ""
    , includeSearchUrlInResults = False
    , taskQueue = []
    , resultsList = []
    }
