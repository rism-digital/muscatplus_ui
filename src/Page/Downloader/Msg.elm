module Page.Downloader.Msg exposing (..)

import Http
import Http.Detailed
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search
import Task.Parallel as Parallel


type DownloadProgressTracker
    = NoProgress
    | Progress Int Int -- num downloaded, total to download


type DownloadState
    = DownloadNotStarted
    | Downloading (Parallel.ListState DownloaderMsg Page.RecordTypes.Search.ResultsBody)
    | ErrorDownloading Http.Error
    | DownloadCompleted (List Page.RecordTypes.Search.ResultsBody)
    | DownloadCancelled


type DownloaderMsg
    = ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ClientRespondedWithCurrentTime String
    | RecordDownloadUpdated (Parallel.ListMsg Page.RecordTypes.Search.ResultsBody)
    | RecordDownloadFailed Http.Error
    | RecordDownloadCompleted (List Page.RecordTypes.Search.ResultsBody)
    | NothingHappenedWithTheDownloader
    | UserClickedDownloadButton
    | UserClickedCancelDownloadButton
    | UserChangedIncludeSearchUrl Bool
