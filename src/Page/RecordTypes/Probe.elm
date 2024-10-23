module Page.RecordTypes.Probe exposing (ProbeData, ProbeStatus(..), QueryValidation(..), probeResponseDecoder)

import Http.Detailed
import Json.Decode as Decode exposing (Decoder, bool, int)
import Json.Decode.Pipeline exposing (required, requiredAt)


type alias ProbeData =
    { totalItems : Int
    , validQuery : Bool
    }


type ProbeStatus
    = Probing
    | ProbeSuccess ProbeData
    | ProbeError (Http.Detailed.Error String)
    | NotChecked


type QueryValidation
    = ValidQuery
    | InvalidQuery
    | CheckingQuery
    | NotCheckedQuery


probeResponseDecoder : Decoder ProbeData
probeResponseDecoder =
    Decode.succeed ProbeData
        |> required "totalItems" int
        |> requiredAt [ "queryValidation", "valid" ] bool
