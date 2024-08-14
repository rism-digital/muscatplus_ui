module Page.BottomBar exposing (..)

import Browser.Navigation as Nav
import Page.BottomBar.Msg exposing (BottomBarMsg(..))
import Page.Query exposing (buildFrontPageUrl)
import Session exposing (Session)


type alias Msg =
    BottomBarMsg


update : BottomBarMsg -> Session -> ( Session, Cmd BottomBarMsg )
update msg session =
    case msg of
        UserTouchedBottomBarOptionForFrontPage bottomBarOption ->
            ( { session
                | showFrontSearchInterface = bottomBarOption
              }
            , buildFrontPageUrl bottomBarOption session.restrictedToNationalCollection
                |> Nav.pushUrl session.key
            )
