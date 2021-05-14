module Api.Request exposing (..)

import Api.Decoders exposing (recordResponseDecoder)
import Api.Msg exposing (Message(..))
import Config as C
import Http
import Json.Decode exposing (Decoder)
import Url.Builder exposing (QueryParameter)


serverUrl : List String -> List QueryParameter -> String
serverUrl pathSegments queryParameters =
    Url.Builder.crossOrigin C.serverUrl pathSegments queryParameters


sendRequest : String -> Cmd Message
sendRequest url =
    createRequest ReceivedServerResponse recordResponseDecoder url


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
