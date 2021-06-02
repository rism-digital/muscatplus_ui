module Page.RecordTypes.Institution exposing (..)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Language exposing (LanguageMap)
import Page.RecordTypes.Shared exposing (languageMapLabelDecoder)


type alias BasicInstitutionBody =
    { id : String
    , label : LanguageMap
    }


type alias InstitutionBody =
    { id : String
    , label : LanguageMap
    }


institutionBodyDecoder : Decoder InstitutionBody
institutionBodyDecoder =
    Decode.succeed InstitutionBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder


basicInstitutionBodyDecoder : Decoder BasicInstitutionBody
basicInstitutionBodyDecoder =
    Decode.succeed BasicInstitutionBody
        |> required "id" string
        |> required "label" languageMapLabelDecoder
