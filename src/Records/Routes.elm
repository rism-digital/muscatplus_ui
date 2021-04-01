module Records.Routes exposing (..)

import Config as C
import Http
import Records.DataTypes exposing (RecordResponse, Route(..))
import Records.Decoders exposing (recordResponseDecoder)
import Shared.Request exposing (createRequest)
import Url exposing (Url)
import Url.Builder
import Url.Parser as P exposing ((</>), s)


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


routeMatches : Url -> Maybe Route
routeMatches url =
    P.parse routeParser url


recordUrl : List String -> String
recordUrl pathSegments =
    Url.Builder.crossOrigin C.serverUrl pathSegments []


recordRequest : (Result Http.Error RecordResponse -> msg) -> String -> Cmd msg
recordRequest responseMsg path =
    let
        pathSegments =
            path
                |> String.dropLeft 1
                |> String.split "/"

        url =
            recordUrl pathSegments
    in
    createRequest responseMsg recordResponseDecoder url
