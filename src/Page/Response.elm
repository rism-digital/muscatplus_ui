module Page.Response exposing (..)

import Page.RecordTypes.Festival exposing (FestivalBody)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Place exposing (PlaceBody)
import Page.RecordTypes.Root exposing (RootBody)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.RecordTypes.Source exposing (FullSourceBody)


type ServerData
    = SourceData FullSourceBody
    | PersonData PersonBody
    | InstitutionData InstitutionBody
    | PlaceData PlaceBody
    | FestivalData FestivalBody
    | SearchData SearchBody
    | IncipitData IncipitBody
    | RootData RootBody


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
