module Page.Downloader.Msg exposing (..)

import Http
import Http.Detailed
import Page.RecordTypes.Probe exposing (ProbeData)


type DownloaderMsg
    = ServerRespondedWithProbeData (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ))
    | NothingHappenedWithTheDownloader
    | UserClickedDownloadButton
