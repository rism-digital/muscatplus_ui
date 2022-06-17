module Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionFlags, viewInstitutionSearchResult, viewInstitutionSummary)

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


viewInstitutionFlags : Language -> InstitutionResultFlags -> Element msg
viewInstitutionFlags language flags =
    let
        numSources =
            if flags.numberOfSources > 0 then
                let
                    labelText =
                        if flags.numberOfSources == 1 then
                            "1 Source"

                        else
                            formatNumberByLanguage language (toFloat flags.numberOfSources) ++ " Sources"
                in
                makeFlagIcon
                    { background = colourScheme.darkOrange
                    , foreground = colourScheme.white
                    }
                    (sourcesSvg colourScheme.white)
                    labelText

            else
                none
    in
    row
        [ width fill
        , spacing 10
        ]
        [ numSources
        ]


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
                [ width fill ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = mapMarkerSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "countryName"
                    , displayStyles = []
                    }
                    summary
                ]
            ]
        ]
