module Page.NotFound exposing (..)

import Page.NotFound.Model exposing (NotFoundPageModel)
import Page.NotFound.Msg exposing (NotFoundMsg(..))
import Page.Request exposing (createRequestWithDecoder)
import Response exposing (Response(..))
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
