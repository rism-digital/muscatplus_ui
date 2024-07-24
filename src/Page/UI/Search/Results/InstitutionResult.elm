module Page.UI.Search.Results.InstitutionResult exposing (viewInstitutionSearchResult)

import Dict exposing (Dict)
import Element exposing (Color, Element, alignRight, column, el, fill, maximum, onLeft, px, row, spacing, spacingXY, text, width)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (InstitutionResultBody, InstitutionResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.CantusLogo exposing (cantusLogo)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (altSvg, linkSvg, mapMarkerSvg, sourcesSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultTemplate, setResultColours, viewSearchResultSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewInstitutionSearchResult :
    SearchResultConfig msg
    -> InstitutionResultBody
    -> Element msg
viewInstitutionSearchResult { language, selectedResult, clickForPreviewMsg, resultIdx } body =
    let
        resultBody =
            [ viewMaybe (viewInstitutionSummary language resultColours.iconColour) body.summary
            , viewMaybe (viewInstitutionFlags language) body.flags
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
            , row
                [ width fill
                , spacing 20
                ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = altSvg iconColour
                    , iconSize = 20
                    , includeLabelInValue = False
                    , fieldName = "otherNames"
                    , displayStyles = [ bodyRegular ]
                    , formatNumbers = False
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
                (el
                    [ width (px 60)
                    , alignRight
                    , el tooltipStyle (text "Source: DIAMM")
                        |> tooltip onLeft
                    ]
                    diammLogo
                )
                flags.isDIAMMRecord

        isCantusFlag =
            viewIf
                (el
                    [ width (px 60)
                    , alignRight
                    , el tooltipStyle (text "Source: Cantus")
                        |> tooltip onLeft
                    ]
                    cantusLogo
                )
                flags.isCantusRecord

        linkedWithExternalRecordFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.olive
                    }
                    (linkSvg colourScheme.white)
                    "Linked with DIAMM"
                )
                flags.linkedWithExternalRecord
    in
    row
        [ width fill
        , spacingXY 5 0
        ]
        [ linkedWithExternalRecordFlag
        , isDIAMMFlag
        , isCantusFlag
        ]
