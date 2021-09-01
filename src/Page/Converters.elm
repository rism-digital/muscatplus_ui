module Page.Converters exposing (..)

import Basics as Math
import Dict exposing (Dict)
import List.Extra as LE
import Page.Query exposing (Filter(..))
import Page.RecordTypes.ResultMode exposing (ResultMode, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..), RangeFacet)
import Page.UI.Facets.RangeSlider as RangeSlider exposing (RangeSlider)


convertFacetToFilter : String -> FacetItem -> Filter
convertFacetToFilter name facet =
    let
        (FacetItem qval _ _) =
            facet
    in
    Filter name qval


convertFacetToResultMode : FacetItem -> ResultMode
convertFacetToResultMode facet =
    let
        (FacetItem qval _ _) =
            facet
    in
    parseStringToResultMode qval


{-|

    A generic filterMap function that operates on Dictionaries.

-}
filterMap : (comparable -> a -> Maybe b) -> Dict comparable a -> Dict comparable b
filterMap f dict =
    Dict.foldl
        (\k v acc ->
            case f k v of
                Just newVal ->
                    Dict.insert k newVal acc

                Nothing ->
                    acc
        )
        Dict.empty
        dict


convertRangeFacetToRangeSlider : RangeFacet -> RangeSlider
convertRangeFacetToRangeSlider rangeFacet =
    let
        valueRange =
            rangeFacet.range

        minLabelValue =
            valueRange.min

        minValue =
            minLabelValue.value

        maxLabelValue =
            valueRange.max

        maxValue =
            maxLabelValue.value

        lowerLabelValue =
            valueRange.lower

        lowerValue =
            lowerLabelValue.value

        upperLabelValue =
            valueRange.upper

        upperValue =
            upperLabelValue.value

        stepSize =
            Math.round ((maxValue - minValue) / 50.0)

        timeAxis =
            LE.initialize 50
                (\idx ->
                    ( let
                        tickValue =
                            Math.round minValue + (stepSize * idx)

                        idxValue =
                            if tickValue > Math.round maxValue then
                                Math.round maxValue

                            else
                                tickValue
                      in
                      idxValue
                    , False
                    )
                )
                |> List.map (\( timePoint, isLabelled ) -> RangeSlider.AxisTick (Math.toFloat timePoint) isLabelled)
    in
    RangeSlider.init
        |> RangeSlider.setExtents minValue maxValue
        |> RangeSlider.setValues minValue maxValue
        |> RangeSlider.setStepSize (Just (Math.toFloat stepSize))
        |> RangeSlider.setDimensions 400 75
        |> RangeSlider.setAxisTicks timeAxis
        |> RangeSlider.setValues lowerValue upperValue
