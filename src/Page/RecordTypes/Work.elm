module Page.RecordTypes.Work exposing (WorkBody, workBodyDecoder)

import Json.Decode as Decode exposing (Decoder)


type alias WorkBody =
    {}


workBodyDecoder : Decoder WorkBody
workBodyDecoder =
    Decode.succeed WorkBody
