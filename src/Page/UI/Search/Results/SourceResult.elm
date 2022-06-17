module Page.UI.Search.Results.SourceResult exposing (viewSourceSearchResult)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, link, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Search exposing (SourceResultBody, SourceResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (calendarSvg, digitizedImagesSvg, iiifLogo, layerGroupSvg, musicNotationSvg, peopleSvg, sourcesSvg, userCircleSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultIsSelected, resultTemplate, viewSearchResultSummaryField)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewSourceFlags : Language -> SourceResultFlags -> Element msg
viewSourceFlags language flags =
    let
        -- TODO: Translate the labels!
        hasDigitizationFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.turquoise
                    , foreground = colourScheme.white
                    }
                    (digitizedImagesSvg colourScheme.white)
                    "Has digitization"
                )
                flags.hasDigitization

        iiifFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.white
                    , foreground = colourScheme.black
                    }
                    iiifLogo
                    "Has IIIF Manifest"
                )
                flags.hasIIIFManifest

        incipitFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.red
                    , foreground = colourScheme.white
                    }
                    (musicNotationSvg colourScheme.white)
                    "Has incipits"
                )
                flags.hasIncipits
    in
    row
        [ width fill
        , spacing 10
        ]
        [ incipitFlag
        , hasDigitizationFlag
        , iiifFlag
        ]


viewSourcePartOf : Language -> Color -> PartOfSectionBody -> Element msg
viewSourcePartOf language fontLinkColour partOfBody =
    row
        [ width fill
        , bodyRegular
        ]
        [ column
            [ width fill
            ]
            [ row
                [ width fill ]
                [ text "Part of " -- TODO: Translate!
                , link
                    [ Font.color (fontLinkColour |> convertColorToElementColor) ]
                    { label = text (extractLabelFromLanguageMap language <| .label partOfBody.source)
                    , url = .id partOfBody.source
                    }
                ]
            ]
        ]


viewSourceSearchResult :
    SearchResultConfig msg
    -> SourceResultBody
    -> Element msg
viewSourceSearchResult { language, selectedResult, clickForPreviewMsg } body =
    let
        resultBody =
            [ viewMaybe (viewSourceSummary language resultColours.iconColour) body.summary
            , viewMaybe (viewSourcePartOf language resultColours.fontLinkColour) body.partOf
            , viewMaybe (viewSourceFlags language) body.flags
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


viewSourceSummary : Language -> Color -> Dict String LabelValue -> Element msg
viewSourceSummary language iconColour summary =
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
                    , icon = peopleSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "sourceComposers"
                    , displayStyles = []
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = userCircleSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "sourceComposer"
                    , displayStyles = []
                    }
                    summary
                ]
            , row
                [ width fill
                , spacing 20
                ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = calendarSvg iconColour
                    , includeLabelInValue = False
                    , fieldName = "dateStatements"
                    , displayStyles = []
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = layerGroupSvg iconColour
                    , includeLabelInValue = True
                    , fieldName = "numItems"
                    , displayStyles = []
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = sourcesSvg iconColour
                    , includeLabelInValue = True
                    , fieldName = "numExemplars"
                    , displayStyles = []
                    }
                    summary
                ]
            ]
        ]
