module Msg exposing (Msg(..))

import Element exposing (Device)
import Routes
import Search


type Msg
    = OnWindowResize Device
    | LanguageSelectChanged String
    | Routing Routes.Message
    | SearchInterface Search.Message
    | NoOp
