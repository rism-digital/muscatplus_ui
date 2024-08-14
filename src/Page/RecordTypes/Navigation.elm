module Page.RecordTypes.Navigation exposing (..)

import Page.RecordTypes.ResultMode exposing (ResultMode(..))


type NavigationBarOption
    = SourceSearchOption
    | PeopleSearchOption
    | InstitutionSearchOption
    | IncipitSearchOption
    | LiturgicalFestivalsOption


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

        LiturgicalFestivalsMode ->
            LiturgicalFestivalsOption


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

        LiturgicalFestivalsOption ->
            "festivals"


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

        LiturgicalFestivalsOption ->
            LiturgicalFestivalsMode
