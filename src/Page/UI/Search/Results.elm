module Page.UI.Search.Results exposing (ResultColours, ResultConfig, SearchResultConfig, SearchResultSummaryConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Attribute, Element, above, alignLeft, alignTop, centerY, column, el, fill, height, htmlAttribute, onLeft, padding, paddingXY, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Flip exposing (flip)
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, extractTextFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (emptyAttribute, lineSpacing)
import Page.UI.Components exposing (h3)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)
import Url
import Utilities exposing (choose, convertPathToNodeId)


type alias ResultColours =
    { backgroundColour : Color
    , fontLinkColour : Color
    , textColour : Color
    , iconColour : Color
    }


type alias ResultConfig msg =
    { id : String
    , language : Language
    , resultTitle : LanguageMap
    , colours : ResultColours
    , resultBody : List (Element msg)
    , clickMsg : String -> msg
    }


type alias SearchResultConfig msg =
    { language : Language
    , selectedResult : Maybe String
    , clickForPreviewMsg : String -> msg
    }


type alias SearchResultSummaryConfig msg =
    { language : Language
    , icon : Element msg
    , iconSize : Int
    , includeLabelInValue : Bool
    , fieldName : String
    , displayStyles : List (Attribute msg)
    , formatNumbers : Bool
    }


resultIsSelected : Maybe String -> String -> ResultColours
resultIsSelected selectedResult thisId =
    let
        isSelected =
            ME.unwrap False ((==) thisId) selectedResult
    in
    if isSelected then
        { backgroundColour = colourScheme.lightBlue
        , fontLinkColour = colourScheme.white
        , textColour = colourScheme.white
        , iconColour = colourScheme.white
        }

    else
        { backgroundColour = colourScheme.white
        , fontLinkColour = colourScheme.lightBlue
        , textColour = colourScheme.black
        , iconColour = colourScheme.slateGrey
        }


resultTemplate :
    ResultConfig msg
    -> Element msg
resultTemplate cfg =
    let
        resultRowNodeId =
            Url.fromString cfg.id
                |> ME.unpack (\() -> emptyAttribute)
                    (\u ->
                        String.dropLeft 1 u.path
                            |> convertPathToNodeId
                            |> HA.id
                            |> htmlAttribute
                    )
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        , Background.color (.backgroundColour cfg.colours |> convertColorToElementColor)
        , Font.color (.textColour cfg.colours |> convertColorToElementColor)
        , onClick (cfg.clickMsg cfg.id)
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.dotted
        , pointer
        , paddingXY 20 12
        , resultRowNodeId
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 10
            ]
            [ row
                [ width fill
                , alignLeft
                , alignTop
                ]
                [ el
                    [ Font.color (.fontLinkColour cfg.colours |> convertColorToElementColor)
                    , width fill
                    , alignTop
                    ]
                    (h3 cfg.language cfg.resultTitle)
                ]
            , row
                [ width fill
                , alignLeft
                , alignTop
                ]
                [ column
                    [ width fill
                    , alignLeft
                    , alignTop
                    , spacing lineSpacing
                    ]
                    cfg.resultBody
                ]
            ]
        ]


summaryFieldTemplate : SearchResultSummaryConfig msg -> LabelValue -> Element msg
summaryFieldTemplate summaryCfg fieldValue =
    let
        fLabel =
            extractLabelFromLanguageMap summaryCfg.language fieldValue.label

        fVal =
            extractTextFromLanguageMap summaryCfg.language fieldValue.value

        fValueLength =
            List.length fValueFormatted

        fValueFormatted =
            List.map
                (\f ->
                    choose summaryCfg.formatNumbers
                        (String.toInt f
                            |> ME.unpack (\() -> f)
                                (\num ->
                                    toFloat num
                                        |> formatNumberByLanguage summaryCfg.language
                                )
                        )
                        f
                )
                fVal

        allEntries =
            viewIf
                (column
                    tooltipStyle
                    (List.map (\t -> el [] (text t)) fVal)
                )
                (fValueLength > 3)

        expandedList =
            viewIf
                (el
                    [ tooltip onLeft allEntries
                    , padding 4
                    , Background.color (colourScheme.lightGrey |> convertColorToElementColor)
                    , Font.color (colourScheme.black |> convertColorToElementColor)
                    , centerY
                    ]
                    (text (extractLabelFromLanguageMap summaryCfg.language localTranslations.seeAll))
                )
                (fValueLength > 3)

        iconElement =
            el
                [ width (px summaryCfg.iconSize)
                , height (px summaryCfg.iconSize)
                , padding 2
                , centerY
                , el tooltipStyle (text fLabel)
                    |> tooltip above
                ]
                summaryCfg.icon

        fValueAsString =
            if fValueLength > 3 then
                List.take 3 fValueFormatted
                    |> String.join "; "
                    |> flip String.append " … "

            else
                String.join "; " fValueFormatted

        templatedVal =
            choose summaryCfg.includeLabelInValue (fValueAsString ++ " " ++ fLabel) fValueAsString
    in
    el
        [ spacing 5
        , alignTop
        ]
        (row
            [ spacing 5 ]
            [ iconElement
            , el
                [ centerY ]
                (el summaryCfg.displayStyles (text templatedVal))
            , expandedList
            ]
        )


viewSearchResultSummaryField : SearchResultSummaryConfig msg -> Dict String LabelValue -> Element msg
viewSearchResultSummaryField summaryCfg summaryField =
    Dict.get summaryCfg.fieldName summaryField
        |> viewMaybe (summaryFieldTemplate summaryCfg)
