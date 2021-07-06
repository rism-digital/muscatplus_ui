module Page exposing (..)

import Msg exposing (Msg)
import Page.Model exposing (CurrentRecordViewTab(..), PageModel, Response(..))
import Page.Query exposing (defaultQueryArgs)
import Page.Request exposing (createRequestWithDecoder)
import Page.Route exposing (parseUrl)
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
    , currentTab = DefaultRecordViewTab
    , searchResults = NoResponseToShow
    , searchParams = { query = defaultQueryArgs }
    }


initialCmd : Url -> Cmd Msg
initialCmd initialUrl =
    let
        cmd =
            createRequestWithDecoder (Url.toString initialUrl)
    in
    cmd
