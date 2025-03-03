module Page.Downloader.Task exposing (..)

import Http
import Json.Decode exposing (Decoder)
import Task exposing (Task)


queueTasks : List String -> Decoder a -> List (Task Http.Error a)
queueTasks urls decoder =
    List.map (\u -> getTask u decoder) urls


getTask : String -> Decoder a -> Task Http.Error a
getTask path decoder =
    Http.task
        { method = "get"
        , headers = [ Http.header "Accept" "application/ld+json" ]
        , url = path
        , body = Http.emptyBody
        , resolver = handleJsonResponse decoder |> Http.stringResolver
        , timeout = Nothing
        }


handleJsonResponse : Decoder a -> Http.Response String -> Result Http.Error a
handleJsonResponse decoder response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.BadStatus_ { statusCode } _ ->
            Err (Http.BadStatus statusCode)

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.GoodStatus_ _ body ->
            case Json.Decode.decodeString decoder body of
                Err _ ->
                    Err (Http.BadBody body)

                Ok result ->
                    Ok result
