module Page.Decoders exposing (recordResponseDecoder)

import Json.Decode as Decode exposing (Decoder, andThen, string)
import Page.RecordTypes
    exposing
        ( RecordType(..)
        , recordTypeFromJsonType
        )
import Page.RecordTypes.Festival exposing (liturgicalFestivalBodyDecoder)
import Page.RecordTypes.Incipit exposing (IncipitBody, incipitBodyDecoder)
import Page.RecordTypes.Institution exposing (institutionBodyDecoder)
import Page.RecordTypes.Person exposing (personBodyDecoder)
import Page.RecordTypes.Place exposing (placeBodyDecoder)
import Page.RecordTypes.Root exposing (frontBodyDecoder)
import Page.RecordTypes.Search exposing (searchBodyDecoder)
import Page.RecordTypes.Source exposing (sourceBodyDecoder)
import Page.Response exposing (ServerData(..))


recordResponseDecoder : Decoder ServerData
recordResponseDecoder =
    Decode.field "type" string
        |> andThen recordResponseConverter


festivalResponseDecoder : Decoder ServerData
festivalResponseDecoder =
    Decode.map FestivalData liturgicalFestivalBodyDecoder


sourceResponseDecoder : Decoder ServerData
sourceResponseDecoder =
    Decode.map SourceData sourceBodyDecoder


incipitResponseDecoder : Decoder ServerData
incipitResponseDecoder =
    Decode.map IncipitData incipitBodyDecoder


searchResponseDecoder : Decoder ServerData
searchResponseDecoder =
    Decode.map SearchData searchBodyDecoder


institutionResponseDecoder : Decoder ServerData
institutionResponseDecoder =
    Decode.map InstitutionData institutionBodyDecoder


personResponseDecoder : Decoder ServerData
personResponseDecoder =
    Decode.map PersonData personBodyDecoder


placeResponseDecoder : Decoder ServerData
placeResponseDecoder =
    Decode.map PlaceData placeBodyDecoder


rootResponseDecoder : Decoder ServerData
rootResponseDecoder =
    Decode.map RootData frontBodyDecoder


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

        Festival ->
            festivalResponseDecoder

        Incipit ->
            incipitResponseDecoder

        CollectionSearchResult ->
            searchResponseDecoder

        Root ->
            rootResponseDecoder

        -- TODO: This is obviously wrong! Fix it with the actual response types
        --       once we have a clear idea of what they are.
        Unknown ->
            sourceResponseDecoder
