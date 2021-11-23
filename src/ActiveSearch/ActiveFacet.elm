module ActiveSearch.ActiveFacet exposing (..)

import Dict
import Language exposing (LanguageMap)
import Page.Query exposing (Filter(..))
import Page.RecordTypes.Search exposing (FacetData(..), FacetItem(..), FacetType(..), Facets)


type alias FacetLabel =
    LanguageMap


type alias FacetValue =
    String


type alias FriendlyFacetValue =
    Maybe LanguageMap


type alias FacetAlias =
    String


type ActiveFacet
    = ActiveFacet FacetType FacetLabel FacetAlias FacetValue FriendlyFacetValue


{-|

    Takes a filter and a list of available facets, and
    returns an ActiveFacet that contains a human-readable
    representation of the facet value.

-}
convertFilterToActiveFacet : Filter -> Facets -> Maybe ActiveFacet
convertFilterToActiveFacet filter facets =
    let
        (Filter alias value) =
            filter

        facetData =
            Dict.get alias facets

        activeFacet =
            case facetData of
                Just d ->
                    let
                        ( facetType, facetLabel, friendlyValue ) =
                            case d of
                                ToggleFacetData f ->
                                    ( Toggle, f.label, Nothing )

                                RangeFacetData f ->
                                    ( Range, f.label, Nothing )

                                SelectFacetData f ->
                                    let
                                        -- FacetItem String LanguageMap Float
                                        friendlyFacetValue =
                                            List.filter (\(FacetItem itmVal _ _) -> value == itmVal) f.items
                                                |> List.head
                                                |> Maybe.map (\(FacetItem _ itmFriendly _) -> itmFriendly)
                                    in
                                    ( Select, f.label, friendlyFacetValue )

                                NotationFacetData f ->
                                    ( Notation, f.label, Nothing )
                    in
                    Just (ActiveFacet facetType facetLabel alias value friendlyValue)

                Nothing ->
                    Nothing
    in
    activeFacet
