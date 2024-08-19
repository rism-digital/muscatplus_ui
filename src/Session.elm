module Session exposing (Session, init, updateBottomBarOptions, updateSideBarOptions)

{-|

    The Session model holds global configuration values.
    Whereas the various Page models change with each route,
    the Session model is consistent on all routes so make it
    appropriate for storing values that affect non-page-specific
    data.

    Some views (the sidebar) use the Session as its core model,
    but this doesn't mean that the sidebar "owns" the session.

-}

import Browser.Navigation as Nav
import Device exposing (detectDevice, isMobileView)
import Dict exposing (Dict)
import Element exposing (Device)
import Flags exposing (Flags)
import Json.Decode as Decode
import Language exposing (Language, LanguageMap, parseLocaleToLanguage)
import Maybe.Extra as ME
import Page.BottomBar.Options as BottomBarOptions
import Page.NavigationBar exposing (NavigationBar(..))
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..), resultModeToNavigationBarOption)
import Page.Route exposing (Route(..), parseUrl)
import Page.SideBar.Options as SideBarOptions
import SearchPreferences exposing (SearchPreferences, searchPreferencesDecoder)
import Url exposing (Url)


type alias Session =
    { key : Nav.Key
    , language : Language
    , device : Device
    , window : ( Int, Int )
    , url : Url
    , route : Route
    , showMuscatLinks : Bool
    , isFramed : Bool
    , navigationBar : NavigationBar
    , restrictedToNationalCollection : Maybe CountryCode
    , allNationalCollections : Dict CountryCode LanguageMap
    , searchPreferences : Maybe SearchPreferences
    , cacheBuster : Bool
    , showFrontSearchInterface : NavigationBarOption
    }


updateSideBarOptions : Session -> (SideBarOptions.SideBarOptions -> SideBarOptions.SideBarOptions) -> Session
updateSideBarOptions session updateFn =
    case session.navigationBar of
        SideBar options ->
            { session | navigationBar = SideBar (updateFn options) }

        BottomBar _ ->
            session


updateBottomBarOptions : Session -> (BottomBarOptions.BottomBarOptions -> BottomBarOptions.BottomBarOptions) -> Session
updateBottomBarOptions session updateFn =
    case session.navigationBar of
        BottomBar options ->
            { session | navigationBar = BottomBar (updateFn options) }

        SideBar _ ->
            session


init : Flags -> Url -> Nav.Key -> Session
init flags url key =
    let
        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight

        navigationBar =
            if isMobileView initialDevice then
                BottomBar BottomBarOptions.init

            else
                SideBar SideBarOptions.init

        initialMode =
            case route of
                FrontPageRoute qargs ->
                    resultModeToNavigationBarOption qargs.mode

                _ ->
                    SourceSearchOption

        language =
            parseLocaleToLanguage flags.locale

        nationalCollectionFromUrl =
            case route of
                FrontPageRoute qargs ->
                    qargs.nationalCollection

                SearchPageRoute qargs _ ->
                    qargs.nationalCollection

                SourceContentsPageRoute _ qargs ->
                    qargs.nationalCollection

                InstitutionSourcePageRoute _ qargs ->
                    qargs.nationalCollection

                -- nb: the person source page route is not included
                -- since the person pages are hidden when performing
                -- a national collection search.
                _ ->
                    Nothing

        nationalCollectionFilter =
            ME.unpack (\() -> flags.nationalCollection) (\_ -> nationalCollectionFromUrl) nationalCollectionFromUrl

        route =
            parseUrl url

        searchPreferences =
            Maybe.map
                (\pref ->
                    Decode.decodeValue searchPreferencesDecoder pref
                        |> Result.toMaybe
                )
                flags.searchPreferences
                |> ME.join
    in
    { key = key
    , language = language
    , device = initialDevice
    , window = ( flags.windowWidth, flags.windowHeight )
    , url = url
    , route = route
    , showMuscatLinks = flags.showMuscatLinks
    , showFrontSearchInterface = initialMode
    , isFramed = flags.isFramed
    , navigationBar = navigationBar
    , restrictedToNationalCollection = nationalCollectionFilter
    , allNationalCollections = Dict.empty
    , searchPreferences = searchPreferences
    , cacheBuster = flags.cacheBuster
    }
