module Page.BottomBar.Msg exposing (BottomBarMsg(..))

import Page.RecordTypes.Navigation exposing (NavigationBarOption)


type BottomBarMsg
    = UserTouchedBottomBarOptionForFrontPage NavigationBarOption
