module Page.Search.Views.Results.SourceResult exposing (..)

import Color exposing (Color)
import Dict exposing (Dict)
import Element exposing (Element, column, fill, link, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Search exposing (SourceResultBody, SourceResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.Search.Msg as SearchMsg exposing (SearchMsg)
import Page.Search.Views.Results exposing (resultIsSelected, resultTemplate, viewSearchResultSummaryField)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (makeFlagIcon)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (calendarSvg, digitizedImagesSvg, layerGroupSvg, musicNotationSvg, peopleSvg, sourcesSvg, userCircleSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewSourceSearchResult : Language -> Maybe String -> SourceResultBody -> Element SearchMsg
viewSourceSearchResult language selectedResult body =
    let
        resultColours =
            resultIsSelected selectedResult body.id

        resultBody =
            [ viewMaybe (viewSourceSummary language resultColours.iconColour) body.summary
            , viewMaybe (viewSourcePartOf language resultColours.fontLinkColour) body.partOf
            , viewMaybe (viewSourceFlags language) body.flags
            ]
    in
    resultTemplate
        { id = body.id
        , language = language
        , resultTitle = body.label
        , colours = resultColours
        , resultBody = resultBody
        , clickMsg = SearchMsg.UserClickedSearchResultForPreview
        }


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
                    { url = .id partOfBody.source
                    , label = text (extractLabelFromLanguageMap language <| .label partOfBody.source)
                    }
                ]
            ]
        ]


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


viewSourceFlags : Language -> SourceResultFlags -> Element msg
viewSourceFlags language flags =
    let
        -- TODO: Translate the labels!
        incipitFlag =
            viewIf
                (makeFlagIcon
                    { foreground = colourScheme.white
                    , background = colourScheme.red
                    }
                    (musicNotationSvg colourScheme.white)
                    "Has incipits"
                )
                flags.hasIncipits

        hasDigitizationFlag =
            viewIf
                (makeFlagIcon
                    { foreground = colourScheme.white
                    , background = colourScheme.turquoise
                    }
                    (digitizedImagesSvg colourScheme.white)
                    "Has digitization"
                )
                flags.hasDigitization
    in
    row
        [ width fill
        , spacing 10
        ]
        [ incipitFlag
        , hasDigitizationFlag
        ]
