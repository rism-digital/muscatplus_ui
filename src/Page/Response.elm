module Page.Response exposing (..)

import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody)
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
    | FestivalData LiturgicalFestivalBody
    | SearchData SearchBody
    | IncipitData IncipitBody
    | RootData RootBody
