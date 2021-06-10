module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Flags exposing (Flags)
import Model exposing (Model)
import Msg exposing (Msg)
import Subscriptions
import Update
import Url exposing (Url)
import View


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        , onUrlChange = Msg.ClientChangedUrl
        , onUrlRequest = Msg.UserRequestedUrlChange
        }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags initialUrl key =
    let
        ( model, cmd ) =
            Model.init flags initialUrl key
    in
    ( model, cmd )
