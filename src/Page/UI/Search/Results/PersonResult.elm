module Page.UI.Search.Results.PersonResult exposing (viewPersonSearchResult)

import Dict exposing (Dict)
import Element exposing (Color, Element, column, fill, maximum, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (PersonResultBody, PersonResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (bodyRegular, bodySM)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (briefcaseSvg, penNibSvg, sourcesSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)
import Page.UI.Style exposing (colourScheme)


viewPersonFlags : Language -> PersonResultFlags -> Element msg
viewPersonFlags language flags =
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


viewPersonSearchResult :
    SearchResultConfig msg
    -> PersonResultBody
    -> Element msg
viewPersonSearchResult { language, selectedResult, clickForPreviewMsg } body =
    let
        resultBody =
            [ viewMaybe (viewPersonSummary language resultColours.iconColour) body.summary

            --, viewMaybe (viewPersonFlags language) body.flags
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


viewPersonSummary : Language -> Color -> Dict String LabelValue -> Element msg
viewPersonSummary language iconColour summary =
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
                    , icon = briefcaseSvg iconColour
                    , iconSize = 20
                    , includeLabelInValue = False
                    , fieldName = "roles"
                    , displayStyles = [ bodyRegular ]
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
                    , iconSize = 18
                    , includeLabelInValue = True
                    , fieldName = "numSources"
                    , displayStyles =
                        [ bodySM
                        ]
                    , formatNumbers = True
                    }
                    summary
                ]
            ]
        ]
