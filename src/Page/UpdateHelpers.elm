module Page.UpdateHelpers exposing (..)

import ActiveSearch
    exposing
        ( setActiveSearch
        , setActiveSuggestion
        , setExpandedFacets
        , setQueryFacetValues
        , setRangeFacetValues
        , toExpandedFacets
        , toQueryFacetValues
        , toRangeFacetValues
        , toggleExpandedFacets
        )
import ActiveSearch.Model exposing (ActiveSearch)
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Flip exposing (flip)
import Http
import Http.Detailed
import List.Extra as LE
import Page.Keyboard.Model exposing (toKeyboardQuery)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs, buildQueryParameters, setFacetBehaviours, setFacetSorts, setFilters, setMode, setNationalCollection, setNextQuery, toFacetBehaviours, toFacetSorts, toFilters, toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, RangeFacetValue(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.Request exposing (createProbeRequestWithDecoder, createSuggestRequestWithDecoder)
import Page.Route exposing (Route(..))
import Page.SideBar.Msg exposing (sideBarOptionToResultMode)
import Parser as P exposing ((|.), (|=), Parser)
import Request exposing (serverUrl)
import Response exposing (Response(..), ServerData)
import Session exposing (Session)
import Url
import Url.Builder exposing (toQuery)
import Utlities exposing (choose, convertPathToNodeId)
import Viewport exposing (resetViewportOf)


createRangeString : String -> String -> String
createRangeString lower upper =
    "[" ++ lower ++ " TO " ++ upper ++ "]"


addNationalCollectionFilter :
    Maybe String
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
addNationalCollectionFilter ncFilter model =
    toNextQuery model.activeSearch
        |> setNationalCollection ncFilter
        |> flip setNextQuery model.activeSearch
        |> flip setActiveSearch model


addNationalCollectionQueryParameter : Session -> QueryArgs -> String
addNationalCollectionQueryParameter session qargs =
    let
        newQargs =
            case session.restrictedToNationalCollection of
                Just _ ->
                    case qargs.nationalCollection of
                        Nothing ->
                            { qargs | nationalCollection = session.restrictedToNationalCollection }

                        Just _ ->
                            qargs

                Nothing ->
                    qargs
    in
    buildQueryParameters newQargs
        |> toQuery
        |> String.dropLeft 1


setProbeResponse : Response ProbeData -> { a | probeResponse : Response ProbeData } -> { a | probeResponse : Response ProbeData }
setProbeResponse newResponse oldModel =
    { oldModel | probeResponse = newResponse }


probeSubmit :
    (Result (Http.Detailed.Error String) ( Http.Metadata, ProbeData ) -> msg)
    -> Session
    -> { a | activeSearch : ActiveSearch msg, probeResponse : Response ProbeData }
    -> ( { a | activeSearch : ActiveSearch msg, probeResponse : Response ProbeData }, Cmd msg )
probeSubmit probeMsg session model =
    let
        newModel =
            addNationalCollectionFilter session.restrictedToNationalCollection model
                |> setProbeResponse (Loading Nothing)

        probeUrl =
            createProbeUrl session newModel.activeSearch
    in
    ( newModel
    , createProbeRequestWithDecoder probeMsg probeUrl
    )


createProbeUrl : Session -> ActiveSearch msg -> String
createProbeUrl session activeSearch =
    let
        resultMode =
            toNextQuery activeSearch
                |> toMode

        notationQueryParameters =
            case activeSearch.keyboard of
                Just p ->
                    toKeyboardQuery p
                        |> buildNotationQueryParameters

                Nothing ->
                    []

        textQueryParameters =
            setMode resultMode activeSearch.nextQuery
                |> buildQueryParameters

        probeUrl =
            case session.route of
                InstitutionSourcePageRoute id _ ->
                    serverUrl [ "institutions", String.fromInt id, "probe" ]

                PersonSourcePageRoute id _ ->
                    serverUrl [ "people", String.fromInt id, "probe" ]

                _ ->
                    serverUrl [ "probe" ]
    in
    List.append textQueryParameters notationQueryParameters
        |> probeUrl


userRemovedItemFromQueryFacet :
    FacetAlias
    -> String
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
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
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
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
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
userEnteredTextInQueryFacet alias query model =
    let
        newQueryFacetValue =
            .queryFacetValues model.activeSearch
                |> Dict.insert alias query

        newModel =
            setQueryFacetValues newQueryFacetValue model.activeSearch
                |> flip setActiveSearch model
    in
    if String.length query == 0 then
        let
            clearSuggestionModel =
                setActiveSuggestion Nothing newModel.activeSearch
                    |> flip setActiveSearch newModel
        in
        clearSuggestionModel

    else
        newModel


textQuerySuggestionSubmit :
    String
    -> (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ) -> msg)
    -> Cmd msg
