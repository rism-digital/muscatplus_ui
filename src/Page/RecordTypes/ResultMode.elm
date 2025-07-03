module Page.RecordTypes.ResultMode exposing
    ( ResultMode(..)
    , parseStringToResultMode
    , resultModeHeader
    , resultModeOptions
    )

import Dict
import Language exposing (LanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)


type ResultMode
    = SourcesMode
    | PeopleMode
    | InstitutionsMode
    | IncipitsMode
    | WorkCatalogueMode
    | NoMode


{-|

    Takes a string and parses it to a result mode type. If one is not found
    then it assumes 'everything' is the default.

-}
parseStringToResultMode : String -> ResultMode
parseStringToResultMode string =
    Dict.fromList resultModeOptions
        |> Dict.get string
        |> Maybe.withDefault NoMode


resultModeOptions : List ( String, ResultMode )
resultModeOptions =
    [ ( "sources", SourcesMode )
    , ( "people", PeopleMode )
    , ( "institutions", InstitutionsMode )
    , ( "incipits", IncipitsMode )
    ]


resultModeHeader : ResultMode -> LanguageMap
resultModeHeader mode =
    case mode of
        SourcesMode ->
            localTranslations.sources

        PeopleMode ->
            localTranslations.people

        InstitutionsMode ->
            localTranslations.institutions

        IncipitsMode ->
            localTranslations.incipits

        WorkCatalogueMode ->
            localTranslations.workCatalogues

        NoMode ->
            toLanguageMap "No mode."
