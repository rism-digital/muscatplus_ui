module Search.DataTypes exposing (..)

import Api.Search exposing (ApiResponse(..), SearchQueryArgs, SearchResponse)
import Element exposing (Device)
import Http
import Language exposing (Language)


type Msg
    = ReceivedSearchResponse (Result Http.Error SearchResponse)
    | SearchInput SearchQueryArgs
    | SearchSubmit
    | OnWindowResize Device
    | NoOp


type alias Model =
    { language : Language
    , query : SearchQueryArgs
    , response : ApiResponse
    , errorMessage : String
    , viewingDevice : Device
    }
