module Page.About exposing (Model, Msg, init, initialCmd, update)

import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg(..))
import Page.Decoders exposing (aboutResponseDecoder)
import Request exposing (createRequest)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)


type alias Model =
    AboutPageModel


type alias Msg =
    AboutMsg


init : Model
init =
    { response = Loading Nothing }


initialCmd : Url -> Cmd Msg
initialCmd initialUrl =
    createRequest ServerRespondedWithAboutData aboutResponseDecoder (Url.toString initialUrl)


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        ServerRespondedWithAboutData (Ok ( _, response )) ->
            ( { model
                | response = Response response
              }
            , Cmd.none
            )

        ServerRespondedWithAboutData (Err error) ->
            ( { model
                | response = Error error
              }
            , Cmd.none
            )

        NothingHappened ->
            ( model, Cmd.none )
