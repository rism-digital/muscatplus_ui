module Page.Search.UpdateHelpers exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setRangeFacetValues, toActiveSearch, toKeyboard, toRangeFacetValues)
import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Http
import Http.Detailed
import Page.Query exposing (buildQueryParameters, setFacetBehaviours, setFilters, setNationalCollection, setNextQuery, toFacetBehaviours, toFilters, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, RangeFacetValue(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.Request exposing (createProbeRequestWithDecoder, createSuggestRequestWithDecoder)
import Page.Search.Utilities exposing (createRangeString)
import Page.UI.Keyboard.Model exposing (toKeyboardQuery)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Request exposing (serverUrl)
import Session exposing (Session)
import Utlities exposing (flip)


addNationalCollectionFilter :
    Maybe String
    -> { a | activeSearch : ActiveSearch }
    -> { a | activeSearch : ActiveSearch }
addNationalCollectionFilter ncFilter model =
    let
        newQuery =
            toActiveSearch model
                |> toNextQuery
                |> setNationalCollection ncFilter
    in
    toActiveSearch model
        |> setNextQuery newQuery
        |> flip setActiveSearch model


probeSubmit :
    (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ) -> msg)
    -> Session
    -> { a | activeSearch : ActiveSearch }
    -> ( { a | activeSearch : ActiveSearch }, Cmd msg )
probeSubmit msg session model =
    let
        newModel =
            addNationalCollectionFilter session.restrictedToNationalCollection model

        notationQueryParameters =
            toKeyboard newModel.activeSearch
                |> toKeyboardQuery
                |> buildNotationQueryParameters

        textQueryParameters =
            toNextQuery newModel.activeSearch
                |> buildQueryParameters

        probeUrl =
            List.append textQueryParameters notationQueryParameters
                |> serverUrl [ "probe" ]
    in
    ( newModel
    , createProbeRequestWithDecoder msg probeUrl
    )


userRemovedItemFromQueryFacet :
    FacetAlias
    -> String
    -> { a | activeSearch : ActiveSearch }
    -> { a | activeSearch : ActiveSearch }
userRemovedItemFromQueryFacet alias query model =
    let
        activeFilters =
            toNextQuery model.activeSearch
                |> toFilters

        newActiveFilters =
            Dict.update alias
                (\existingValues ->
                    case existingValues of
                        Just list ->
                            Just (List.filter (\s -> s /= query) list)

                        Nothing ->
                            Nothing
                )
                activeFilters
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> flip setNextQuery model.activeSearch
        |> flip setActiveSearch model


updateQueryFacetValues :
    FacetAlias
    -> FacetBehaviours
    -> { a | activeSearch : ActiveSearch }
    -> { a | activeSearch : ActiveSearch }
updateQueryFacetValues alias currentBehaviour model =
    let
        activeFilters =
            toNextQuery model.activeSearch
                |> toFilters

        newActiveFilters =
            Dict.update alias
                (\existingValues ->
                    case existingValues of
                        Just [] ->
                            Just []

                        Just (x :: xs) ->
                            Just ("" :: x :: xs)

                        Nothing ->
                            Just []
                )
                activeFilters

        newActiveBehaviours =
            toNextQuery model.activeSearch
                |> toFacetBehaviours
                |> Dict.insert alias currentBehaviour
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> setFacetBehaviours newActiveBehaviours
        |> flip setNextQuery model.activeSearch
        |> setActiveSuggestion Nothing
        |> flip setActiveSearch model


updateQueryFacetFilters :
    FacetAlias
    -> String
    -> { a | activeSearch : ActiveSearch }
    -> { a | activeSearch : ActiveSearch }
updateQueryFacetFilters alias text model =
    let
        activeFacets =
            toNextQuery model.activeSearch
                |> toFilters

        newActiveFilters =
            Dict.update alias
                (\existingValues ->
                    case existingValues of
                        Just [] ->
                            Just [ text ]

                        Just (_ :: xs) ->
                            Just (text :: xs)

                        Nothing ->
                            Just [ text ]
                )
                activeFacets
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> flip setNextQuery model.activeSearch
        |> setActiveSuggestion Nothing
        |> flip setActiveSearch model


userEnteredTextInQueryFacet :
    FacetAlias
    -> String
    -> String
    -> (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ) -> msg)
    -> { a | activeSearch : ActiveSearch }
    -> ( { a | activeSearch : ActiveSearch }, Cmd msg )
