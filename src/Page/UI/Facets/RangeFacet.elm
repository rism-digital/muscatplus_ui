module Page.UI.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, above, alignLeft, alignTop, column, fill, height, padding, paragraph, px, row, shrink, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input exposing (labelHidden)
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Search exposing (RangeFacet, RangeFacetValue(..))
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (emptyAttribute, lineSpacing)
import Page.UI.Facets.Shared exposing (facetTitleBar)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (facetHelp)
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
    Filter using a range of numeric values, e.g., 1650. Unlimited ranges are indicated with a '*', e.g., '1650 TO *' would
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
    viewMaybe
        (\eMsg ->
            row
                []
                [ paragraph
                    [ Background.color colourScheme.red
                    , padding 4
                    , Font.color colourScheme.white
                    ]
                    [ text eMsg ]
                ]
        )
        errorMessage


viewRangeFacet : RangeFacetConfig msg -> Element msg
viewRangeFacet config =
    let
        bothAreValid =
            lowerIsValid && upperIsValid

        facetAlias =
            .alias config.rangeFacet

        facetValues =
            selectAppropriateRangeFacetValues facetAlias config.activeSearch

        ( lowerValue, upperValue ) =
            Maybe.withDefault ( "*", "*" ) facetValues

        ( lowerIsValid, lowerValidError ) =
            inputIsValid "Lower range" lowerValue

        -- If both inputs are valid, then we emit the focus/unfocused event that
        -- will trigger a probe; if either is invalid then we do not set the event
        -- handler.
        ( upperIsValid, upperValidError ) =
            inputIsValid "Upper range" upperValue

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
                Element.focused [ Border.color colourScheme.red ]

            else
                emptyAttribute

        upperValueBorder =
            if not upperIsValid then
                Element.focused [ Border.color colourScheme.red ]

            else
                emptyAttribute

        titleBar =
            facetTitleBar
                { extraControls = []
                , language = config.language
                , title = .label config.rangeFacet
                , tooltip = config.tooltip
                }
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
            [ titleBar
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
                    [ width shrink
                    , height shrink
                    , alignLeft
                    , alignTop
                    ]
                    [ facetHelp above rangeFacetHelp ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ validateInput lowerValidError
                    , validateInput upperValidError
                    ]
                ]
            ]
        ]
