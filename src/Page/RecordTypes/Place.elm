module Page.RecordTypes.Place exposing (..)

import Json.Decode as Decode exposing (Decoder)


type alias PlaceBody =
    {}


placeBodyDecoder : Decoder PlaceBody
placeBodyDecoder =
    Decode.succeed PlaceBody
