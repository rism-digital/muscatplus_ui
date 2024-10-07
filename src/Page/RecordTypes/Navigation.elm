module Page.RecordTypes.Navigation exposing (NavigationBarOption(..), navigationBarOptionToModeString, navigationBarOptionToResultMode, resultModeToNavigationBarOption)

import Page.RecordTypes.ResultMode exposing (ResultMode(..))


type NavigationBarOption
    = SourceSearchOption
    | PeopleSearchOption
    | InstitutionSearchOption
    | IncipitSearchOption


resultModeToNavigationBarOption : ResultMode -> NavigationBarOption
resultModeToNavigationBarOption mode =
    case mode of
        SourcesMode ->
            SourceSearchOption

        PeopleMode ->
            PeopleSearchOption

        InstitutionsMode ->
            InstitutionSearchOption

        IncipitsMode ->
            IncipitSearchOption


navigationBarOptionToModeString : NavigationBarOption -> String
navigationBarOptionToModeString option =
    case option of
        SourceSearchOption ->
            "sources"

        PeopleSearchOption ->
            "people"

        InstitutionSearchOption ->
            "institutions"

        IncipitSearchOption ->
            "incipits"


navigationBarOptionToResultMode : NavigationBarOption -> ResultMode
navigationBarOptionToResultMode option =
    case option of
        SourceSearchOption ->
            SourcesMode

        PeopleSearchOption ->
            PeopleMode

        InstitutionSearchOption ->
            InstitutionsMode

        IncipitSearchOption ->
            IncipitsMode
