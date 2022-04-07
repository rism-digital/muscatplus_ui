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
            ( PersonPage session <| Record.init initialUrl route
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        PersonSourcePageRoute _ _ ->
            let
                recordPath =
                    String.replace "/sources" "" initialUrl.path

                recordUrl =
                    { initialUrl | path = recordPath }

                initialModel =
                    Record.init initialUrl route
            in
            ( PersonPage session <| Record.init initialUrl route
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest recordUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordSearchRequest initialUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.requestPreviewIfSelected initialModel.selectedResult
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        InstitutionPageRoute _ ->
            ( InstitutionPage session <| Record.init initialUrl route
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        InstitutionSourcePageRoute _ _ ->
            let
                recordPath =
                    String.replace "/sources" "" initialUrl.path

                recordUrl =
                    { initialUrl | path = recordPath }

                initialModel =
                    Record.init initialUrl route
            in
            ( InstitutionPage session initialModel
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest recordUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordSearchRequest initialUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.requestPreviewIfSelected initialModel.selectedResult
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        SourcePageRoute _ ->
            ( SourcePage session <| Record.init initialUrl route
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        PlacePageRoute _ ->
            ( PlacePage session <| Record.init initialUrl route
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
