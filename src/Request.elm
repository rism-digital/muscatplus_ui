module Request exposing (..)

import Config as C
import Http
import Json.Decode exposing (Decoder)
import Url.Builder exposing (QueryParameter)


serverUrl : List String -> List QueryParameter -> String
serverUrl pathSegments queryParameters =
    let
        cleanedSegments =
            List.map
                (\segment ->
                    if String.startsWith "/" segment then
                        String.dropLeft 1 segment

                    else
                        segment
                )
                pathSegments
    in
    Url.Builder.crossOrigin C.serverUrl cleanedSegments queryParameters


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
