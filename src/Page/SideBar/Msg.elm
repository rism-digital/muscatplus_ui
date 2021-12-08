module Page.SideBar.Msg exposing (..)


type SideBarMsg
    = UserMouseEnteredSideBar
    | UserMouseExitedSideBar
    | UserClickedSideBarOptionForFrontPage SideBarOption
    | UserMouseEnteredSideBarOption SideBarOption
    | UserMouseExitedSideBarOption SideBarOption
    | UserChangedLanguageSelect String


type SideBarOption
    = SourceSearchOption
    | PeopleSearchOption
    | InstitutionSearchOption
    | IncipitSearchOption
