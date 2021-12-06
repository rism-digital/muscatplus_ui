module Page.SideBar exposing (..)

import Browser.Navigation as Nav
import Page.SideBar.Msg exposing (SideBarMsg(..))
import Session exposing (AnimatedSideBar(..), Session)


type alias Msg =
    SideBarMsg


update : SideBarMsg -> Session -> ( Session, Cmd SideBarMsg )
update msg session =
    case msg of
        UserMouseEnteredSideBar ->
            ( { session | expandedSideBar = Expanding }, Cmd.none )

        UserMouseExitedSideBar ->
            ( { session | expandedSideBar = Collapsing }, Cmd.none )

        UserMouseEnteredSideBarOption button ->
            ( { session | currentlyHoveredOption = Just button }, Cmd.none )

        UserMouseExitedSideBarOption button ->
            ( { session | currentlyHoveredOption = Nothing }, Cmd.none )

        UserClickedSideBarOptionForFrontPage sidebarOption ->
            ( { session | showFrontSearchInterface = sidebarOption }
            , Nav.pushUrl session.key "/"
            )
