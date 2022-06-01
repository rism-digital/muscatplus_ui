module Model exposing (..)

import Page.About as About
import Page.Front as Front
import Page.NotFound as NotFound
import Page.Record as Record
import Page.Search as Search
import Session exposing (Session)


type Model
    = NotFoundPage Session NotFound.Model
    | SearchPage Session Search.Model
    | FrontPage Session Front.Model
    | SourcePage Session Record.Model
    | PersonPage Session Record.Model
    | InstitutionPage Session Record.Model
    | PlacePage Session Record.Model
    | AboutPage Session About.Model


toSession : Model -> Session
toSession model =
    case model of
        NotFoundPage session _ ->
            session

        SearchPage session _ ->
            session

        FrontPage session _ ->
            session

        SourcePage session _ ->
            session

        PersonPage session _ ->
            session

        InstitutionPage session _ ->
            session

        PlacePage session _ ->
            session

        AboutPage session _ ->
            session


updateSession : Session -> Model -> Model
updateSession newSession model =
    case model of
        NotFoundPage _ pageModel ->
            NotFoundPage newSession pageModel

        SearchPage _ pageModel ->
            SearchPage newSession pageModel

        FrontPage _ pageModel ->
            FrontPage newSession pageModel

        SourcePage _ pageModel ->
            SourcePage newSession pageModel

        PersonPage _ pageModel ->
            PersonPage newSession pageModel

        InstitutionPage _ pageModel ->
            InstitutionPage newSession pageModel

        PlacePage _ pageModel ->
            PlacePage newSession pageModel

        AboutPage _ aboutModel ->
            AboutPage newSession aboutModel
