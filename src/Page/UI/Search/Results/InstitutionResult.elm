module Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionSearchResult)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, row, spacing, width)
import Element.Font as Font
import Language exposing (Language)
import Page.RecordTypes.Search exposing (InstitutionResultBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (mapMarkerSvg, sourcesSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)


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
                    , iconSize = 20
                    , includeLabelInValue = False
                    , fieldName = "countryName"
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
                    , icon = sourcesSvg iconColour
                    , iconSize = 15
                    , includeLabelInValue = True
                    , fieldName = "totalSources"
                    , displayStyles =
                        [ Font.size 12 ]
                    , formatNumbers = True
                    }
                    summary
                ]
            ]
        ]
