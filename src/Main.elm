module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import BrowserPreferences exposing (browserPreferencesDecoder, defaultPreferences)
import Flags exposing (Flags)
import Json.Decode as Decode exposing (decodeValue)
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.Front as Front
import Page.NotFound as NotFound
import Page.Record as Record
import Page.Route as Route exposing (Route(..))
import Page.Search as Search exposing (applySearchPreferences)
import Page.SideBar as Sidebar
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

        browserPreferences =
            case flags.searchPreferences of
                Just localPreferences ->
                    decodeValue browserPreferencesDecoder localPreferences
                        |> Result.withDefault defaultPreferences

                Nothing ->
                    defaultPreferences
    in
    case route of
        FrontPageRoute _ ->
            ( FrontPage session <| Front.init
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithFrontPage <| Front.frontPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        SearchPageRoute _ _ ->
            let
                initialModel =
                    Search.init initialUrl route
                        |> applySearchPreferences browserPreferences
            in
            ( SearchPage session initialModel
            , Cmd.batch
                [ Cmd.batch
                    [ Search.searchPageRequest initialUrl
                    , Search.requestPreviewIfSelected initialModel.selectedResult
                    ]
                    |> Cmd.map Msg.UserInteractedWithSearchPage
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        PersonPageRoute _ ->
            ( PersonPage session <| Record.init route
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        InstitutionPageRoute _ ->
            ( InstitutionPage session <| Record.init route
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        SourcePageRoute _ ->
            ( SourcePage session <| Record.init route
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        PlacePageRoute _ ->
            ( PlacePage session <| Record.init route
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        _ ->
            ( NotFoundPage session NotFound.init
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithNotFoundPage <| NotFound.initialCmd initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )
