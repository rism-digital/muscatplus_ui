module Session exposing (..)

import Browser.Navigation as Nav
import Device exposing (detectDevice)
import Element exposing (Device)
import Flags exposing (Flags)
import Language exposing (Language, parseLocaleToLanguage)
import Page.Route exposing (Route, parseUrl)
import Page.SideBar.Msg exposing (SideBarOption(..))
import Url exposing (Url)


{-|

    The Session model holds global configuration values.
    Whereas the various Page models change with each route,
    the Session model is consistent on all routes so make it
    appropriate for storing values that affect non-page-specific
    data.

    Some views (the sidebar) use the Session as its core model,
    but this doesn't mean that the sidebar "owns" the session.

-}
type AnimatedSideBar
    = Expanding
    | Collapsing
    | NoAnimation


type alias Session =
    { key : Nav.Key
    , language : Language
    , device : Device
    , url : Url
    , route : Route
    , showMuscatLinks : Bool
    , expandedSideBar : AnimatedSideBar
    , showFrontSearchInterface : SideBarOption
    , currentlyHoveredOption : Maybe SideBarOption
    }


init : Flags -> Url -> Nav.Key -> Session
init flags url key =
    let
        language =
            flags.locale
                |> parseLocaleToLanguage

        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight

        route =
            parseUrl url

        muscatLinks =
            flags.showMuscatLinks
    in
    { key = key
    , language = language
    , device = initialDevice
    , url = url
    , route = route
    , showMuscatLinks = muscatLinks
    , expandedSideBar = NoAnimation
    , showFrontSearchInterface = SourceSearchOption
    , currentlyHoveredOption = Nothing
    }
