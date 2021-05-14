module Model exposing (Model, init)

import Api exposing (Model)
import Api.Query exposing (defaultQueryArgs)
import Browser.Navigation as Nav
import Device exposing (detectDevice)
import Element exposing (Device)
import Flags exposing (Flags)
import Language exposing (Language, parseLocaleToLanguage)
import Routes exposing (Route(..))
import Search exposing (Model)
import Url exposing (Url)


type alias Model =
    { response : Api.Model
    , search : Search.Model
    , route : Routes.Model
    , errorMessage : String
    , language : Language
    , viewingDevice : Device
    }


{-|

    The initial model state

-}
init : Flags -> Url -> Nav.Key -> Model
init flags initialUrl key =
    let
        language =
            flags.locale
                |> parseLocaleToLanguage

        initialRoute =
            Routes.init initialUrl key

        initialQuery =
            case initialRoute.currentRoute of
                SearchPageRoute queryargs ->
                    queryargs

                _ ->
                    defaultQueryArgs

        initialMode =
            initialQuery.mode

        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight

        initialSearch =
            Search.init initialMode initialQuery
    in
    { route = initialRoute
    , search = initialSearch
    , response = Api.Loading
    , errorMessage = ""
    , language = language
    , viewingDevice = initialDevice
    }
