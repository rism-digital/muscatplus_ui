module Response exposing (..)

import Page.RecordTypes.Festival exposing (LiturgicalFestivalBody)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Place exposing (PlaceBody)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.RecordTypes.Source exposing (FullSourceBody)


{-|

    The `Loading` parameter takes a "Maybe ServerData" that can keep a
    previous page state around. This allows the browser to keep the page
    rendered while new data is being fetched.

-}
type Response
    = Loading (Maybe ServerData)
    | Response ServerData
    | Error String
    | NoResponseToShow


type ServerData
    = SourceData FullSourceBody
    | PersonData PersonBody
    | InstitutionData InstitutionBody
    | PlaceData PlaceBody
    | FestivalData LiturgicalFestivalBody
    | SearchData SearchBody
    | IncipitData IncipitBody
    | FrontData FrontBody
