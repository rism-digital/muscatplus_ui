module Page.Request exposing (..)

import Http
import Http.Detailed
import Page.Decoders exposing (recordResponseDecoder)
import Request exposing (createRequest)
import Response exposing (ServerData)


createRequestWithDecoder : (Result (Http.Detailed.Error String) ( Http.Metadata, ServerData ) -> msg) -> String -> Cmd msg
createRequestWithDecoder msg url =
    createRequest msg recordResponseDecoder url


createErrorMessage : Http.Detailed.Error String -> String
createErrorMessage error =
    case error of
        Http.Detailed.BadUrl url ->
            "A Bad URL was supplied: " ++ url

        Http.Detailed.BadBody _ _ message ->
            "Unexpected response: " ++ message

        Http.Detailed.BadStatus metadata message ->
            case metadata.statusCode of
                404 ->
                    metadata.statusText

                _ ->
                    "A bad status was received"

        _ ->
            "A problem happened with the request"
