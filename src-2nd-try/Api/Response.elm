module Api.Response exposing (..)

import Api.RecordTypes exposing (FestivalBody, FullSourceBody, IncipitBody, InstitutionBody, PersonBody, PlaceBody, SearchBody)


type ServerResponse
    = SourceResponse FullSourceBody
    | PersonResponse PersonBody
    | InstitutionResponse InstitutionBody
    | PlaceResponse PlaceBody
    | FestivalResponse FestivalBody
    | SearchResponse SearchBody
    | IncipitResponse IncipitBody


type ResultMode
    = SourcesMode
    | PeopleMode
    | InstitutionsMode
    | IncipitsMode
    | LiturgicalFestivalsMode


{-|

    Takes a string and parses it to a result mode type. If one is not found
    then it assumes 'everything' is the default.

-}
parseStringToResultMode : String -> ResultMode
parseStringToResultMode string =
    List.filter (\( str, _ ) -> str == string) resultModeOptions
        |> List.head
        |> Maybe.withDefault ( "sources", SourcesMode )
        |> Tuple.second


parseResultModeToString : ResultMode -> String
parseResultModeToString mode =
    List.filter (\( _, m ) -> m == mode) resultModeOptions
        |> List.head
        |> Maybe.withDefault ( "sources", SourcesMode )
        |> Tuple.first


resultModeOptions : List ( String, ResultMode )
resultModeOptions =
    [ ( "sources", SourcesMode )
    , ( "people", PeopleMode )
    , ( "institutions", InstitutionsMode )
    , ( "incipits", IncipitsMode )
    , ( "festivals", LiturgicalFestivalsMode )
    ]
