module Api.Request exposing (..)

import Http
import Json.Decode exposing (Decoder)


createRequest : (Result Http.Error a -> msg) -> Decoder a -> String -> Cmd msg
createRequest responseMsg responseDecoder url =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/ld+json" ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson responseMsg responseDecoder
        , timeout = Nothing
        , tracker = Nothing
        }
