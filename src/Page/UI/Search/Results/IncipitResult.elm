module Page.UI.Search.Results.IncipitResult exposing (viewIncipitSearchResult)

import Dict exposing (Dict)
import Element exposing (Color, Element, column, el, fill, htmlAttribute, maximum, row, spacing, width)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language)
import Maybe.Extra as ME
import Page.RecordTypes.Incipit exposing (RenderedIncipit)
import Page.RecordTypes.Search exposing (IncipitResultBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (bodySM, emptyAttribute)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (musicListSvg, peopleSvg, sourcesSvg, textIconSvg)
import Page.UI.Record.Incipits exposing (viewRenderedIncipits)
import Page.UI.Search.Results exposing (SearchResultConfig, resultTemplate, setResultColours, viewSearchResultSummaryField)


viewIncipitSearchResult :
    SearchResultConfig msg
    -> IncipitResultBody
    -> Element msg
viewIncipitSearchResult { language, selectedResult, clickForPreviewMsg, resultIdx } body =
    let
        isSelected =
            ME.unwrap False ((==) body.id) selectedResult

        resultBody =
            [ viewMaybe (viewIncipitSummary language resultColours.iconColour) body.summary
            , viewMaybe (viewSearchResultIncipits isSelected) body.renderedIncipits
            ]

        resultColours =
            setResultColours resultIdx selectedResult body.id
    in
    resultTemplate
        { id = body.id
        , language = language
        , resultTitle = body.label
        , colours = resultColours
        , resultBody = resultBody
        , clickMsg = clickForPreviewMsg
        }


viewSearchResultIncipits : Bool -> List RenderedIncipit -> Element msg
viewSearchResultIncipits isSelected incipits =
    el
        [ width (fill |> maximum 600)
        , if isSelected then
            htmlAttribute (HA.class "result-selected")

          else
            emptyAttribute
        ]
        (viewRenderedIncipits incipits)


viewIncipitSummary : Language -> Color -> Dict String LabelValue -> Element msg
viewIncipitSummary language iconColour summary =
    row
        [ width (fill |> maximum 600) ]
        [ column
            [ spacing 5
            , width fill
            ]
            [ row
                [ spacing 20
                ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = sourcesSvg iconColour
                    , iconSize = 20
                    , includeLabelInValue = False
                    , fieldName = "sourceTitle"
                    , displayStyles = []
                    , formatNumbers = False
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = peopleSvg iconColour
                    , iconSize = 20
                    , includeLabelInValue = False
                    , fieldName = "incipitComposer"
                    , displayStyles = []
                    , formatNumbers = False
                    }
                    summary
                ]
            , row
                [ width fill
                , spacing 20
                ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = textIconSvg iconColour
                    , iconSize = 18
                    , includeLabelInValue = False
                    , fieldName = "textIncipit"
                    , displayStyles = [ bodySM, Font.italic ]
                    , formatNumbers = False
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = musicListSvg iconColour
                    , iconSize = 18
                    , includeLabelInValue = False
                    , fieldName = "voiceInstrument"
                    , displayStyles = [ bodySM ]
                    , formatNumbers = False
                    }
                    summary
                ]
            ]
        ]
