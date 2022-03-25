module Page.Search.Views.Results.InstitutionResult exposing (..)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, none, row, spacing, width)
import Language exposing (Language, formatNumberByLanguage)
import Page.RecordTypes.Search exposing (InstitutionResultBody, InstitutionResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.Search.Msg exposing (SearchMsg)
import Page.Search.Views.Results exposing (resultIsSelected, resultTemplate, viewSearchResultSummaryField)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (globeStandSvg, sourcesSvg)
import Page.UI.Style exposing (colourScheme)


viewInstitutionSearchResult : Language -> Maybe String -> InstitutionResultBody -> Element SearchMsg
viewInstitutionSearchResult language selectedResult body =
    let
        resultColours =
            resultIsSelected selectedResult body.id

        resultBody =
            [ viewMaybe (viewInstitutionSummary language resultColours.iconColour) body.summary ]
    in
    resultTemplate
        { id = body.id
        , language = language
        , resultTitle = body.label
        , colours = resultColours
        , resultBody = resultBody
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
                    , icon = globeStandSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "countryName"
                    , displayStyles = []
                    }
                    summary
                ]
            ]
        ]


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
                    { foreground = colourScheme.white
                    , background = colourScheme.darkOrange
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
