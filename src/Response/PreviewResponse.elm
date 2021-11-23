module Response.PreviewResponse exposing (..)

import Http.Detailed
import Model exposing (Model)
import Msg exposing (Msg)
import Response exposing (Response(..), ServerData)


serverRespondedWithPreview : Model -> ServerData -> ( Model, Cmd Msg )
serverRespondedWithPreview model response =
    let
        oldSearch =
            model.activeSearch

        newSearch =
            { oldSearch | preview = Response response }
    in
    ( { model | activeSearch = newSearch }, Cmd.none )


serverRespondedWithPreviewError : Model -> Http.Detailed.Error String -> ( Model, Cmd Msg )
serverRespondedWithPreviewError model error =
    ( model, Cmd.none )
