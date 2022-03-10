module Page.Search.UpdateHelpers exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setExpandedFacets, setQueryFacetValues, setRangeFacetValues, toActiveSearch, toExpandedFacets, toKeyboard, toQueryFacetValues, toRangeFacetValues, toggleExpandedFacets)
import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Flip exposing (flip)
import Http
import Http.Detailed
import List.Extra as LE
import Page.Query exposing (buildQueryParameters, setFacetBehaviours, setFacetSorts, setFilters, setNationalCollection, setNextQuery, toFacetBehaviours, toFacetSorts, toFilters, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, RangeFacetValue(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.Request exposing (createProbeRequestWithDecoder, createSuggestRequestWithDecoder)
import Page.Search.Utilities exposing (createRangeString)
import Page.UI.Keyboard.Model exposing (toKeyboardQuery)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Request exposing (serverUrl)
import Response exposing (Response(..))
import Session exposing (Session)


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


setProbeResponse : Response ProbeData -> { a | probeResponse : Response ProbeData } -> { a | probeResponse : Response ProbeData }
setProbeResponse newResponse oldModel =
    { oldModel | probeResponse = newResponse }


probeSubmit :
    (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ) -> msg)
    -> Session
    -> { a | activeSearch : ActiveSearch, probeResponse : Response ProbeData }
    -> ( { a | activeSearch : ActiveSearch, probeResponse : Response ProbeData }, Cmd msg )
probeSubmit msg session model =
    let
        newModel =
            addNationalCollectionFilter session.restrictedToNationalCollection model
                |> setProbeResponse (Loading Nothing)

        probeUrl =
            createProbeUrl newModel.activeSearch
    in
    ( newModel
    , createProbeRequestWithDecoder msg probeUrl
    )


createProbeUrl : ActiveSearch -> String
createProbeUrl activeSearch =
    let
        notationQueryParameters =
            toKeyboard activeSearch
                |> toKeyboardQuery
                |> buildNotationQueryParameters

        textQueryParameters =
            activeSearch.nextQuery
                |> buildQueryParameters
    in
    List.append textQueryParameters notationQueryParameters
        |> serverUrl [ "probe" ]


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


updateQueryFacetFilters :
    FacetAlias
    -> String
    -> FacetBehaviours
    -> { a | activeSearch : ActiveSearch }
    -> { a | activeSearch : ActiveSearch }
updateQueryFacetFilters alias text currentBehaviour model =
    let
        activeFilters =
            toNextQuery model.activeSearch
                |> toFilters

        newActiveFilters =
            Dict.update alias
                (\existingValues ->
                    case existingValues of
                        Just [] ->
                            Just [ text ]

                        Just v ->
                            Just (text :: v)

                        Nothing ->
                            Just [ text ]
                )
                activeFilters

        newActiveBehaviours =
            toNextQuery model.activeSearch
                |> toFacetBehaviours
                |> Dict.insert alias currentBehaviour

        newQueryFacetValues =
            toQueryFacetValues model.activeSearch
                |> Dict.remove alias
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> setFacetBehaviours newActiveBehaviours
        |> flip setNextQuery model.activeSearch
        |> setQueryFacetValues newQueryFacetValues
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
        newQueryFacetValue =
            .queryFacetValues model.activeSearch
                |> Dict.insert alias query

        newModel =
            setQueryFacetValues newQueryFacetValue model.activeSearch
                |> flip setActiveSearch model

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


userClickedToggleFacet : FacetAlias -> { a | activeSearch : ActiveSearch } -> { a | activeSearch : ActiveSearch }
userClickedToggleFacet alias model =
    let
        oldFilters =
            toNextQuery model.activeSearch
                |> toFilters

        newFilters =
            if Dict.member alias oldFilters == True then
                Dict.remove alias oldFilters

            else
                Dict.insert alias [ "true" ] oldFilters

        newQueryArgs =
            toNextQuery model.activeSearch
                |> setFilters newFilters
    in
    setNextQuery newQueryArgs model.activeSearch
        |> flip setActiveSearch model


userClickedSelectFacetItem : FacetAlias -> String -> { a | activeSearch : ActiveSearch } -> { a | activeSearch : ActiveSearch }
userClickedSelectFacetItem alias facetValue model =
    let
        activeFilters =
            toNextQuery model.activeSearch
                |> toFilters

        newActiveFilters =
            Dict.update alias
                (\existingValues ->
                    case existingValues of
                        Just list ->
                            if List.member facetValue list == False then
                                Just (facetValue :: list)

                            else
                                Just (LE.remove facetValue list)

                        Nothing ->
                            Just [ facetValue ]
                )
                activeFilters
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> flip setNextQuery model.activeSearch
        |> flip setActiveSearch model


userClickedSelectFacetExpand : FacetAlias -> { a | activeSearch : ActiveSearch } -> { a | activeSearch : ActiveSearch }
userClickedSelectFacetExpand alias model =
    let
        newExpandedFacets =
            toExpandedFacets model.activeSearch
                |> toggleExpandedFacets alias
    in
    setExpandedFacets newExpandedFacets model.activeSearch
        |> flip setActiveSearch model


userChangedSelectFacetSort : FacetAlias -> FacetSorts -> { a | activeSearch : ActiveSearch } -> { a | activeSearch : ActiveSearch }
userChangedSelectFacetSort alias facetSort model =
    let
        newFacetSorts =
            toNextQuery model.activeSearch
                |> toFacetSorts
                |> Dict.insert alias facetSort
    in
    toNextQuery model.activeSearch
        |> setFacetSorts newFacetSorts
        |> flip setNextQuery model.activeSearch
        |> flip setActiveSearch model
