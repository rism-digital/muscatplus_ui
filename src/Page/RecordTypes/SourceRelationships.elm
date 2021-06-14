module Page.RecordTypes.SourceRelationships exposing (..)

{-
   Handles the relationship of sources to
   people and institutions

-}

import Json.Decode as Decode exposing (Decoder, int, string)
import Json.Decode.Pipeline exposing (required)


type alias SourceRelationshipsSectionBody =
    { url : String
    , totalItems : Int
    }


sourceRelationshipsSectionBodyDecoder : Decoder SourceRelationshipsSectionBody
sourceRelationshipsSectionBodyDecoder =
    Decode.succeed SourceRelationshipsSectionBody
        |> required "url" string
        |> required "totalItems" int
