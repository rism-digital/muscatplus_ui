module Page.RecordTypes.ExternalRecord exposing (ExternalProject(..), ExternalRecord(..), ExternalRecordBody, externalRecordBodyDecoder)

import Json.Decode as Decode exposing (Decoder, andThen, string)
import Json.Decode.Pipeline exposing (required)
import Page.RecordTypes.Institution exposing (BasicInstitutionBody, InstitutionBody, basicInstitutionBodyDecoder)
import Page.RecordTypes.Person exposing (PersonBody, personBodyDecoder)
import Page.RecordTypes.Source exposing (FullSourceBody, sourceBodyDecoder)


type ExternalProject
    = DIAMM
    | Cantus
    | RISM -- used as a default value


type ExternalRecord
    = ExternalSource FullSourceBody
    | ExternalPerson PersonBody
    | ExternalInstitution BasicInstitutionBody


type alias ExternalRecordBody =
    { id : String
    , record : ExternalRecord
    , project : ExternalProject
    }


externalRecordBodyDecoder : Decoder ExternalRecordBody
externalRecordBodyDecoder =
    Decode.succeed ExternalRecordBody
        |> required "id" string
        |> required "record"
            (Decode.field "type" string
                |> andThen externalRecordDecoder
            )
        |> required "project"
            (string
                |> andThen externalProjectDecoder
            )


externalRecordDecoder : String -> Decoder ExternalRecord
externalRecordDecoder recordType =
    case recordType of
        "rism:Institution" ->
            Decode.map ExternalInstitution basicInstitutionBodyDecoder

        "rism:Person" ->
            Decode.map ExternalPerson personBodyDecoder

        "rism:Source" ->
            Decode.map ExternalSource sourceBodyDecoder

        _ ->
            Decode.fail "Could not decode the external record body"


externalProjectDecoder : String -> Decoder ExternalProject
externalProjectDecoder extProj =
    case extProj of
        "https://www.diamm.ac.uk/" ->
            Decode.succeed DIAMM

        "https://cantusdatabase.org/" ->
            Decode.succeed Cantus

        _ ->
            Decode.succeed RISM
