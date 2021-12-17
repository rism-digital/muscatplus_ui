module Page.RecordTypes.Probe exposing (..)

import Json.Decode as Decode exposing (Decoder, int)
import Json.Decode.Pipeline exposing (required)


type alias ProbeData =
    { totalItems : Int }


probeResponseDecoder : Decoder ProbeData
probeResponseDecoder =
    Decode.succeed ProbeData
        |> required "totalItems" int
