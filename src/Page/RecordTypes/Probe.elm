module Page.RecordTypes.Probe exposing (..)

import Json.Decode as Decode exposing (Decoder, int)
import Json.Decode.Pipeline exposing (optional, required)
import Page.RecordTypes.Search exposing (ModeFacet, modeFacetDecoder)


type alias ProbeData =
    { totalItems : Int
    , modes : Maybe ModeFacet
    }


probeResponseDecoder : Decoder ProbeData
probeResponseDecoder =
    Decode.succeed ProbeData
        |> required "totalItems" int
        |> optional "modes" (Decode.maybe modeFacetDecoder) Nothing
