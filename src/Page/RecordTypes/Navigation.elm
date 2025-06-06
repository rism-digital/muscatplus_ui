module Page.RecordTypes.Navigation exposing (NavigationBarOption(..), navigationBarOptionToModeString, navigationBarOptionToResultMode, resultModeToNavigationBarOption)

import Page.RecordTypes.ResultMode exposing (ResultMode(..))


type NavigationBarOption
    = SourceSearchOption
    | PeopleSearchOption
    | InstitutionSearchOption
    | IncipitSearchOption
    | WorkCatalogueNavigateOption


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

        WorkCatalogueMode ->
            WorkCatalogueNavigateOption


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

        WorkCatalogueNavigateOption ->
            "publications"


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

        WorkCatalogueNavigateOption ->
            WorkCatalogueMode
