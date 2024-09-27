module Page.NavigationBar exposing (NavigationBar(..))

import Page.BottomBar.Options exposing (BottomBarOptions)
import Page.SideBar.Options exposing (SideBarOptions)


type NavigationBar
    = SideBar SideBarOptions
    | BottomBar BottomBarOptions
