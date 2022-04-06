module Page.UI.Search.Results.PersonResult exposing (..)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, none, row, spacing, width)
import Language exposing (Language, formatNumberByLanguage)
import Page.RecordTypes.Search exposing (PersonResultBody, PersonResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (briefcaseSvg, sourcesSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)
import Page.UI.Style exposing (colourScheme)


viewPersonSearchResult :
    SearchResultConfig PersonResultBody msg
    -> Element msg
viewPersonSearchResult { language, selectedResult, body, clickForPreviewMsg } =
    let
        resultColours =
            resultIsSelected selectedResult body.id

        resultBody =
            [ viewMaybe (viewPersonSummary language resultColours.iconColour) body.summary ]
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
                [ width fill ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = briefcaseSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "roles"
                    , displayStyles = []
                    }
                    summary
                ]
            ]
        ]


viewPersonFlags : Language -> PersonResultFlags -> Element msg
viewPersonFlags language flags =
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
        [ numSources ]
