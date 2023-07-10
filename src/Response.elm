module Response exposing (Response(..), ServerData(..))

import Http.Detailed
import Page.RecordTypes.About exposing (AboutBody)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecordBody)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.RecordTypes.Place exposing (PlaceBody)
import Page.RecordTypes.Search exposing (SearchBody)
import Page.RecordTypes.Source exposing (FullSourceBody)


{-|

    The `Loading` parameter takes a "Maybe data" that can keep a
    previous page state around. This allows the browser to keep the page
    rendered while new data is being fetched.

-}
type Response data
    = Loading (Maybe data)
    | Response data
    | Error (Http.Detailed.Error String)
    | NoResponseToShow


type ServerData
    = SourceData FullSourceBody
    | PersonData PersonBody
    | InstitutionData InstitutionBody
    | PlaceData PlaceBody
    | SearchData SearchBody
    | IncipitData IncipitBody
    | FrontData FrontBody
    | AboutData AboutBody
    | ExternalData ExternalRecordBody
