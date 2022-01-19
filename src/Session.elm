module Session exposing (..)

import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer exposing (Debouncer)
import Device exposing (detectDevice)
import Dict exposing (Dict)
import Element exposing (Device)
import Flags exposing (Flags)
import Language exposing (Language, LanguageMap, parseLocaleToLanguage)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.Route exposing (Route(..), parseUrl)
import Page.SideBar.Msg exposing (SideBarMsg, SideBarOption(..))
import Url exposing (Url)


sideBarExpandDelay : Int
sideBarExpandDelay =
    250


{-|

    The Session model holds global configuration values.
    Whereas the various Page models change with each route,
    the Session model is consistent on all routes so make it
    appropriate for storing values that affect non-page-specific
    data.

    Some views (the sidebar) use the Session as its core model,
    but this doesn't mean that the sidebar "owns" the session.

-}
type SideBarAnimationStatus
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
    , expandedSideBar : SideBarAnimationStatus
    , sideBarExpansionDebouncer : Debouncer SideBarMsg
    , showFrontSearchInterface : SideBarOption
    , currentlyHoveredOption : Maybe SideBarOption
    , currentlyHoveredNationalCollectionChooser : Bool
    , restrictedToNationalCollection : Maybe CountryCode
    , allNationalCollections : Dict CountryCode LanguageMap
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

        initialMode =
            case route of
                FrontPageRoute qargs ->
                    case qargs.mode of
                        SourcesMode ->
                            SourceSearchOption

                        PeopleMode ->
                            PeopleSearchOption

                        InstitutionsMode ->
                            InstitutionSearchOption

                        IncipitsMode ->
                            IncipitSearchOption

                        _ ->
                            SourceSearchOption

                _ ->
                    SourceSearchOption

        nationalCollectionFromUrl =
            case route of
                FrontPageRoute qargs ->
                    qargs.nationalCollection

                _ ->
                    Nothing

        nationalCollectionFromLocalStorage =
            flags.nationalCollection

        muscatLinks =
            flags.showMuscatLinks

        nationalCollectionFilter =
            if nationalCollectionFromUrl /= Nothing then
                nationalCollectionFromUrl

            else if nationalCollectionFromLocalStorage /= Nothing then
                nationalCollectionFromLocalStorage

            else
                Nothing
    in
    { key = key
    , language = language
    , device = initialDevice
    , url = url
    , route = route
    , showMuscatLinks = muscatLinks
    , expandedSideBar = NoAnimation
    , sideBarExpansionDebouncer = Debouncer.debounce sideBarExpandDelay |> Debouncer.toDebouncer
    , showFrontSearchInterface = initialMode
    , currentlyHoveredOption = Nothing
    , currentlyHoveredNationalCollectionChooser = False
    , restrictedToNationalCollection = nationalCollectionFilter
    , allNationalCollections = Dict.empty
    }
