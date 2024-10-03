module Page.NavigationBar exposing (NavigationBar(..), setNavigationBar)

import Page.BottomBar.Options exposing (BottomBarOptions)
import Page.SideBar.Options exposing (SideBarOptions)


type NavigationBar
    = SideBar SideBarOptions
    | BottomBar BottomBarOptions


setNavigationBar : NavigationBar -> { a | navigationBar : NavigationBar } -> { a | navigationBar : NavigationBar }
setNavigationBar newNav oldRecord =
    { oldRecord | navigationBar = newNav }
