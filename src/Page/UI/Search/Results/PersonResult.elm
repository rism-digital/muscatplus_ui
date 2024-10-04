module Page.UI.Search.Results.PersonResult exposing (viewPersonSearchResult)

import Dict exposing (Dict)
import Element exposing (Color, Element, alignRight, column, el, fill, maximum, onLeft, px, row, spacing, text, width)
import Language exposing (Language)
import Page.RecordTypes.Search exposing (PersonResultBody, PersonResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (bodyRegular, bodySM)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (briefcaseSvg, linkSvg, sourcesSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultTemplate, setResultColours, viewSearchResultSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewPersonSearchResult :
    SearchResultConfig msg
    -> PersonResultBody
    -> Element msg
viewPersonSearchResult { language, selectedResult, clickForPreviewMsg, resultIdx } body =
    let
        resultBody =
            [ viewMaybe (viewPersonSummary language resultColours.iconColour) body.summary
            , viewMaybe (viewPersonFlags language) body.flags
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


viewPersonFlags : Language -> PersonResultFlags -> Element msg
viewPersonFlags _ flags =
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
        , spacing 10
        ]
        [ linkedWithExternalRecordFlag
        , isDIAMMFlag
        ]


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
