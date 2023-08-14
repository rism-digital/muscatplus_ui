module Page.Error exposing (Model, Msg, init, initialCmd, update)

import Page.Error.Model exposing (ErrorPageModel)
import Page.Error.Msg exposing (NotFoundMsg(..))
import Page.Request exposing (createRequestWithDecoder)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)


type alias Model =
    ErrorPageModel


type alias Msg =
    NotFoundMsg


init : ErrorPageModel
init =
    { response = Loading Nothing }


initialCmd : Url -> Cmd NotFoundMsg
initialCmd initialUrl =
    createRequestWithDecoder ServerRespondedWithNotFoundData (Url.toString initialUrl)


update : Session -> NotFoundMsg -> ErrorPageModel -> ( ErrorPageModel, Cmd NotFoundMsg )
update session msg model =
    case msg of
        ServerRespondedWithNotFoundData (Ok _) ->
            ( { model
                | response = NoResponseToShow
              }
            , Cmd.none
            )

        ServerRespondedWithNotFoundData (Err error) ->
            ( { model
                | response = Error error
              }
            , Cmd.none
            )

        NothingHappened ->
            ( model, Cmd.none )
