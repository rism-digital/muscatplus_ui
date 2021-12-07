module Page.NotFound exposing (..)

import Page.NotFound.Model exposing (NotFoundPageModel)
import Page.NotFound.Msg exposing (NotFoundMsg(..))
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)


type alias Msg =
    NotFoundMsg


type alias Model =
    NotFoundPageModel


init : NotFoundPageModel
init =
    { response = Loading Nothing }


initialCmd : Url -> Cmd NotFoundMsg
initialCmd initialUrl =
    createRequestWithDecoder ServerRespondedWithNotFoundData (Url.toString initialUrl)


update : Session -> NotFoundMsg -> NotFoundPageModel -> ( NotFoundPageModel, Cmd NotFoundMsg )
update session msg model =
    case msg of
        ServerRespondedWithNotFoundData (Ok ( _, response )) ->
            ( model, Cmd.none )

        ServerRespondedWithNotFoundData (Err error) ->
            ( { model | response = Error (createErrorMessage error) }, Cmd.none )

        NothingHappened ->
            ( model, Cmd.none )
