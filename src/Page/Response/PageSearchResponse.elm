module Page.Response.PageSearchResponse exposing (..)

import Http exposing (Error(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.Response exposing (ServerData)


serverRespondedWithPageSearch : Model -> ServerData -> ( Model, Cmd Msg )
serverRespondedWithPageSearch model response =
    let
        oldPage =
            model.page

        newPage =
            { oldPage | searchResults = Response response }
    in
    ( { model | page = newPage }, Cmd.none )


serverRespondedWithPageSearchError : Model -> Error -> ( Model, Cmd Msg )
serverRespondedWithPageSearchError model error =
    let
        errorMessage =
            case error of
                BadUrl url ->
                    "A Bad URL was supplied: " ++ url

                BadBody message ->
                    "Unexpected response: " ++ message

                _ ->
                    "A problem happened with the request"

        oldPage =
            model.page

        newPage =
            { oldPage | searchResults = Error errorMessage }
    in
    ( { model | page = newPage }, Cmd.none )
