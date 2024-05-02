module Flags exposing (Flags)

import Json.Decode exposing (Value)


type alias Flags =
    { locale : String
    , windowWidth : Int
    , windowHeight : Int
    , showMuscatLinks : Bool
    , nationalCollection : Maybe String
    , searchPreferences : Maybe Value
    , isFramed : Bool
    , cacheBuster : Bool
    }