textQuerySuggestionSubmit suggestionUrl msg =
    createSuggestRequestWithDecoder msg suggestionUrl


userChangedFacetBehaviour :
    FacetAlias
    -> FacetBehaviours
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
userChangedFacetBehaviour alias facetBehaviour oldModel =
    toNextQuery oldModel.activeSearch
        |> toFacetBehaviours
        |> Dict.insert alias facetBehaviour
        |> flip setFacetBehaviours (toNextQuery oldModel.activeSearch)
        |> flip setNextQuery oldModel.activeSearch
        |> flip setActiveSearch oldModel


{-|

    Takes a range query string, such as "[1900 TO 2000]", and parses
    it to a tuple pair representing the start and end dates. Also supports
    wildcards, e.g., "[* TO 1700]", "[1700 TO *]" and "[* TO *]".

    If the query string cannot be parsed it returns a ("", "") pair, and lets
    the downstream components do any validation on this input.

-}
rangeStringParser : String -> Maybe ( String, String )
rangeStringParser rString =
    let
        isStar : Char -> Bool
        isStar c =
            c == '*'

        -- chooses one of the following for valid input
        --  - A number (float)
        --  - A star "*"
        oneOfParser : Parser String
        oneOfParser =
            P.oneOf
                [ P.map String.fromFloat P.float
                , P.map identity <| P.getChompedString (P.chompIf isStar)
                ]

        qParser =
            P.succeed Tuple.pair
                |. P.symbol "["
                |= oneOfParser
                |. P.spaces
                |. P.symbol "TO"
                |. P.spaces
                |= oneOfParser
                |. P.symbol "]"
                |. P.end
    in
    case P.run qParser rString of
        Ok res ->
            Just res

        Err _ ->
            Nothing


selectAppropriateRangeFacetValues : FacetAlias -> ActiveSearch msg -> Maybe ( String, String )
selectAppropriateRangeFacetValues facetAlias activeSearch =
    let
        setRangeValues =
            Dict.get facetAlias activeSearch.rangeFacetValues

        queryRangeValues =
            Dict.get facetAlias (.filters activeSearch.nextQuery)
    in
    case setRangeValues of
        Just ( l, v ) ->
            Just ( l, v )

        _ ->
            case queryRangeValues of
                Just (m :: []) ->
                    rangeStringParser m

                _ ->
                    Nothing


updateRangeFacetValues : String -> RangeFacetValue -> String -> Dict FacetAlias ( String, String ) -> Dict FacetAlias ( String, String )
updateRangeFacetValues alias inputBox value rangeFacetValues =
    let
        updateFn existingValues =
            case existingValues of
                Just ( lower, upper ) ->
                    case inputBox of
                        LowerRangeValue ->
                            Just ( value, upper )

                        UpperRangeValue ->
                            Just ( lower, value )

                Nothing ->
                    if value == "*" then
                        Nothing

                    else
                        case inputBox of
                            LowerRangeValue ->
                                Just ( value, "*" )

                            UpperRangeValue ->
                                Just ( "*", value )
    in
    Dict.update alias updateFn rangeFacetValues


