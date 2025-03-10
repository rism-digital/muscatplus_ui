module Page.Downloader.Msg exposing (DownloadProgressTracker(..), DownloadState(..), DownloaderMsg(..))

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
    | Downloading (Parallel.ListState DownloaderMsg ( Http.Metadata, Page.RecordTypes.Search.ResultsBody ))
    | ErrorDownloading (Http.Detailed.Error String)
    | DownloadCompleted
    | DownloadCancelled


type DownloaderMsg
    = ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | ClientRespondedWithCurrentTime String
    | RecordDownloadUpdated (Parallel.ListMsg ( Http.Metadata, Page.RecordTypes.Search.ResultsBody ))
    | RecordDownloadFailed (Http.Detailed.Error String)
    | RecordDownloadCompleted (List ( Http.Metadata, Page.RecordTypes.Search.ResultsBody ))
    | NothingHappenedWithTheDownloader
    | UserClickedDownloadButton
    | UserClickedCancelDownloadButton
    | UserChangedIncludeSearchUrl Bool
