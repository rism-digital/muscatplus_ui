module Response.PageSearchResponse exposing (..)

import Http.Detailed
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Response exposing (Response(..), ServerData)


serverRespondedWithPageSearch : Model -> ServerData -> ( Model, Cmd Msg )
serverRespondedWithPageSearch model response =
    let
        oldPage =
            model.page

        newPage =
            { oldPage | searchResults = Response response }
    in
    ( { model | page = newPage }, Cmd.none )


serverRespondedWithPageSearchError : Model -> Http.Detailed.Error String -> ( Model, Cmd Msg )
serverRespondedWithPageSearchError model error =
    let
        errorMessage =
            case error of
                Http.Detailed.BadUrl url ->
                    "A Bad URL was supplied: " ++ url

                Http.Detailed.BadBody metadata body message ->
                    "Unexpected response: " ++ message

                _ ->
                    "A problem happened with the request"

        oldPage =
            model.page

        newPage =
            { oldPage | searchResults = Error errorMessage }
    in
    ( { model | page = newPage }, Cmd.none )
