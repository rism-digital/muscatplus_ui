module Page.SideBar.Msg exposing (..)

import Debouncer.Messages as Debouncer
import Dict exposing (Dict)
import Http
import Http.Detailed
import Language exposing (LanguageMap)
import Page.RecordTypes.Countries exposing (CountryCode)


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
    | UserChoseNationalCollection (Maybe CountryCode)
    | UserChangedLanguageSelect String


type SideBarOption
    = SourceSearchOption
    | PeopleSearchOption
    | InstitutionSearchOption
    | IncipitSearchOption
