module Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionSearchResult)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, none, row, spacing, width)
import Language exposing (Language, formatNumberByLanguage)
import Page.RecordTypes.Search exposing (InstitutionResultBody, InstitutionResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (mapMarkerSvg, sourcesSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)
import Page.UI.Style exposing (colourScheme)


viewInstitutionSearchResult :
    SearchResultConfig msg
    -> InstitutionResultBody
    -> Element msg
viewInstitutionSearchResult { language, selectedResult, clickForPreviewMsg } body =
    let
        resultBody =
            [ viewMaybe (viewInstitutionSummary language resultColours.iconColour) body.summary ]

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


viewInstitutionSummary : Language -> Color -> Dict String LabelValue -> Element msg
viewInstitutionSummary language iconColour summary =
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
                    , icon = mapMarkerSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "countryName"
                    , displayStyles = []
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = sourcesSvg iconColour
                    , includeLabelInValue = True
                    , fieldName = "totalHoldings"
                    , displayStyles = []
                    }
                    summary
                ]
            ]
        ]
