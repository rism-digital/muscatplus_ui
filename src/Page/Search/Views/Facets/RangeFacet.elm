module Page.Search.Views.Facets.RangeFacet exposing (..)

import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignTop, column, fill, padding, paddingXY, px, row, spacing, text, width)
import Element.Input as Input exposing (labelHidden)
import Language exposing (Language)
import Page.Query exposing (rangeStringParser)
import Page.RecordTypes.Search exposing (RangeFacet)
import Page.RecordTypes.Shared exposing (FacetAlias, toNumericValue)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (h5)


viewRangeFacet : Language -> Dict FacetAlias (List String) -> RangeFacet -> Element SearchMsg
viewRangeFacet language activeFilters body =
    let
        rangeValues =
            body.range

        facetAlias =
            body.alias

        lowerValue =
            toNumericValue rangeValues.lower

        upperValue =
            toNumericValue rangeValues.upper

        -- returns a list of fully composed range query string, e.g.,
        -- ["[* TO 1900]"]. If it doesn't
        currentValue : List String
        currentValue =
            Dict.get facetAlias activeFilters
                |> Maybe.withDefault []

        ( upperParsedValue, lowerParsedValue ) =
            case currentValue of
                [] ->
                    ( "*", "*" )

                x :: _ ->
                    rangeStringParser x

        parsedLowerValue : Float
        parsedLowerValue =
            if lowerParsedValue == "*" then
                lowerValue

            else
                String.toFloat lowerParsedValue
                    |> Maybe.withDefault lowerValue

        parsedUpperValue : Float
        parsedUpperValue =
            if upperParsedValue == "*" then
                upperValue

            else
                String.toFloat upperParsedValue
                    |> Maybe.withDefault upperValue

        lowerValueIsOutOfRange : Bool
        lowerValueIsOutOfRange =
            parsedLowerValue < lowerValue || parsedLowerValue > upperValue

        upperValueIsOutOfRange : Bool
        upperValueIsOutOfRange =
            parsedUpperValue > upperValue || parsedUpperValue < lowerValue

        lowerValueValidate : String -> String
        lowerValueValidate inp =
            if String.all Char.isDigit inp || inp == "*" then
                inp

            else
                lowerParsedValue

        upperValueValidate : String -> String
        upperValueValidate inp =
            if String.all Char.isDigit inp || inp == "*" then
                inp

            else
                upperParsedValue
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ row
                [ width fill
                , alignTop
                , padding 10
                , spacing lineSpacing
                ]
                [ column
                    [ width fill
                    , alignLeft
                    , alignTop
                    ]
                    [ row
                        [ spacing 10 ]
                        [ h5 language body.label ]
                    ]
                ]
            , row
                [ width fill
                , paddingXY 20 10
                ]
                [ column
                    [ spacing lineSpacing ]
                    [ Input.text
                        [ width (px 80) ]
                        { onChange = \c -> UserEnteredTextInRangeFacet facetAlias ( lowerValueValidate c, upperParsedValue )
                        , text = lowerParsedValue
                        , placeholder = Nothing
                        , label = labelHidden ""
                        }
                    ]
                , column
                    []
                    [ Input.text
                        [ width (px 80) ]
                        { onChange = \c -> UserEnteredTextInRangeFacet facetAlias ( lowerParsedValue, upperValueValidate c )
                        , text = upperParsedValue
                        , placeholder = Nothing
                        , label = labelHidden ""
                        }
                    ]
                ]
            ]
        ]
