module Page.RecordTypes.ResultMode exposing
    ( ResultMode(..)
    , parseResultModeToString
    , parseStringToResultMode
    , resultModeHeader
    )

import Dict
import Language exposing (LanguageMap)
import Language.LocalTranslations exposing (localTranslations)


type ResultMode
    = SourcesMode
    | PeopleMode
    | InstitutionsMode
    | IncipitsMode


parseResultModeToString : ResultMode -> String
parseResultModeToString mode =
    List.filter (\( _, m ) -> m == mode) resultModeOptions
        |> List.head
        |> Maybe.withDefault ( "sources", SourcesMode )
        |> Tuple.first


{-|

    Takes a string and parses it to a result mode type. If one is not found
    then it assumes 'everything' is the default.

-}
parseStringToResultMode : String -> ResultMode
parseStringToResultMode string =
    Dict.fromList resultModeOptions
        |> Dict.get string
        |> Maybe.withDefault SourcesMode


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
