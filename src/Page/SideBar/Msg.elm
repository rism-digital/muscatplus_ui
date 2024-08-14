module Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), showSideBarLabels, sideBarExpandDelay)

import Debouncer.Messages as Debouncer
import Dict exposing (Dict)
import Http
import Http.Detailed
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import SearchPreferences exposing (SearchPreferences)


type SideBarAnimationStatus
    = Expanded
    | Collapsed
    | NoAnimation


type SideBarMsg
    = ServerRespondedWithCountryCodeList (Result (Http.Detailed.Error String) ( Http.Metadata, Dict CountryCode LanguageMap ))
    | ClientDebouncedSideBarMessages (Debouncer.Msg SideBarMsg)
    | ClientDebouncedNationalCollectionChooserMessages (Debouncer.Msg SideBarMsg)
    | ClientSetSearchPreferencesThroughPort SearchPreferences
    | UserMouseEnteredSideBar
    | UserMouseExitedSideBar
    | UserClickedSideBarOptionForFrontPage NavigationBarOption
    | UserMouseEnteredSideBarOption NavigationBarOption
    | UserMouseExitedSideBarOption
    | UserMouseEnteredCountryChooser
    | UserMouseExitedCountryChooser
    | UserMouseEnteredNationalCollectionSidebarOption
    | UserMouseExitedNationalCollectionSidebarOption
    | UserMouseEnteredAboutMenuSidebarOption
    | UserMouseExitedAboutMenuSidebarOption
    | UserMouseEnteredLanguageChooserSidebarOption
    | UserMouseExitedLanguageChooserSidebarOption
    | UserChoseNationalCollection (Maybe CountryCode)
    | UserChoseLanguage Language
    | ClientUpdatedMuscatLinks Bool
    | NothingHappened


showSideBarLabels : SideBarAnimationStatus -> Bool
showSideBarLabels status =
    case status of
        Expanded ->
            True

        Collapsed ->
            False

        NoAnimation ->
            False


sideBarExpandDelay : Int
sideBarExpandDelay =
    200
