module Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), SideBarOption(..), resultModeToSideBarOption, showSideBarLabels, sideBarExpandDelay, sideBarOptionToModeString, sideBarOptionToResultMode)

import Debouncer.Messages as Debouncer
import Dict exposing (Dict)
import Http
import Http.Detailed
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
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
    | UserClickedSideBarOptionForFrontPage SideBarOption
    | UserMouseEnteredSideBarOption SideBarOption
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


type SideBarOption
    = SourceSearchOption
    | PeopleSearchOption
    | InstitutionSearchOption
    | IncipitSearchOption
    | LiturgicalFestivalsOption


resultModeToSideBarOption : ResultMode -> SideBarOption
resultModeToSideBarOption mode =
    case mode of
        SourcesMode ->
            SourceSearchOption

        PeopleMode ->
            PeopleSearchOption

        InstitutionsMode ->
            InstitutionSearchOption

        IncipitsMode ->
            IncipitSearchOption

        LiturgicalFestivalsMode ->
            LiturgicalFestivalsOption


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


sideBarOptionToModeString : SideBarOption -> String
sideBarOptionToModeString option =
    case option of
        SourceSearchOption ->
            "sources"

        PeopleSearchOption ->
            "people"

        InstitutionSearchOption ->
            "institutions"

        IncipitSearchOption ->
            "incipits"

        LiturgicalFestivalsOption ->
            "festivals"


sideBarOptionToResultMode : SideBarOption -> ResultMode
sideBarOptionToResultMode option =
    case option of
        SourceSearchOption ->
            SourcesMode

        PeopleSearchOption ->
            PeopleMode

        InstitutionSearchOption ->
            InstitutionsMode

        IncipitSearchOption ->
            IncipitsMode

        LiturgicalFestivalsOption ->
            LiturgicalFestivalsMode
