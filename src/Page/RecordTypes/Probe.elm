module Page.RecordTypes.Probe exposing (ProbeData, ProbeStatus(..), QueryValidation(..), probeResponseDecoder)

import Http.Detailed
import Json.Decode as Decode exposing (Decoder, bool, int)
import Json.Decode.Pipeline exposing (required, requiredAt)


type alias ProbeData =
    { totalItems : Int
    , queryStatus : QueryValidation
    }


type ProbeStatus
    = Probing
    | ProbeSuccess ProbeData
    | ProbeError (Http.Detailed.Error String)
    | NotChecked


type QueryValidation
    = ValidQuery
    | InvalidQuery
    | EmptyQuery
    | CheckingQuery
    | NotCheckedQuery


probeResponseDecoder : Decoder ProbeData
probeResponseDecoder =
    Decode.succeed ProbeData
        |> required "totalItems" int
        |> requiredAt [ "queryValidation", "valid" ]
            (bool
                |> Decode.andThen queryValidationDecoder
            )


queryValidationDecoder : Bool -> Decoder QueryValidation
queryValidationDecoder qstatus =
    if qstatus then
        Decode.succeed ValidQuery

    else
        Decode.succeed InvalidQuery