userEnteredTextInRangeFacet :
    FacetAlias
    -> RangeFacetValue
    -> String
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
userEnteredTextInRangeFacet alias inputBox value model =
    let
        newRangeFacetValues =
            toRangeFacetValues model.activeSearch
                |> updateRangeFacetValues alias inputBox value
    in
    setRangeFacetValues newRangeFacetValues model.activeSearch
        |> flip setActiveSearch model


userLostFocusOnRangeFacet :
    FacetAlias
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
userLostFocusOnRangeFacet alias model =
    let
        rangeFacetValues =
            toRangeFacetValues model.activeSearch

        ( lowerValue, upperValue ) =
            Dict.get alias rangeFacetValues
                |> Maybe.withDefault ( "*", "*" )

        newLowerValue =
            choose (lowerValue == "") "*" lowerValue

        newUpperValue =
            choose (upperValue == "") "*" upperValue

        oldFilters =
            toNextQuery model.activeSearch
                |> toFilters

        newActiveFilters =
            if newLowerValue == "*" && newUpperValue == "*" then
                Dict.remove alias oldFilters

            else
                Dict.insert alias (List.singleton (createRangeString newLowerValue newUpperValue)) oldFilters

        -- ensure the range facet also displays the correct value
        newRangeFacetValues =
            rangeFacetValues
                |> Dict.insert alias ( newLowerValue, newUpperValue )
    in
    toNextQuery model.activeSearch
        |> setFilters newActiveFilters
        |> flip setNextQuery model.activeSearch
        |> setRangeFacetValues newRangeFacetValues
        |> flip setActiveSearch model


userClickedToggleFacet : FacetAlias -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
userClickedToggleFacet alias model =
    let
        oldFilters =
            toNextQuery model.activeSearch
                |> toFilters

        newFilters =
            if Dict.member alias oldFilters then
                Dict.remove alias oldFilters

            else
                Dict.insert alias [ "true" ] oldFilters

        newQueryArgs =
            toNextQuery model.activeSearch
                |> setFilters newFilters
    in
    setNextQuery newQueryArgs model.activeSearch
        |> flip setActiveSearch model


userClickedSelectFacetItem : FacetAlias -> String -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
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


userClickedSelectFacetExpand : FacetAlias -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
userClickedSelectFacetExpand alias model =
    let
        newExpandedFacets =
            toExpandedFacets model.activeSearch
                |> toggleExpandedFacets alias
    in
    setExpandedFacets newExpandedFacets model.activeSearch
        |> flip setActiveSearch model


userChangedSelectFacetSort : FacetAlias -> FacetSorts -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
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


userClickedResultForPreview :
    String
    -> Session
    -> { a | selectedResult : Maybe String, preview : Response ServerData }
    -> ( { a | selectedResult : Maybe String, preview : Response ServerData }, Cmd msg )
userClickedResultForPreview result session model =
    let
        resultUrl =
            Url.fromString result

        resPath =
            case resultUrl of
                Just p ->
                    String.dropLeft 1 p.path
                        |> convertPathToNodeId
                        |> Just

                Nothing ->
                    Nothing

        currentUrl =
            session.url

        newUrl =
            { currentUrl | fragment = resPath }

        newUrlStr =
            Url.toString newUrl
    in
    ( { model
        | selectedResult = Just result
        , preview = Loading Nothing
      }
    , Nav.pushUrl session.key newUrlStr
    )


userClickedClosePreviewWindow :
    Session
    -> { a | selectedResult : Maybe String, preview : Response ServerData }
    -> ( { a | selectedResult : Maybe String, preview : Response ServerData }, Cmd msg )
userClickedClosePreviewWindow session model =
    let
        currentUrl =
            session.url

        newUrl =
            { currentUrl | fragment = Nothing }

        newUrlStr =
            Url.toString newUrl
    in
    ( { model
        | preview = NoResponseToShow
        , selectedResult = Nothing
      }
    , Nav.pushUrl session.key newUrlStr
    )
