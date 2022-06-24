module Page.UpdateHelpers exposing
    ( addNationalCollectionFilter
    , addNationalCollectionQueryParameter
    , createProbeUrl
    , probeSubmit
    , rangeStringParser
    , selectAppropriateRangeFacetValues
    , textQuerySuggestionSubmit
    , updateQueryFacetFilters
    , userChangedFacetBehaviour
    , userChangedResultSorting
    , userChangedResultsPerPage
    , userChangedSelectFacetSort
    , userClickedClosePreviewWindow
    , userClickedFacetPanelToggle
    , userClickedResultForPreview
    , userClickedSelectFacetExpand
    , userClickedSelectFacetItem
    , userClickedToggleFacet
    , userEnteredTextInKeywordQueryBox
    , userEnteredTextInQueryFacet
    , userEnteredTextInRangeFacet
    , userFocusedRangeFacet
    , userLostFocusOnRangeFacet
    , userRemovedItemFromQueryFacet
    )

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setExpandedFacetPanels, setExpandedFacets, setQueryFacetValues, setRangeFacetValues, toExpandedFacetPanels, toExpandedFacets, toQueryFacetValues, toRangeFacetValues, toggleExpandedFacetPanel, toggleExpandedFacets)
import ActiveSearch.Model exposing (ActiveSearch)
import Browser.Navigation as Nav
import Config as C
import Dict exposing (Dict)
import Flip exposing (flip)
import Http
import Http.Detailed
import List.Extra as LE
import Page.Keyboard.Model exposing (toKeyboardQuery)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs, buildQueryParameters, setFacetBehaviours, setFacetSorts, setFilters, setKeywordQuery, setMode, setNationalCollection, setNextQuery, setRows, setSort, toFacetBehaviours, toFacetSorts, toFilters, toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.RecordTypes.Search exposing (FacetBehaviours, FacetSorts, RangeFacetValue(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.RecordTypes.Suggestion exposing (ActiveSuggestion)
import Page.Request exposing (createProbeRequestWithDecoder, createSuggestRequestWithDecoder)
import Page.Route exposing (Route(..))
import Parser as P exposing ((|.), (|=), Parser)
import Request exposing (serverUrl)
import Response exposing (Response(..), ServerData)
import Session exposing (Session)
import Url
import Url.Builder exposing (toQuery)
import Utlities exposing (choose, convertPathToNodeId)


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
                        Just _ ->
                            qargs

                        Nothing ->
                            { qargs | nationalCollection = session.restrictedToNationalCollection }

                Nothing ->
                    qargs
    in
    buildQueryParameters newQargs
        |> toQuery
        |> String.dropLeft 1


createProbeUrl : Session -> ActiveSearch msg -> String
createProbeUrl session activeSearch =
    let
        notationQueryParameters =
            case activeSearch.keyboard of
                Just p ->
                    toKeyboardQuery p
                        |> buildNotationQueryParameters

                Nothing ->
                    []

        probeUrl =
            case session.route of
                SourceContentsPageRoute id _ ->
                    serverUrl [ "sources", String.fromInt id, "probe" ]

                PersonSourcePageRoute id _ ->
                    serverUrl [ "people", String.fromInt id, "probe" ]

                InstitutionSourcePageRoute id _ ->
                    serverUrl [ "institutions", String.fromInt id, "probe" ]

                _ ->
                    serverUrl [ "probe" ]

        resultMode =
            toNextQuery activeSearch
                |> toMode

        textQueryParameters =
            setMode resultMode activeSearch.nextQuery
                |> buildQueryParameters
    in
    List.append textQueryParameters notationQueryParameters
        |> probeUrl


createRangeString : String -> String -> String
createRangeString lower upper =
    "[" ++ lower ++ " TO " ++ upper ++ "]"


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
                , P.map identity (P.getChompedString (P.chompIf isStar))
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
    in
    case setRangeValues of
        Just ( l, v ) ->
            Just ( l, v )

        _ ->
            let
                queryRangeValues =
                    Dict.get facetAlias (.filters activeSearch.nextQuery)
            in
            case queryRangeValues of
                Just (m :: []) ->
                    rangeStringParser m

                _ ->
                    Nothing


setProbeResponse : Response ProbeData -> { a | probeResponse : Response ProbeData } -> { a | probeResponse : Response ProbeData }
setProbeResponse newResponse oldModel =
    { oldModel | probeResponse = newResponse }


textQuerySuggestionSubmit :
    String
    -> (Result (Http.Detailed.Error String) ( Http.Metadata, ActiveSuggestion ) -> msg)
    -> Cmd msg
textQuerySuggestionSubmit suggestionUrl msg =
    createSuggestRequestWithDecoder msg suggestionUrl


updateQueryFacetFilters :
    FacetAlias
    -> String
    -> FacetBehaviours
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
updateQueryFacetFilters alias text currentBehaviour model =
    let
        newActiveBehaviours =
            toNextQuery model.activeSearch
                |> toFacetBehaviours
                |> Dict.insert alias currentBehaviour

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


userChangedResultSorting : String -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
userChangedResultSorting sortParam model =
    let
        sortValue =
            Just sortParam

        newQueryArgs =
            toNextQuery model.activeSearch
                |> setSort sortValue
    in
    setNextQuery newQueryArgs model.activeSearch
        |> flip setActiveSearch model


userChangedResultsPerPage : String -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
userChangedResultsPerPage numResults model =
    let
        rowNum =
            Maybe.withDefault C.defaultRows (String.toInt numResults)

        newQueryArgs =
            toNextQuery model.activeSearch
                |> setRows rowNum
    in
    setNextQuery newQueryArgs model.activeSearch
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


userClickedClosePreviewWindow :
    Session
    -> { a | preview : Response ServerData, selectedResult : Maybe String }
    -> ( { a | preview : Response ServerData, selectedResult : Maybe String }, Cmd msg )
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


userClickedResultForPreview :
    String
    -> Session
    -> { a | preview : Response ServerData, selectedResult : Maybe String }
    -> ( { a | preview : Response ServerData, selectedResult : Maybe String }, Cmd msg )
userClickedResultForPreview result session model =
    let
        currentUrl =
            session.url

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

        newUrl =
            { currentUrl | fragment = resPath }

        newUrlStr =
            Url.toString newUrl
    in
    ( { model
        | preview = Loading Nothing
        , selectedResult = Just result
      }
    , Nav.pushUrl session.key newUrlStr
    )


userClickedSelectFacetExpand : FacetAlias -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
userClickedSelectFacetExpand alias model =
    let
        newExpandedFacets =
            toExpandedFacets model.activeSearch
                |> toggleExpandedFacets alias
    in
    setExpandedFacets newExpandedFacets model.activeSearch
        |> flip setActiveSearch model


userClickedFacetPanelToggle : String -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
userClickedFacetPanelToggle alias model =
    let
        newPanelSection =
            toExpandedFacetPanels model.activeSearch
                |> toggleExpandedFacetPanel alias
    in
    setExpandedFacetPanels newPanelSection model.activeSearch
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


userEnteredTextInKeywordQueryBox : String -> { a | activeSearch : ActiveSearch msg } -> { a | activeSearch : ActiveSearch msg }
userEnteredTextInKeywordQueryBox queryText model =
    let
        newText =
            if String.isEmpty queryText then
                Nothing

            else
                Just queryText

        newQueryArgs =
            toNextQuery model.activeSearch
                |> setKeywordQuery newText
    in
    setNextQuery newQueryArgs model.activeSearch
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
        setActiveSuggestion Nothing newModel.activeSearch
            |> flip setActiveSearch newModel

    else
        newModel


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


userFocusedRangeFacet :
    String
    -> { a | activeSearch : ActiveSearch msg }
    -> ( { a | activeSearch : ActiveSearch msg }, Cmd msg )
userFocusedRangeFacet alias model =
    let
        -- when the user focuses the range facet, we ensure that any query parameters are
        -- immediately transferred to the place where we keep range facet values so that we
        -- can edit them.
        nextQueryFilters =
            toNextQuery model.activeSearch
                |> toFilters

        maybeRangeValue =
            case Dict.get alias nextQueryFilters of
                Just (m :: []) ->
                    rangeStringParser m

                _ ->
                    Nothing

        -- if we have an existing value here, prefer that. If not, choose the query value
        newRangeValues =
            Dict.update alias
                (\v ->
                    case v of
                        Just m ->
                            Just m

                        Nothing ->
                            maybeRangeValue
                )
                (.rangeFacetValues model.activeSearch)

        newActiveSearch =
            setRangeFacetValues newRangeValues model.activeSearch
    in
    ( { model
        | activeSearch = newActiveSearch
      }
    , Cmd.none
    )


userLostFocusOnRangeFacet :
    FacetAlias
    -> { a | activeSearch : ActiveSearch msg }
    -> { a | activeSearch : ActiveSearch msg }
userLostFocusOnRangeFacet alias model =
    let
        ( lowerValue, upperValue ) =
            Dict.get alias rangeFacetValues
                |> Maybe.withDefault ( "*", "*" )

        newLowerValue =
            choose (lowerValue == "") "*" lowerValue

        newUpperValue =
            choose (upperValue == "") "*" upperValue

        rangeFacetValues =
            toRangeFacetValues model.activeSearch

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
