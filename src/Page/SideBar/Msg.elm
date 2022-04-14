module Page.SideBar.Msg exposing (..)

import Debouncer.Messages as Debouncer
import Dict exposing (Dict)
import Http
import Http.Detailed
import Language exposing (LanguageMap)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.RecordTypes.ResultMode exposing (ResultMode(..))


type SideBarMsg
    = ServerRespondedWithCountryCodeList (Result (Http.Detailed.Error String) ( Http.Metadata, Dict CountryCode LanguageMap ))
    | ClientDebouncedSideBarMessages (Debouncer.Msg SideBarMsg)
    | UserMouseEnteredSideBar
    | UserMouseExitedSideBar
    | UserClickedSideBarOptionForFrontPage SideBarOption
    | UserMouseEnteredSideBarOption SideBarOption
    | UserMouseExitedSideBarOption SideBarOption
    | UserMouseEnteredCountryChooser
    | UserMouseExitedCountryChooser
    | UserMouseDownOnLanguageChooser
    | UserMouseUpOnLanguageChooser
    | UserChoseNationalCollection (Maybe CountryCode)
    | UserChangedLanguageSelect String


type SideBarOption
    = SourceSearchOption
    | PeopleSearchOption
    | InstitutionSearchOption
    | IncipitSearchOption
    | LiturgicalFestivalsOption


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
