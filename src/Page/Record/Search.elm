module Page.Record.Search exposing (searchSubmit)

import ActiveSearch exposing (setActiveSearch)
import Browser.Navigation as Nav
import Flip exposing (flip)
import Page.Query exposing (buildQueryParameters, resetPage, setNextQuery, toNextQuery)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.UpdateHelpers exposing (addNationalCollectionFilter)
import Request exposing (serverUrl)
import Response exposing (Response(..))
import Session exposing (Session)


searchSubmit : Session -> RecordPageModel RecordMsg -> ( RecordPageModel RecordMsg, Cmd RecordMsg )
searchSubmit session model =
    let
        nationalCollectionSetModel =
            addNationalCollectionFilter session.restrictedToNationalCollection pageResetModel

        newModel =
            { nationalCollectionSetModel
                | response = Loading oldData
                , searchResults = Loading oldSearchData
                , preview = NoResponseToShow
            }

        oldData =
            case model.response of
                Response d ->
                    Just d

                _ ->
                    Nothing

        oldSearchData =
            case model.searchResults of
                Response d ->
                    Just d

                _ ->
                    Nothing

        pageResetModel =
            setNextQuery resetPageInQueryArgs model.activeSearch
                |> flip setActiveSearch model

        resetPageInQueryArgs =
            toNextQuery model.activeSearch
                |> resetPage

        searchUrl =
            serverUrl [ .path session.url ] textQueryParameters

        textQueryParameters =
            toNextQuery nationalCollectionSetModel.activeSearch
                |> buildQueryParameters
    in
    ( newModel
    , Nav.pushUrl session.key searchUrl
    )