userEnteredTextInQueryFacet alias query suggestionUrl msg model =
    let
        newModel =
            updateQueryFacetFilters alias query model

        ( suggestModel, suggestionCmd ) =
            if String.length query > 2 then
                ( newModel
                , createSuggestRequestWithDecoder msg (String.append suggestionUrl query)
                )

            else if String.length query == 0 then
                let
                    clearSuggestionModel =
                        setActiveSuggestion Nothing newModel.activeSearch
                            |> flip setActiveSearch newModel
                in
                ( clearSuggestionModel, Cmd.none )

            else
                ( newModel, Cmd.none )
    in
    ( suggestModel, suggestionCmd )


userChangedFacetBehaviour :
    FacetAlias
    -> FacetBehaviours
    -> { a | activeSearch : ActiveSearch }
    -> { a | activeSearch : ActiveSearch }
userChangedFacetBehaviour alias facetBehaviour oldModel =
    toNextQuery oldModel.activeSearch
        |> toFacetBehaviours
        |> Dict.insert alias facetBehaviour
        |> flip setFacetBehaviours (toNextQuery oldModel.activeSearch)
        |> flip setNextQuery oldModel.activeSearch
        |> flip setActiveSearch oldModel


userEnteredTextInRangeFacet :
    FacetAlias
    -> RangeFacetValue
    -> String
    -> { a | activeSearch : ActiveSearch }
    -> { a | activeSearch : ActiveSearch }
userEnteredTextInRangeFacet alias inputBox value model =
    let
        rangeFacetValues =
            toRangeFacetValues model.activeSearch

        newRangeFacetValues =
            Dict.update alias
                (\existingValues ->
                    case existingValues of
                        Just ( lower, upper ) ->
                            case inputBox of
                                LowerRangeValue ->
                                    Just ( value, upper )

                                UpperRangeValue ->
                                    Just ( lower, value )

                        Nothing ->
                            case inputBox of
                                LowerRangeValue ->
                                    Just ( value, "*" )

                                UpperRangeValue ->
                                    Just ( "*", value )
                )
                rangeFacetValues
    in
    setRangeFacetValues newRangeFacetValues model.activeSearch
        |> flip setActiveSearch model


userLostFocusOnRangeFacet :
    FacetAlias
    -> { a | activeSearch : ActiveSearch }
    -> { a | activeSearch : ActiveSearch }
userLostFocusOnRangeFacet alias model =
    let
        rangeFacetValues =
            toRangeFacetValues model.activeSearch

        ( lowerValue, upperValue ) =
            Dict.get alias rangeFacetValues
                |> Maybe.withDefault ( "*", "*" )

        newLowerValue =
            if lowerValue == "" then
                "*"

            else
                lowerValue

        newUpperValue =
            if upperValue == "" then
                "*"

            else
                upperValue

        rangeString =
            createRangeString newLowerValue newUpperValue

        newActiveFilters =
            toNextQuery model.activeSearch
                |> toFilters
                |> Dict.insert alias [ rangeString ]

        -- ensure the range facet also displays the correct value
        newRangeFacetValues =
            toRangeFacetValues model.activeSearch
                |> Dict.insert alias ( newLowerValue, newUpperValue )
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> flip setNextQuery model.activeSearch
        |> setRangeFacetValues newRangeFacetValues
        |> flip setActiveSearch model
