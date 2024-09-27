module Page.SideBar.Options exposing (SideBarOptions, init, updateCurrentlyHoveredAboutMenuSidebarOption, updateCurrentlyHoveredLanguageChooserSidebarOption, updateCurrentlyHoveredNationalCollectionSidebarOption, updateCurrentlyHoveredNationalCollectionStatus, updateCurrentlyHoveredStatus, updateExpansionStatus, updateNationalCollectionChooserDebouncer, updateSideBarExpansionDebouncer)

import Debouncer.Messages as Debouncer exposing (Debouncer, fromSeconds)
import Page.RecordTypes.Navigation exposing (NavigationBarOption)
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg, sideBarExpandDelay)


type alias SideBarOptions =
    { expandedSideBar : SideBarAnimationStatus
    , sideBarExpansionDebouncer : Debouncer SideBarMsg
    , nationalCollectionChooserDebouncer : Debouncer SideBarMsg
    , currentlyHoveredOption : Maybe NavigationBarOption
    , currentlyHoveredNationalCollectionChooser : Bool
    , currentlyHoveredNationalCollectionSidebarOption : Bool
    , currentlyHoveredAboutMenuSidebarOption : Bool
    , currentlyHoveredAboutMenuChooser : Bool
    , currentlyHoveredLanguageChooser : Bool
    , currentlyHoveredLanguageChooserSidebarOption : Bool
    }


init : SideBarOptions
init =
    { expandedSideBar = NoAnimation
    , sideBarExpansionDebouncer = Debouncer.debounce sideBarExpandDelay |> Debouncer.toDebouncer
    , nationalCollectionChooserDebouncer = Debouncer.debounce (fromSeconds 0.8) |> Debouncer.toDebouncer
    , currentlyHoveredOption = Nothing
    , currentlyHoveredNationalCollectionChooser = False
    , currentlyHoveredNationalCollectionSidebarOption = False
    , currentlyHoveredAboutMenuSidebarOption = False
    , currentlyHoveredAboutMenuChooser = False
    , currentlyHoveredLanguageChooser = False
    , currentlyHoveredLanguageChooserSidebarOption = False
    }


updateExpansionStatus : SideBarAnimationStatus -> SideBarOptions -> SideBarOptions
updateExpansionStatus status options =
    { options | expandedSideBar = status }


updateCurrentlyHoveredStatus : Maybe NavigationBarOption -> SideBarOptions -> SideBarOptions
updateCurrentlyHoveredStatus status options =
    { options | currentlyHoveredOption = status }


updateCurrentlyHoveredNationalCollectionStatus : Bool -> SideBarOptions -> SideBarOptions
updateCurrentlyHoveredNationalCollectionStatus status options =
    { options | currentlyHoveredNationalCollectionChooser = status }


updateCurrentlyHoveredNationalCollectionSidebarOption : Bool -> SideBarOptions -> SideBarOptions
updateCurrentlyHoveredNationalCollectionSidebarOption status options =
    { options | currentlyHoveredNationalCollectionSidebarOption = status }


updateCurrentlyHoveredAboutMenuSidebarOption : Bool -> SideBarOptions -> SideBarOptions
updateCurrentlyHoveredAboutMenuSidebarOption status options =
    { options | currentlyHoveredAboutMenuSidebarOption = status }


updateCurrentlyHoveredLanguageChooserSidebarOption : Bool -> SideBarOptions -> SideBarOptions
updateCurrentlyHoveredLanguageChooserSidebarOption status options =
    { options | currentlyHoveredLanguageChooserSidebarOption = status }


updateSideBarExpansionDebouncer : Debouncer SideBarMsg -> SideBarOptions -> SideBarOptions
updateSideBarExpansionDebouncer status options =
    { options | sideBarExpansionDebouncer = status }


updateNationalCollectionChooserDebouncer : Debouncer SideBarMsg -> SideBarOptions -> SideBarOptions
updateNationalCollectionChooserDebouncer status options =
    { options | nationalCollectionChooserDebouncer = status }
