module Request exposing (apply, createRequest, createRequestWithAcceptAndExpect, createSvgRequest, serverUrl)

import Config as C
import Http exposing (Expect)
import Http.Detailed
import Json.Decode exposing (Decoder)
import Url.Builder exposing (QueryParameter)
import Url.Parser.Query as Q


{-|

    Creates a pipeline-like Query parser.

-}
apply : Q.Parser a -> Q.Parser (a -> b) -> Q.Parser b
apply argParser funcParser =
    Q.map2 (<|) funcParser argParser


createRequest :
    (Result (Http.Detailed.Error String) ( Http.Metadata, a ) -> msg)
    -> Decoder a
    -> String
    -> Cmd msg
createRequest responseMsg responseDecoder url =
    createRequestWithAcceptAndExpect "application/ld+json" (Http.Detailed.expectJson responseMsg responseDecoder) url


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


createSvgRequest :
    (Result (Http.Detailed.Error String) ( Http.Metadata, String ) -> msg)
    -> String
    -> Cmd msg
createSvgRequest responseMsg url =
    createRequestWithAcceptAndExpect "image/svg+xml" (Http.Detailed.expectString responseMsg) url


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
