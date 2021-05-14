module Api exposing (..)

import Api.Msg exposing (Message(..))
import Api.Response exposing (ServerResponse)
import Http exposing (Error(..))


type Model
    = Loading
    | Response ServerResponse
    | ApiError String
    | NoResponseToShow



--update : Message -> Model -> ( Model, Cmd msg )
--update msg model =
--    case msg of
--        ReceivedServerResponse (Ok response) ->
--            ( Response response, Cmd.none )
--
--        ReceivedServerResponse (Err error) ->
--            let
--                errorMessage =
--                    case error of
--                        BadUrl url ->
--                            "A Bad URL was supplied: " ++ url
--
--                        BadBody message ->
--                            "Unexpected response: " ++ message
--
--                        _ ->
--                            "A problem happened with the request"
--            in
--            ( ApiError errorMessage, Cmd.none )
