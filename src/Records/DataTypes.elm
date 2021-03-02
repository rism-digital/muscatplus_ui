module Records.DataTypes exposing (Model, Msg(..), Route(..), parseUrl)

import Api.Records exposing (ApiResponse(..), RecordResponse)
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Element exposing (Device)
import Http
import Language exposing (Language)
import Url exposing (Url)
import Url.Parser as P exposing ((</>), s)


type Msg
    = ReceivedRecordResponse (Result Http.Error RecordResponse)
    | UrlRequest UrlRequest
    | UrlChanged Url
    | OnWindowResize Device
    | LanguageSelectChanged String
    | NoOp


type alias Model =
    { key : Nav.Key
    , url : Url
    , response : ApiResponse
    , errorMessage : String
    , language : Language
    , viewingDevice : Device
    }


type Route
    = SourceRoute Int
    | PersonRoute Int
    | InstitutionRoute Int
    | NotFound


parseUrl : Url -> Route
parseUrl url =
    case P.parse routeParser url of
        Just route ->
            route

        Nothing ->
            NotFound


routeParser : P.Parser (Route -> a) a
routeParser =
    P.oneOf
        [ P.map SourceRoute (s "sources" </> P.int)
        , P.map PersonRoute (s "people" </> P.int)
        , P.map InstitutionRoute (s "institutions" </> P.int)
        ]
