module Page exposing (..)

import Msg exposing (Msg)
import Page.Model exposing (PageModel, Response(..))
import Page.Request exposing (createRequestWithDecoder)
import Page.Route exposing (Route(..), parseUrl)
import Url exposing (Url)


type alias Model =
    PageModel


init : Url -> PageModel
init initialUrl =
    let
        initialRoute =
            parseUrl initialUrl
    in
    { response = Loading
    , route = initialRoute
    , url = initialUrl
    }


initialCmd : Url -> Cmd Msg
initialCmd initialUrl =
    let
        cmd =
            createRequestWithDecoder (Url.toString initialUrl)
    in
    cmd
