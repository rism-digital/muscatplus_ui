module Search.Update exposing (..)

import Browser.Navigation as Nav
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.Query exposing (buildQueryParameters)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Request exposing (serverUrl)


searchSubmit : Model -> ( Model, Cmd Msg )
searchSubmit model =
    let
        oldPage =
            model.page

        newPage =
            { oldPage | response = Page.Model.Loading }

        oldSearch =
            model.activeSearch

        keyboard =
            oldSearch.keyboard

        notationQueryParameters =
            buildNotationQueryParameters keyboard.query

        textQueryParameters =
            buildQueryParameters oldSearch.query

        newSearch =
            { oldSearch | preview = NoResponseToShow }

        url =
            serverUrl
                [ "search" ]
                (List.append textQueryParameters notationQueryParameters)

        _ =
            Debug.log "Request url" url
    in
    ( { model
        | page = newPage
        , activeSearch = newSearch
      }
      -- this will trigger UrlChanged, which will actually submit the
      -- URL and request the data from the server.
    , Nav.pushUrl model.key url
    )
