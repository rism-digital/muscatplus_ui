module Page.Search.Views.Results exposing (..)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Attribute, Element, above, alignLeft, alignTop, centerY, column, el, fill, height, htmlAttribute, onLeft, padding, paddingXY, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Flip exposing (flip)
import Html.Attributes as HTA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, extractTextFromLanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (emptyAttribute, lineSpacing)
import Page.UI.Components exposing (h3)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)
import Url
import Utlities exposing (convertPathToNodeId)


type alias SearchResultSummaryConfig msg =
    { language : Language
    , icon : Element msg
    , includeLabelInValue : Bool
    , fieldName : String
    , displayStyles : List (Attribute msg)
    }


summaryFieldTemplate : SearchResultSummaryConfig msg -> LabelValue -> Element msg
summaryFieldTemplate summaryCfg fieldValue =
    let
        fLabel =
            extractLabelFromLanguageMap summaryCfg.language fieldValue.label

        fVal =
            extractTextFromLanguageMap summaryCfg.language fieldValue.value

        iconElement =
            el
                [ width <| px 20
                , height <| px 20
                , centerY
                , tooltip above <|
                    el
                        tooltipStyle
                        (text fLabel)
                ]
                summaryCfg.icon

        fValueLength =
            List.length fVal

        fValueAsString =
            if fValueLength > 3 then
                List.take 3 fVal
                    |> String.join "; "
                    |> flip String.append " … "

            else
                String.join "; " fVal

        templatedVal =
            if summaryCfg.includeLabelInValue then
                fValueAsString ++ " " ++ fLabel

            else
                fValueAsString

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
                    (text "See all")
                )
                (fValueLength > 3)
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


type alias ResultColours =
    { backgroundColour : Color
    , fontLinkColour : Color
    , textColour : Color
    , iconColour : Color
    }


resultIsSelected : Maybe String -> String -> ResultColours
resultIsSelected selectedResult thisId =
    let
        isSelected =
            case selectedResult of
                Just r ->
                    r == thisId

                Nothing ->
                    False
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


type alias ResultConfig msg =
    { id : String
    , language : Language
    , resultTitle : LanguageMap
    , colours : ResultColours
    , resultBody : List (Element msg)
    , clickMsg : String -> msg
    }


resultTemplate : ResultConfig msg -> Element msg
resultTemplate cfg =
    let
        resultRowNodeId =
            case Url.fromString cfg.id of
                Just u ->
                    String.dropLeft 1 u.path
                        |> convertPathToNodeId
                        |> HTA.id
                        |> htmlAttribute

                Nothing ->
                    emptyAttribute
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        , Background.color (.backgroundColour cfg.colours |> convertColorToElementColor)
        , Font.color (.textColour cfg.colours |> convertColorToElementColor)
        , onClick (cfg.clickMsg cfg.id)
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
        , Border.dotted
        , pointer
        , paddingXY 20 20
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
