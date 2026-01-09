module Page.RecordTypes.SearchControl exposing (SearchControlOptions(..), navigationBarOptionToResultMode, resultModeToSearchControlOption, searchControlOptionToModeString)

import Page.RecordTypes.ResultMode exposing (ResultMode(..))


type SearchControlOptions
    = SourceSearchOption
    | PeopleSearchOption
    | InstitutionSearchOption
    | IncipitSearchOption
    | WorkCatalogueNavigateOption
    | EmptyOption


resultModeToSearchControlOption : ResultMode -> SearchControlOptions
resultModeToSearchControlOption mode =
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

        _ ->
            SourceSearchOption


searchControlOptionToModeString : SearchControlOptions -> String
searchControlOptionToModeString option =
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

        EmptyOption ->
            ""


navigationBarOptionToResultMode : SearchControlOptions -> ResultMode
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

        EmptyOption ->
            EmptyMode
