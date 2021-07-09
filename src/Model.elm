module Model exposing (..)

import Browser.Navigation as Nav
import Device exposing (detectDevice)
import Element exposing (Device)
import Flags exposing (Flags)
import Language exposing (Language, parseLocaleToLanguage)
import Msg exposing (Msg)
import Page
import Search exposing (ActiveSearch)
import Url exposing (Url)


type alias Model =
    { page : Page.Model
    , device : Device
    , language : Language
    , activeSearch : ActiveSearch
    , key : Nav.Key
    , showMuscatLinks : Bool
    }


{-|

    The initial model state

-}
init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags initialUrl key =
    let
        language =
            flags.locale
                |> parseLocaleToLanguage

        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight

        initialPage =
            Page.init initialUrl

        initialSearch =
            Search.init initialPage.route

        initialCmd =
            Page.initialCmd initialUrl
    in
    ( { page = initialPage
      , device = initialDevice
      , language = language
      , activeSearch = initialSearch
      , key = key
      , showMuscatLinks = flags.showMuscatLinks
      }
    , initialCmd
    )
