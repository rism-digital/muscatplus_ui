module Page.UI.Search.Results.SourceResult exposing (viewSourceSearchResult)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, link, maximum, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Search exposing (SourceResultBody, SourceResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.UI.Attributes exposing (bodyRegular, bodySM)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (calendarSvg, digitizedImagesSvg, iiifLogo, layerGroupSvg, musicNotationSvg, penNibSvg, peopleSvg, sourcesSvg, userCircleSvg)
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
                    (extractLabelFromLanguageMap language localTranslations.hasDigitization)
                )
                flags.hasDigitization

        iiifFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.white
                    , foreground = colourScheme.black
                    }
                    iiifLogo
                    (extractLabelFromLanguageMap language localTranslations.hasIIIFManifest)
                )
                flags.hasIIIFManifest

        incipitFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.red
                    , foreground = colourScheme.white
                    }
                    (musicNotationSvg colourScheme.white)
                    (extractLabelFromLanguageMap language localTranslations.hasIncipits)
                )
                flags.hasIncipits

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
        [ incipitFlag
        , hasDigitizationFlag
        , iiifFlag
        , isDIAMMFlag
        , hasDIAMMFlag
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
                [ text (extractLabelFromLanguageMap language localTranslations.partOf ++ " ")
                , link
                    [ Font.color (fontLinkColour |> convertColorToElementColor) ]
                    { label = text (extractLabelFromLanguageMap language (.label partOfBody.source))
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

            --, viewMaybe (viewSourceFlags language) body.flags
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
    let
        composerInfo =
            if Dict.member "sourceComposer" summary then
                viewSearchResultSummaryField
                    { language = language
                    , icon = userCircleSvg iconColour
                    , iconSize = 20
                    , includeLabelInValue = False
                    , fieldName = "sourceComposer"
                    , displayStyles = [ bodyRegular ]
                    , formatNumbers = False
                    }
                    summary

            else
                viewSearchResultSummaryField
                    { language = language
                    , icon = peopleSvg iconColour
                    , iconSize = 20
                    , includeLabelInValue = False
                    , fieldName = "sourceComposers"
                    , displayStyles =
                        [ bodyRegular
                        ]
                    , formatNumbers = False
                    }
                    summary
    in
    row
        [ width (fill |> maximum 600) ]
        [ column
            [ spacing 5
            , width fill
            ]
            [ row
                [ spacing 20
                , width fill
                ]
                [ composerInfo
                ]
            , row
                [ spacing 20
                , width fill
                ]
                [ viewSearchResultSummaryField
                    { language = language
                    , icon = calendarSvg iconColour
                    , iconSize = 18
                    , includeLabelInValue = False
                    , fieldName = "dateStatements"
                    , displayStyles =
                        [ bodySM
                        ]
                    , formatNumbers = False
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = layerGroupSvg iconColour
                    , iconSize = 18
                    , includeLabelInValue = True
                    , fieldName = "numItems"
                    , displayStyles =
                        [ bodySM
                        ]
                    , formatNumbers = True
                    }
                    summary
                , viewSearchResultSummaryField
                    { language = language
                    , icon = sourcesSvg iconColour
                    , iconSize = 18
                    , includeLabelInValue = True
                    , fieldName = "numExemplars"
                    , displayStyles =
                        [ bodySM
                        ]
                    , formatNumbers = True
                    }
                    summary
                ]
            ]
        ]
