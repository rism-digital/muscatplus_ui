module Page.UI.Search.Results.SourceResult exposing (viewSourceSearchResult)

import Dict exposing (Dict)
import Element exposing (Color, Element, alignRight, column, el, fill, link, maximum, onLeft, px, row, spacing, spacingXY, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Search exposing (SourceResultBody, SourceResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.RecordTypes.SourceShared exposing (SourceContentTypeRecordBody)
import Page.UI.Attributes exposing (bodyRegular, bodySM)
import Page.UI.CantusLogo exposing (cantusLogo)
import Page.UI.Components exposing (contentTypeIconChooser, makeFlagIcon, sourceIconChooser, sourceTypeIconChooser)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (calendarSvg, digitizedImagesSvg, iiifLogo, layerGroupSvg, linkSvg, musicNotationSvg, peopleSvg, sourcesSvg, userCircleSvg)
import Page.UI.Search.Results exposing (SearchResultConfig, resultTemplate, setResultColours, viewSearchResultSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)


viewSourceFlags : Language -> SourceResultFlags -> Element msg
viewSourceFlags language flags =
    let
        -- TODO: Translate the labels!
        hasDigitizationFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.puce
                    }
                    (digitizedImagesSvg colourScheme.white)
                    (extractLabelFromLanguageMap language localTranslations.hasDigitization)
                )
                flags.hasDigitization

        iiifFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.lightGrey
                    }
                    iiifLogo
                    (extractLabelFromLanguageMap language localTranslations.hasIIIFManifest)
                )
                flags.hasIIIFManifest

        incipitFlag =
            viewIf
                (makeFlagIcon
                    { background = colourScheme.red
                    }
                    (musicNotationSvg colourScheme.white)
                    (extractLabelFromLanguageMap language localTranslations.hasIncipits)
                )
                flags.hasIncipits

        isDIAMMFlag =
            viewIf
                (el
                    [ width (px 90)
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
                    [ width (px 100)
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

        recordTypeFlag =
            let
                iconLabel =
                    extractLabelFromLanguageMap language (.label flags.recordType)

                iconType =
                    extractLabelFromLanguageMap language localTranslations.recordType
            in
            makeFlagIcon
                { background = colourScheme.darkBlue
                }
                (sourceIconChooser (.type_ flags.recordType) colourScheme.white)
                (iconType ++ ": " ++ iconLabel)

        sourceTypeFlag =
            let
                iconLabel =
                    extractLabelFromLanguageMap language (.label flags.sourceType)

                iconType =
                    extractLabelFromLanguageMap language localTranslations.sourceType
            in
            makeFlagIcon
                { background = colourScheme.turquoise
                }
                (sourceTypeIconChooser (.type_ flags.sourceType) colourScheme.white)
                (iconType ++ ": " ++ iconLabel)

        contentTypesFlags =
            viewIf (assembleContentTypeFlags language flags.contentTypes) (List.length flags.contentTypes > 0)
    in
    row
        [ width fill
        , spacingXY 5 0
        ]
        [ recordTypeFlag
        , sourceTypeFlag
        , contentTypesFlags
        , incipitFlag
        , hasDigitizationFlag
        , iiifFlag
        , linkedWithExternalRecordFlag
        , isDIAMMFlag
        , isCantusFlag
        ]


assembleContentTypeFlags : Language -> List SourceContentTypeRecordBody -> Element msg
assembleContentTypeFlags language sourceContentTypes =
    let
        sourceTypeIcon { label, type_ } =
            let
                icon =
                    contentTypeIconChooser type_

                iconLabel =
                    extractLabelFromLanguageMap language label

                iconType =
                    extractLabelFromLanguageMap language localTranslations.contentTypes
            in
            makeFlagIcon
                { background = colourScheme.yellow
                }
                (icon colourScheme.white)
                (iconType ++ ": " ++ iconLabel)
    in
    row
        [ spacing 0 ]
        (List.map sourceTypeIcon sourceContentTypes)


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
                    [ Font.color fontLinkColour ]
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
viewSourceSearchResult { language, selectedResult, clickForPreviewMsg, resultIdx } body =
    let
        resultColours =
            setResultColours resultIdx selectedResult body.id

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
