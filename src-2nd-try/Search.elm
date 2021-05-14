module Search exposing (..)

import Api.Decoders exposing (recordResponseDecoder)
import Api.Query exposing (QueryArgs, buildQueryParameters)
import Api.RecordTypes exposing (FacetItem(..))
import Api.Request exposing (createRequest, sendRequest, serverUrl)
import Api.Response exposing (ResultMode(..), ServerResponse)
import Http
import List.Extra as LE
import Search.Facet exposing (convertFacetToFilter, convertFacetToResultMode)


type Message
    = FacetChecked String FacetItem Bool
    | ModeChecked String FacetItem Bool
    | Submit
    | Input String
    | ToggleExpandFacet String
    | ReceivedSearchResponse (Result Http.Error ServerResponse)


type alias Model =
    { query : QueryArgs
    , selectedMode : ResultMode
    , expandedFacets : List String
    }


type alias ParentMsgs msgs msg =
    { msgs | searchMainMsg : Message -> msg }


init : ResultMode -> QueryArgs -> Model
init mode query =
    { query = query
    , selectedMode = mode
    , expandedFacets = []
    }


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        ReceivedSearchResponse (Ok response) ->
            ( model, Cmd.none )

        ReceivedSearchResponse (Err error) ->
            ( model, Cmd.none )

        Submit ->
            let
                url =
                    serverUrl [ "search" ] (buildQueryParameters model.query)
            in
            ( model, Cmd.none )

        Input textInput ->
            let
                currentQ =
                    model.query

                newInp =
                    if String.isEmpty textInput then
                        Nothing

                    else
                        Just textInput

                newQ =
                    QueryArgs newInp currentQ.filters currentQ.sort 1 currentQ.mode
            in
            ( { model | query = newQ }, Cmd.none )

        FacetChecked facetname itm checked ->
            let
                facetConvertedToFilter =
                    convertFacetToFilter facetname itm

                currentQuery =
                    model.query

                currentFilters =
                    currentQuery.filters

                newFilters =
                    if checked then
                        facetConvertedToFilter :: currentFilters

                    else
                        LE.remove facetConvertedToFilter currentFilters

                newQuery =
                    { currentQuery | filters = newFilters, page = 1 }
            in
            update Submit { model | query = newQuery }

        ModeChecked _ itm _ ->
            let
                facetConvertedToResultMode =
                    convertFacetToResultMode itm

                currentQuery =
                    model.query

                newQuery =
                    { currentQuery | mode = facetConvertedToResultMode, filters = [] }
            in
            update Submit { model | selectedMode = facetConvertedToResultMode, query = newQuery }

        ToggleExpandFacet facetAlias ->
            let
                isInExpandedList =
                    List.member facetAlias model.expandedFacets

                newExpandedList =
                    if isInExpandedList then
                        LE.remove facetAlias model.expandedFacets

                    else
                        facetAlias :: model.expandedFacets
            in
            ( { model | expandedFacets = newExpandedList }, Cmd.none )
