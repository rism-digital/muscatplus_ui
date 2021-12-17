module ActiveSearch exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict exposing (Dict)
import List.Extra as LE
import Page.Query exposing (Filter, QueryArgs)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Route exposing (Route(..))
import Page.UI.Keyboard as Keyboard


init : Route -> ActiveSearch
init initialRoute =
    let
        ( qargs, kqargs ) =
            case initialRoute of
                SearchPageRoute q kq ->
                    ( q, kq )

                _ ->
                    ( Page.Query.defaultQueryArgs, Keyboard.defaultKeyboardQuery )

        initialSort =
            qargs.sort

        initialKeyboardModel =
            Keyboard.initModel

        updatedKeyboardModel =
            { initialKeyboardModel | query = kqargs }
    in
    { needsProbing = False
    , nextQuery = qargs
    , expandedFacets = []
    , keyboard = updatedKeyboardModel
    , selectedResultSort = initialSort
    }


toActiveSearch : { a | activeSearch : ActiveSearch } -> ActiveSearch
toActiveSearch model =
    model.activeSearch


setActiveSearch : ActiveSearch -> { a | activeSearch : ActiveSearch } -> { a | activeSearch : ActiveSearch }
setActiveSearch newSearch oldRecord =
    { oldRecord | activeSearch = newSearch }


toKeyboard : { a | keyboard : Keyboard.Model } -> Keyboard.Model
toKeyboard model =
    model.keyboard


setKeyboard : Keyboard.Model -> { a | keyboard : Keyboard.Model } -> { a | keyboard : Keyboard.Model }
setKeyboard newKeyboard oldRecord =
    { oldRecord | keyboard = newKeyboard }


toExpandedFacets : { a | expandedFacets : List String } -> List String
toExpandedFacets model =
    model.expandedFacets


setExpandedFacets : List String -> { a | expandedFacets : List String } -> { a | expandedFacets : List String }
setExpandedFacets newFacets oldRecord =
    { oldRecord | expandedFacets = newFacets }


toggleExpandedFacets : String -> List String -> List String
toggleExpandedFacets newFacet oldFacets =
    if List.member newFacet oldFacets then
        LE.remove newFacet oldFacets

    else
        newFacet :: oldFacets



--toActiveFacets : { a | activeFacets : Dict FacetAlias (List String) } -> Dict FacetAlias (List String)
--toActiveFacets model =
--    model.activeFacets
--
--
--setActiveFacets :
--    Dict FacetAlias (List String)
--    -> { a | activeFacets : Dict FacetAlias (List String) }
--    -> { a | activeFacets : Dict FacetAlias (List String) }
--setActiveFacets newValue oldRecord =
--    { oldRecord | activeFacets = newValue }


setNeedsProbing : Bool -> { a | needsProbing : Bool } -> { a | needsProbing : Bool }
setNeedsProbing newValue oldRecord =
    { oldRecord | needsProbing = newValue }
