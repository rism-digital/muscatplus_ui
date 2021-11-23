module Page.Front exposing (..)

import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg(..))
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Response exposing (Response(..))
import Url exposing (Url)


type alias Model =
    FrontPageModel


type alias Msg =
    FrontMsg


init : FrontPageModel
init =
    { response = Loading Nothing }


frontPageRequest : Url -> Cmd FrontMsg
frontPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithFrontData (Url.toString initialUrl)


update : FrontMsg -> FrontPageModel -> ( FrontPageModel, Cmd FrontMsg )
update msg model =
    case msg of
        ServerRespondedWithFrontData (Ok ( _, response )) ->
            ( { model
                | response = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithFrontData (Err err) ->
            ( { model
                | response = Error (createErrorMessage err)
              }
            , Cmd.none
            )

        NothingHappened ->
            ( model, Cmd.none )
