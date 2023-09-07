module Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionSearchResult)

import Dict exposing (Dict)
import Element exposing (Color, Element, column, fill, maximum, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (InstitutionResultBody, InstitutionResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (mapMarkerSvg, penNibSvg, sourcesSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)
import Page.UI.Style exposing (colourScheme)


viewInstitutionSearchResult :
    SearchResultConfig msg
    -> InstitutionResultBody
    -> Element msg
viewInstitutionSearchResult { language, selectedResult, clickForPreviewMsg } body =
    let
        resultBody =
            [ viewMaybe (viewInstitutionSummary language resultColours.iconColour) body.summary

            --, viewMaybe (viewInstitutionFlags language) body.flags
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


viewInstitutionSummary : Language -> Color -> Dict String LabelValue -> Element msg
viewInstitutionSummary language iconColour summary =
    row
        [ width (fill |> maximum 600) ]
        [ column
            [ spacing 5
            , width fill
            ]
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
                    , displayStyles = [ bodyRegular ]
                    , formatNumbers = False
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = sourcesSvg iconColour
                    , iconSize = 20
                    , includeLabelInValue = True
                    , fieldName = "totalSources"
                    , displayStyles =
                        [ bodyRegular ]
                    , formatNumbers = True
                    }
                    summary
                ]
            ]
        ]


viewInstitutionFlags : Language -> InstitutionResultFlags -> Element msg
viewInstitutionFlags language flags =
    let
        isDIAMMFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.darkBlue
                    , foreground = colourScheme.white
                    }
                    (penNibSvg colourScheme.white)
                    "Is DIAMM"
                )
                flags.isDIAMMRecord

        hasDIAMMFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.yellow
                    , foreground = colourScheme.black
                    }
                    (penNibSvg colourScheme.black)
                    "Has DIAMM"
                )
                flags.hasDIAMMRecord
    in
    row
        [ width fill
        , spacing 10
        ]
        [ isDIAMMFlag
        , hasDIAMMFlag
        ]
