module Page.UI.Facets.RangeFacet exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, above, alignLeft, alignTop, column, fill, none, paragraph, px, row, spacing, spacingXY, text, width)
import Element.Events as Events
import Element.Input as Input exposing (labelHidden)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (RangeFacet, RangeFacetValue(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (h5)
import Page.UI.Tooltip exposing (facetHelp)


rangeFacetHelp =
    """
    Filter using four digit year values, e.g., 1650. Unlimited ranges are indicated with a '*', e.g., '1650 TO *' would
    find all records from 1650 onwards.
    """


type alias RangeFacetConfig msg =
    { language : Language
    , rangeFacet : RangeFacet
    , activeSearch : ActiveSearch msg
    , userLostFocusMsg : FacetAlias -> msg
    , userFocusedMsg : FacetAlias -> msg
    , userEnteredTextMsg : FacetAlias -> RangeFacetValue -> String -> msg
    }


validateInput : String -> String -> Element msg
validateInput boxIndicator value =
    let
        checkValue =
            String.trim value

        -- TODO: Translate!
        errorMessage : Maybe String
        errorMessage =
            if String.trim checkValue /= "*" && String.trim checkValue /= "" && not (String.all Char.isDigit <| String.trim checkValue) then
                Just (boxIndicator ++ ": Please enter only numbers or a '*'")

            else if String.length checkValue > 4 then
                Just (boxIndicator ++ ": Values of more than four digits are not valid")

            else
                Nothing
    in
    case errorMessage of
        Nothing ->
            none

        Just eMsg ->
            row
                []
                [ paragraph [] [ text eMsg ] ]


viewRangeFacet : RangeFacetConfig msg -> Element msg
viewRangeFacet config =
    let
        facetAlias =
            .alias config.rangeFacet

        ( lowerValue, upperValue ) =
            Dict.get facetAlias (.rangeFacetValues config.activeSearch)
                |> Maybe.withDefault ( "*", "*" )
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , alignTop
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ column
                    [ alignTop ]
                    [ facetHelp above rangeFacetHelp ]
                , column
                    [ width fill
                    , alignLeft
                    , alignTop
                    ]
                    [ row
                        [ spacing 10 ]
                        [ h5 config.language (.label config.rangeFacet) ]
                    ]
                ]
            , row
                [ width fill
                , spacingXY 10 0
                ]
                [ column
                    [ spacing lineSpacing ]
                    [ Input.text
                        [ width (px 80)
                        , Events.onLoseFocus (config.userLostFocusMsg facetAlias)
                        , Events.onFocus (config.userFocusedMsg facetAlias)
                        ]
                        { onChange = \c -> config.userEnteredTextMsg facetAlias LowerRangeValue c
                        , text = lowerValue
                        , placeholder = Nothing
                        , label = labelHidden ""
                        }
                    ]
                , column
                    []
                    [ text "TO" ]
                , column
                    [ spacing lineSpacing ]
                    [ Input.text
                        [ width (px 80)
                        , Events.onLoseFocus (config.userLostFocusMsg facetAlias)
                        , Events.onFocus (config.userFocusedMsg facetAlias)
                        ]
                        { onChange = \c -> config.userEnteredTextMsg facetAlias UpperRangeValue c
                        , text = upperValue
                        , placeholder = Nothing
                        , label = labelHidden ""
                        }
                    ]
                , column
                    [ width fill ]
                    [ validateInput "Lower range" lowerValue
                    , validateInput "Upper range" upperValue
                    ]
                ]
            ]
        ]
