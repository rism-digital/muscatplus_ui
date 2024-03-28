module Session exposing (Session, init)

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
import Debouncer.Messages as Debouncer exposing (Debouncer, fromSeconds)
import Device exposing (detectDevice)
import Dict exposing (Dict)
import Element exposing (Device)
import Flags exposing (Flags)
import Json.Decode as Decode
import Language exposing (Language, LanguageMap, parseLocaleToLanguage)
import Maybe.Extra as ME
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.Route exposing (Route(..), parseUrl)
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg, SideBarOption(..), resultModeToSideBarOption, sideBarExpandDelay)
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
    , expandedSideBar : SideBarAnimationStatus
    , sideBarExpansionDebouncer : Debouncer SideBarMsg
    , nationalCollectionChooserDebouncer : Debouncer SideBarMsg
    , showFrontSearchInterface : SideBarOption
    , currentlyHoveredOption : Maybe SideBarOption
    , currentlyHoveredNationalCollectionChooser : Bool
    , currentlyHoveredNationalCollectionSidebarOption : Bool
    , currentlyHoveredAboutMenuSidebarOption : Bool
    , currentlyHoveredAboutMenuChooser : Bool
    , currentlyHoveredLanguageChooser : Bool
    , currentlyHoveredLanguageChooserSidebarOption : Bool
    , restrictedToNationalCollection : Maybe CountryCode
    , allNationalCollections : Dict CountryCode LanguageMap
    , searchPreferences : Maybe SearchPreferences
    }


init : Flags -> Url -> Nav.Key -> Session
init flags url key =
    let
        initialDevice =
            detectDevice flags.windowWidth flags.windowHeight

        initialMode =
            case route of
                FrontPageRoute qargs ->
                    resultModeToSideBarOption qargs.mode

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
    , expandedSideBar = NoAnimation
    , isFramed = flags.isFramed
    , sideBarExpansionDebouncer = Debouncer.debounce sideBarExpandDelay |> Debouncer.toDebouncer
    , nationalCollectionChooserDebouncer = Debouncer.debounce (fromSeconds 0.8) |> Debouncer.toDebouncer
    , showFrontSearchInterface = initialMode
    , currentlyHoveredOption = Nothing
    , currentlyHoveredNationalCollectionChooser = False
    , currentlyHoveredNationalCollectionSidebarOption = False
    , currentlyHoveredAboutMenuSidebarOption = False
    , currentlyHoveredAboutMenuChooser = False
    , currentlyHoveredLanguageChooser = False
    , currentlyHoveredLanguageChooserSidebarOption = False
    , restrictedToNationalCollection = nationalCollectionFilter
    , allNationalCollections = Dict.empty
    , searchPreferences = searchPreferences
    }
