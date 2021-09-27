module Page.Response.DataResponse exposing (..)

import Dict
import Http exposing (Error(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Converters exposing (convertRangeFacetToRangeSlider, filterMap)
import Page.Decoders exposing (recordResponseDecoder)
import Page.Model exposing (CurrentRecordViewTab(..), Response(..))
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.RecordTypes.Search exposing (FacetData(..))
import Page.Response exposing (ServerData(..))
import Page.UI.Keyboard exposing (buildNotationRequestQuery)
import Request exposing (createRequest)
import Search.ActiveFacet exposing (convertFilterToActiveFacet)


serverRespondedWithData : Model -> ServerData -> ( Model, Cmd Msg )
serverRespondedWithData model response =
    let
        oldPage =
            model.page

        oldSearch =
            model.activeSearch

        incomingUrl =
            oldPage.url

        ( showTab, pageSearchCmd ) =
            case ( response, incomingUrl.fragment ) of
                ( PersonData body, Just "sources" ) ->
                    -- if the incoming data is a person record, and the fragment
                    -- says we should be on the 'sources' tab, fire off another Cmd
                    -- to fetch the list of sources associated with this person.
                    let
                        ( tab, sourceCmd ) =
                            case body.sources of
                                Just links ->
                                    ( PersonSourcesRecordSearchTab links.url
                                    , createRequest Msg.ServerRespondedWithPageSearch recordResponseDecoder links.url
                                    )

                                Nothing ->
                                    ( DefaultRecordViewTab
                                    , Cmd.none
                                    )
                    in
                    ( tab
                    , sourceCmd
                    )

                _ ->
                    ( DefaultRecordViewTab
                    , Cmd.none
                    )

        searchMode =
            oldSearch.selectedMode

        keyboardModel =
            oldSearch.keyboard

        keyboardQuery =
            keyboardModel.query

        notationRenderCmd =
            case ( searchMode, keyboardQuery.noteData ) of
                -- if we have an incipit search, we will want to fire off a request to render
                -- any notation contained in the query parameters.
                ( IncipitsMode, _ ) ->
                    Cmd.map Msg.UserInteractedWithPianoKeyboard (buildNotationRequestQuery keyboardQuery)

                _ ->
                    Cmd.none

        newPage =
            { oldPage
                | response = Response response
                , currentTab = showTab
            }

        sliderFacets =
            case response of
                SearchData body ->
                    let
                        isRangeSlider _ a =
                            case a of
                                RangeFacetData d ->
                                    Just (convertRangeFacetToRangeSlider d)

                                _ ->
                                    Nothing
                    in
                    body.facets
                        |> filterMap isRangeSlider

                _ ->
                    Dict.empty

        activeFacets =
            case response of
                SearchData body ->
                    let
                        query =
                            oldSearch.query

                        qFilters =
                            query.filters

                        facetData =
                            body.facets

                        listOfActiveFacets =
                            List.filterMap (\f -> convertFilterToActiveFacet f facetData) qFilters
                    in
                    listOfActiveFacets

                _ ->
                    []

        newSearch =
            { oldSearch
                | sliders = sliderFacets
                , activeFacets = activeFacets
            }
    in
    ( { model
        | page = newPage
        , activeSearch = newSearch
      }
    , Cmd.batch
        [ pageSearchCmd
        , notationRenderCmd
        ]
    )


serverRespondedWithDataError : Model -> Error -> ( Model, Cmd Msg )
serverRespondedWithDataError model error =
    let
        oldPage =
            model.page

        errorMessage =
            case error of
                BadUrl url ->
                    "A Bad URL was supplied: " ++ url

                BadBody message ->
                    "Unexpected response: " ++ message

                _ ->
                    "A problem happened with the request"

        newResponse =
            { oldPage | response = Error errorMessage }
    in
    ( { model | page = newResponse }, Cmd.none )
