module Page.Decoders exposing (aboutResponseDecoder, recordResponseDecoder)

import Json.Decode as Decode exposing (Decoder, andThen, string)
import Page.RecordTypes
    exposing
        ( RecordType(..)
        , recordTypeFromJsonType
        )
import Page.RecordTypes.About exposing (aboutBodyDecoder)
import Page.RecordTypes.Front exposing (frontBodyDecoder)
import Page.RecordTypes.Incipit exposing (incipitBodyDecoder)
import Page.RecordTypes.Institution exposing (institutionBodyDecoder)
import Page.RecordTypes.Person exposing (personBodyDecoder)
import Page.RecordTypes.Place exposing (placeBodyDecoder)
import Page.RecordTypes.Search exposing (searchBodyDecoder)
import Page.RecordTypes.Source exposing (sourceBodyDecoder)
import Response exposing (ServerData(..))


aboutResponseDecoder : Decoder ServerData
aboutResponseDecoder =
    Decode.map AboutData aboutBodyDecoder


recordResponseDecoder : Decoder ServerData
recordResponseDecoder =
    Decode.field "type" string
        |> andThen recordResponseConverter


frontResponseDecoder : Decoder ServerData
frontResponseDecoder =
    Decode.map FrontData frontBodyDecoder


incipitResponseDecoder : Decoder ServerData
incipitResponseDecoder =
    Decode.map IncipitData incipitBodyDecoder


institutionResponseDecoder : Decoder ServerData
institutionResponseDecoder =
    Decode.map InstitutionData institutionBodyDecoder


personResponseDecoder : Decoder ServerData
personResponseDecoder =
    Decode.map PersonData personBodyDecoder


placeResponseDecoder : Decoder ServerData
placeResponseDecoder =
    Decode.map PlaceData placeBodyDecoder


recordResponseConverter : String -> Decoder ServerData
recordResponseConverter typevalue =
    case recordTypeFromJsonType typevalue of
        Source ->
            sourceResponseDecoder

        Person ->
            personResponseDecoder

        Institution ->
            institutionResponseDecoder

        Place ->
            placeResponseDecoder

        Incipit ->
            incipitResponseDecoder

        CollectionSearchResult ->
            searchResponseDecoder

        Front ->
            frontResponseDecoder

        -- TODO: This is obviously wrong! Fix it with the actual response types
        --       once we have a clear idea of what they are.
        Unknown ->
            sourceResponseDecoder


searchResponseDecoder : Decoder ServerData
searchResponseDecoder =
    Decode.map SearchData searchBodyDecoder


sourceResponseDecoder : Decoder ServerData
sourceResponseDecoder =
    Decode.map SourceData sourceBodyDecoder
