module Api.Decoders exposing (..)

import Api.RecordTypes exposing (FestivalBody, FullSourceBody, IncipitBody, InstitutionBody, PersonBody, PlaceBody, RecordType(..), SearchBody, recordTypeFromJsonType)
import Api.Response exposing (ServerResponse(..))
import Json.Decode as Decode exposing (Decoder, andThen, string)


festivalResponseDecoder : Decoder ServerResponse
festivalResponseDecoder =
    Decode.map FestivalResponse festivalBodyDecoder


incipitResponseDecoder : Decoder ServerResponse
incipitResponseDecoder =
    Decode.map IncipitResponse incipitBodyDecoder


institutionResponseDecoder : Decoder ServerResponse
institutionResponseDecoder =
    Decode.map InstitutionResponse institutionBodyDecoder


personResponseDecoder : Decoder ServerResponse
personResponseDecoder =
    Decode.map PersonResponse personBodyDecoder


placeResponseDecoder : Decoder ServerResponse
placeResponseDecoder =
    Decode.map PlaceResponse placeBodyDecoder


sourceResponseDecoder : Decoder ServerResponse
sourceResponseDecoder =
    Decode.map SourceResponse sourceBodyDecoder


searchResponseDecoder : Decoder ServerResponse
searchResponseDecoder =
    Decode.map SearchResponse searchBodyDecoder


sourceBodyDecoder : Decoder FullSourceBody
sourceBodyDecoder =
    Decode.succeed FullSourceBody


searchBodyDecoder : Decoder SearchBody
searchBodyDecoder =
    Decode.succeed SearchBody


festivalBodyDecoder : Decoder FestivalBody
festivalBodyDecoder =
    Decode.succeed FestivalBody


incipitBodyDecoder : Decoder IncipitBody
incipitBodyDecoder =
    Decode.succeed IncipitBody


institutionBodyDecoder : Decoder InstitutionBody
institutionBodyDecoder =
    Decode.succeed InstitutionBody


personBodyDecoder : Decoder PersonBody
personBodyDecoder =
    Decode.succeed PersonBody


placeBodyDecoder : Decoder PlaceBody
placeBodyDecoder =
    Decode.succeed PlaceBody


recordResponseDecoder : Decoder ServerResponse
recordResponseDecoder =
    Decode.field "type" string
        |> andThen recordResponseConverter


recordResponseConverter : String -> Decoder ServerResponse
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

        -- TODO: This is obviously wrong! Fix it with the actual response types
        --       once we have a clear idea of what they are.
        Unknown ->
            sourceResponseDecoder
