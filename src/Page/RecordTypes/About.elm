module Page.RecordTypes.About exposing (..)

import Iso8601
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Time exposing (Posix)


type alias AboutBody =
    { serverVersion : String
    , lastIndexed : Posix
    }


aboutBodyDecoder : Decoder AboutBody
aboutBodyDecoder =
    Decode.succeed AboutBody
        |> required "serverVersion" string
        |> required "lastIndexed" Iso8601.decoder
