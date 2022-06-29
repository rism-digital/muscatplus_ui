module Page.UI.Search.Results.IncipitResult exposing (viewIncipitSearchResult)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, row, spacing, width)
import Element.Font as Font
import Language exposing (Language)
import Page.RecordTypes.Search exposing (IncipitResultBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (musicListSvg, peopleSvg, textIconSvg)
import Page.UI.Record.Incipits exposing (viewRenderedIncipits)
import Page.UI.Search.Results exposing (SearchResultConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)


viewIncipitSearchResult :
    SearchResultConfig msg
    -> IncipitResultBody
    -> Element msg
viewIncipitSearchResult { language, selectedResult, clickForPreviewMsg } body =
    let
        resultBody =
            [ viewMaybe (viewIncipitSummary language resultColours.iconColour) body.summary
            , viewMaybe viewRenderedIncipits body.renderedIncipits
            ]

        resultColours =
            resultIsSelected selectedResult body.id
    in
    resultTemplate
        { id = body.id
        , language = language
        , resultTitle = body.label
        , colours = resultColours
        , resultBody = resultBody
        , clickMsg = clickForPreviewMsg
        }


viewIncipitSummary : Language -> Color -> Dict String LabelValue -> Element msg
viewIncipitSummary language iconColour summary =
    row
        [ width fill ]
        [ column
            [ spacing 5 ]
            [ row
                [ width fill
                , spacing 20
                ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = peopleSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "incipitComposer"
                    , displayStyles = []
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = musicListSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "voiceInstrument"
                    , displayStyles = []
                    }
                    summary
                ]
            , row
                [ width fill ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = textIconSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "textIncipit"
                    , displayStyles = [ Font.italic ]
                    }
                    summary
                ]
            ]
        ]
