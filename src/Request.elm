module Request exposing (..)

import Config as C
import Http exposing (Expect)
import Json.Decode exposing (Decoder)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q


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
    createRequestWithAcceptAndExpect "application/ld+json" (Http.expectJson responseMsg responseDecoder) url


createSvgRequest : (Result Http.Error String -> msg) -> String -> Cmd msg
createSvgRequest responseMsg url =
    createRequestWithAcceptAndExpect "image/svg+xml" (Http.expectString responseMsg) url


createRequestWithAcceptAndExpect : String -> Expect msg -> String -> Cmd msg
createRequestWithAcceptAndExpect accept expect url =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" accept ]
        , url = url
        , body = Http.emptyBody
        , expect = expect
        , timeout = Nothing
        , tracker = Nothing
        }


{-|

    Creates a pipeline-like Query parser.

-}
apply : Q.Parser a -> Q.Parser (a -> b) -> Q.Parser b
apply argParser funcParser =
    Q.map2 (<|) funcParser argParser
