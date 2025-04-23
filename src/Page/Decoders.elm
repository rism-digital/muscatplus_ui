module Page.Decoders exposing (recordResponseDecoder)

import Json.Decode exposing (Decoder, andThen, fail, field, map, string)
import Page.RecordTypes
    exposing
        ( RecordType(..)
        , recordTypeFromJsonType
        )
import Page.RecordTypes.ExternalRecord exposing (externalRecordBodyDecoder)
import Page.RecordTypes.Front exposing (frontBodyDecoder)
import Page.RecordTypes.Holding exposing (holdingBodyDecoder)
import Page.RecordTypes.Incipit exposing (incipitBodyDecoder)
import Page.RecordTypes.Institution exposing (institutionBodyDecoder)
import Page.RecordTypes.Person exposing (personBodyDecoder)
import Page.RecordTypes.Search exposing (searchBodyDecoder)
import Page.RecordTypes.Source exposing (sourceBodyDecoder)
import Response exposing (ServerData(..))


recordResponseDecoder : Decoder ServerData
recordResponseDecoder =
    field "type" string
        |> andThen recordResponseConverter


recordResponseConverter : String -> Decoder ServerData
recordResponseConverter typevalue =
    case recordTypeFromJsonType typevalue of
        Source ->
            map SourceData sourceBodyDecoder

        Person ->
            map PersonData personBodyDecoder

        Institution ->
            map InstitutionData institutionBodyDecoder

        Holding ->
            map HoldingData holdingBodyDecoder

        Incipit ->
            map IncipitData incipitBodyDecoder

        CollectionSearchResult ->
            map SearchData searchBodyDecoder

        Front ->
            map FrontData frontBodyDecoder

        ExternalRecord ->
            map ExternalData externalRecordBodyDecoder

        _ ->
            fail "Could not decode record body response"
