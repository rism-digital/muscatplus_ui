module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Flags exposing (Flags)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Routes exposing (Message(..))
import Subscriptions
import Update
import Url exposing (Url)
import View



{--
    Structure of this code is inspired by the 80sfy project here:
    https://github.com/paulfioravanti/80sfy
-}


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        , onUrlChange = \req -> Routing (Routes.UrlChanged req)
        , onUrlRequest = \url -> Routing (Routes.UrlRequest url)
        }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags initialUrl key =
    let
        model =
            Model.init flags initialUrl key
    in
    ( model, Cmd.none )
