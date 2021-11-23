module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Flags exposing (Flags)
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.Front as Front
import Page.NotFound as NotFound
import Page.Record as Record
import Page.Route as Route exposing (Route(..))
import Page.Search as Search
import Session
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


{-|

    The initial model state

-}
init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags initialUrl key =
    let
        route =
            Route.parseUrl initialUrl

        session =
            Session.init flags initialUrl key
    in
    case route of
        FrontPageRoute ->
            ( FrontPage session Front.init
            , Cmd.map Msg.UserInteractedWithFrontPage (Front.frontPageRequest initialUrl)
            )

        SearchPageRoute _ _ ->
            ( SearchPage session (Search.init route)
            , Cmd.map Msg.UserInteractedWithSearchPage (Search.searchPageRequest initialUrl)
            )

        PersonPageRoute _ ->
            ( PersonPage session (Record.init route)
            , Cmd.map Msg.UserInteractedWithRecordPage (Record.recordPageRequest initialUrl)
            )

        InstitutionPageRoute _ ->
            ( InstitutionPage session (Record.init route)
            , Cmd.map Msg.UserInteractedWithRecordPage (Record.recordPageRequest initialUrl)
            )

        SourcePageRoute _ ->
            ( SourcePage session (Record.init route)
            , Cmd.map Msg.UserInteractedWithRecordPage (Record.recordPageRequest initialUrl)
            )

        _ ->
            ( NotFoundPage session NotFound.init
            , Cmd.map Msg.UserInteractedWithNotFoundPage (NotFound.initialCmd initialUrl)
            )
