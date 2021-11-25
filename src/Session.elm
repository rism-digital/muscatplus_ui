module Session exposing (..)

import Browser.Navigation as Nav
import Device exposing (detectDevice)
import Element exposing (Device)
import Flags exposing (Flags)
import Language exposing (Language, parseLocaleToLanguage)
import Page.Route exposing (Route, parseUrl)
import Url exposing (Url)


type alias Session =
    { key : Nav.Key
    , language : Language
    , device : Device
    , url : Url
    , route : Route
    , showMuscatLinks : Bool
    , expandedSidebar : Bool
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
    , expandedSidebar = False
    }
