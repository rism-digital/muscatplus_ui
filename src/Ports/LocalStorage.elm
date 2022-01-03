port module Ports.LocalStorage exposing (..)

import Json.Encode as Encode


port saveLanguagePreference : Encode.Value -> Cmd msg


port saveNationalCollectionSelection : Encode.Value -> Cmd msg
