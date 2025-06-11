module Page.RecordTypes.ApiError exposing (ApiError, apiErrorDecoder, messageToApiError)

import Json.Decode as Decode exposing (Decoder, Error, decodeString, string)
import Json.Decode.Pipeline exposing (required)


type alias ApiError =
    { message : String }


messageToApiError : String -> Result Error ApiError
messageToApiError msg =
    decodeString apiErrorDecoder msg


apiErrorDecoder : Decoder ApiError
apiErrorDecoder =
    Decode.succeed ApiError
        |> required "message" string
