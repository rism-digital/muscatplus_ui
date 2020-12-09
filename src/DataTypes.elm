module DataTypes exposing (..)

import Api.Search exposing (ApiResponse(..), SearchResponse)
import Http
import Language exposing (Language)


type Msg
    = ReceivedSearchResponse (Result Http.Error SearchResponse)
    | SearchInput String
    | SearchSubmit
    | NoOp


type alias Model =
    { language : Language
    , keywordQuery : String
    , response : ApiResponse
    , errorMessage : String
    }
