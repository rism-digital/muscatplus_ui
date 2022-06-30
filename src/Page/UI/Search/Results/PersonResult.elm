module Page.UI.Search.Results.PersonResult exposing (viewPersonSearchResult)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (PersonResultBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (briefcaseSvg, sourcesSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)


viewPersonSearchResult :
    SearchResultConfig msg
    -> PersonResultBody
    -> Element msg
viewPersonSearchResult { language, selectedResult, clickForPreviewMsg } body =
    let
        resultBody =
            [ viewMaybe (viewPersonSummary language resultColours.iconColour) body.summary ]

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


viewPersonSummary : Language -> Color -> Dict String LabelValue -> Element msg
viewPersonSummary language iconColour summary =
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
                    , icon = briefcaseSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "roles"
                    , displayStyles = []
                    , formatNumbers = False
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = sourcesSvg iconColour
                    , includeLabelInValue = True
                    , fieldName = "numSources"
                    , displayStyles = []
                    , formatNumbers = True
                    }
                    summary
                ]
            ]
        ]
