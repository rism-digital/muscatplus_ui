module Page.UI.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, above, alignLeft, alignTop, centerX, centerY, column, fill, height, none, onRight, padding, paddingEach, paragraph, px, row, shrink, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input exposing (labelHidden)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Page.RecordTypes.Search exposing (RangeFacet, RangeFacetValue(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (emptyAttribute, lineSpacing)
import Page.UI.Components exposing (h4)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (facetHelp, facetTooltip)
import Page.UpdateHelpers exposing (selectAppropriateRangeFacetValues)


type alias RangeFacetConfig msg =
    { language : Language
    , tooltip : LanguageMap
    , rangeFacet : RangeFacet
    , activeSearch : ActiveSearch msg
    , userLostFocusMsg : FacetAlias -> msg
    , userFocusedMsg : FacetAlias -> msg
    , userEnteredTextMsg : FacetAlias -> RangeFacetValue -> String -> msg
    }


rangeFacetHelp : String
rangeFacetHelp =
    """
    Filter using four digit year values, e.g., 1650. Unlimited ranges are indicated with a '*', e.g., '1650 TO *' would
    find all records from 1650 onwards.
    """


inputIsValid : String -> String -> ( Bool, Maybe String )
inputIsValid boxIndicator inp =
    if String.trim inp /= "*" && String.trim inp /= "" && not (String.all Char.isDigit (String.trim inp)) then
        ( False
        , Just (boxIndicator ++ ": Please enter only numbers or a '*'")
        )

    else if String.length inp > 4 then
        ( False
        , Just (boxIndicator ++ ": Values of more than four digits are not valid")
        )

    else
        ( True, Nothing )


validateInput : Maybe String -> Element msg
validateInput errorMessage =
    case errorMessage of
        Just eMsg ->
            row
                []
                [ paragraph
                    [ Background.color (colourScheme.red |> convertColorToElementColor)
                    , padding 4
                    , Font.color (colourScheme.white |> convertColorToElementColor)
                    ]
                    [ text eMsg ]
                ]

        Nothing ->
            none


viewRangeFacet : RangeFacetConfig msg -> Element msg
viewRangeFacet config =
    let
        facetAlias =
            .alias config.rangeFacet

        facetValues =
            selectAppropriateRangeFacetValues facetAlias config.activeSearch

        ( lowerValue, upperValue ) =
            case facetValues of
                Just ( l, u ) ->
                    ( l, u )

                Nothing ->
                    ( "*", "*" )

        ( lowerIsValid, lowerValidError ) =
            inputIsValid "Lower range" lowerValue

        ( upperIsValid, upperValidError ) =
            inputIsValid "Upper range" upperValue

        -- If both inputs are valid, then we emit the focus/unfocused event that
        -- will trigger a probe; if either is invalid then we do not set the event
        -- handler.
        bothAreValid =
            lowerIsValid && upperIsValid

        ( focusLostEventLower, focusedEventLower ) =
            if bothAreValid then
                ( Events.onLoseFocus (config.userLostFocusMsg facetAlias)
                , Events.onFocus (config.userFocusedMsg facetAlias)
                )

            else
                ( emptyAttribute, emptyAttribute )

        ( focusLostEventUpper, focusedEventUpper ) =
            if bothAreValid then
                ( Events.onLoseFocus (config.userLostFocusMsg facetAlias)
                , Events.onFocus (config.userFocusedMsg facetAlias)
                )

            else
                ( emptyAttribute, emptyAttribute )

        lowerValueBorder =
            if not lowerIsValid then
                Element.focused [ Border.color (colourScheme.red |> convertColorToElementColor) ]

            else
                emptyAttribute

        upperValueBorder =
            if not upperIsValid then
                Element.focused [ Border.color (colourScheme.red |> convertColorToElementColor) ]

            else
                emptyAttribute
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        , paddingEach { top = 0, bottom = 14, left = 0, right = 0 }
        ]
        [ column
            [ width fill
            , alignTop
            , spacing lineSpacing
            , paddingEach { top = 0, bottom = 0, left = 14, right = 0 }
            , Border.widthEach { top = 0, bottom = 0, left = 2, right = 0 }
            , Border.color (colourScheme.midGrey |> convertColorToElementColor)
            ]
            [ row
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ column
                    [ width shrink
                    , height shrink
                    , centerX
                    , centerY
                    ]
                    [ facetTooltip onRight (extractLabelFromLanguageMap config.language config.tooltip) ]
                , column
                    [ width fill
                    , alignLeft
                    , centerY
                    ]
                    [ row
                        [ spacing 10 ]
                        [ h4 config.language (.label config.rangeFacet) ]
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
                        , focusLostEventLower
                        , focusedEventLower
                        , lowerValueBorder
                        ]
                        { label = labelHidden ""
                        , onChange = \c -> config.userEnteredTextMsg facetAlias LowerRangeValue c
                        , placeholder = Nothing
                        , text = lowerValue
                        }
                    ]
                , column
                    []
                    [ text "TO" ]
                , column
                    [ spacing lineSpacing ]
                    [ Input.text
                        [ width (px 80)
                        , focusLostEventUpper
                        , focusedEventUpper
                        , upperValueBorder
                        ]
                        { label = labelHidden ""
                        , onChange = \c -> config.userEnteredTextMsg facetAlias UpperRangeValue c
                        , placeholder = Nothing
                        , text = upperValue
                        }
                    ]
                , column
                    [ width fill ]
                    [ validateInput lowerValidError
                    , validateInput upperValidError
                    ]
                ]
            , row
                []
                [ column
                    [ width shrink
                    , height shrink
                    , centerX
                    , centerY
                    ]
                    [ facetHelp above rangeFacetHelp ]
                ]
            ]
        ]
