module Page.Search.Views.Results exposing (..)

import Dict exposing (Dict)
import Element exposing (Element, above, alignLeft, alignTop, centerY, column, el, fill, height, link, none, onLeft, padding, paddingEach, paddingXY, pointer, px, rgb, rgba, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, LanguageMap, LanguageMapReplacementVariable(..), extractLabelFromLanguageMap, extractTextFromLanguageMap, formatNumberByLanguage)
import Page.RecordTypes.Search exposing (IncipitResultFlags, InstitutionResultFlags, PersonResultFlags, SearchResult, SearchResultFlags(..), SourceResultFlags)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (h3, makeFlagIcon)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (calendarSvg, digitizedImagesSvg, layerGroupSvg, musicNotationSvg, penSvg, peopleSvg, scrollOldSvg, sourcesSvg)
import Page.UI.Incipits exposing (viewRenderedIncipits)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (tooltip)
import Utlities exposing (flip)


type alias SearchResultSummaryConfig msg =
    { language : Language
    , icon : Element msg
    , includeLabelInValue : Bool
    , fieldName : String
    }


summaryFieldTemplate : SearchResultSummaryConfig msg -> LabelValue -> Element msg
summaryFieldTemplate summaryCfg fieldValue =
    let
        fLabel =
            extractLabelFromLanguageMap summaryCfg.language fieldValue.label

        fVal =
            extractTextFromLanguageMap summaryCfg.language fieldValue.value

        iconElement =
            el
                [ width <| px 20
                , height <| px 20
                , centerY
                , tooltip above <|
                    el
                        [ Background.color (rgb 0 0 0)
                        , Font.color (rgb 1 1 1)
                        , width shrink
                        , padding 12
                        , Border.rounded 5
                        , Font.size 14
                        , Border.shadow
                            { offset = ( 0, 3 ), blur = 6, size = 0, color = rgba 0 0 0 0.32 }
                        ]
                        (text fLabel)
                ]
                summaryCfg.icon

        fValueLength =
            List.length fVal

        fValueAsString =
            if fValueLength > 3 then
                List.take 3 fVal
                    |> String.join "; "
                    |> flip String.append " … "

            else
                String.join "; " fVal

        templatedVal =
            if summaryCfg.includeLabelInValue == True then
                fValueAsString ++ " " ++ fLabel

            else
                fValueAsString

        allEntries =
            if fValueLength > 3 then
                column
                    [ Background.color (rgb 0 0 0)
                    , Font.color (rgb 1 1 1)
                    , width shrink
                    , padding 12
                    , Border.rounded 5
                    , Font.size 14
                    , Border.shadow
                        { offset = ( 0, 3 ), blur = 6, size = 0, color = rgba 0 0 0 0.32 }
                    , spacing 5
                    ]
                    (List.map (\t -> el [] (text t)) fVal)

            else
                none

        expandedList =
            if fValueLength > 3 then
                -- TODO: Translate!
                el
                    [ tooltip onLeft allEntries
                    , padding 4
                    , Background.color (colourScheme.lightGrey |> convertColorToElementColor)
                    , Font.color (colourScheme.black |> convertColorToElementColor)
                    , centerY
                    ]
                    (text "See all")

            else
                none
    in
    el
        [ spacing 5
        , alignTop
        ]
        (row
            [ spacing 5 ]
            [ iconElement
            , el
                [ centerY ]
                (text templatedVal)
            , expandedList
            ]
        )


viewSearchResultSummaryField : SearchResultSummaryConfig msg -> Dict String LabelValue -> Element msg
viewSearchResultSummaryField summaryCfg summaryField =
    Dict.get summaryCfg.fieldName summaryField
        |> viewMaybe (summaryFieldTemplate summaryCfg)


viewSearchResult : Language -> Maybe String -> SearchResult -> Element SearchMsg
viewSearchResult language selectedResult result =
    let
        isSelected =
            case selectedResult of
                Just url ->
                    result.id == url

                Nothing ->
                    False

        backgroundColour =
            if isSelected == True then
                colourScheme.lightBlue

            else
                colourScheme.white

        fontLinkColor =
            if isSelected == True then
                colourScheme.white

            else
                colourScheme.lightBlue

        textColor =
            if isSelected == True then
                colourScheme.white

            else
                colourScheme.black

        iconColour =
            if isSelected == True then
                colourScheme.white

            else
                colourScheme.slateGrey

        resultTitle =
            el
                [ Font.color (fontLinkColor |> convertColorToElementColor)
                , width fill
                , alignTop
                ]
                (h3 language result.label)

        resultFlags : Element msg
        resultFlags =
            viewMaybe (viewResultFlags language) result.flags

        partOf =
            case result.partOf of
                Just partOfBody ->
                    let
                        source =
                            partOfBody.source
                    in
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
                                    [ Font.color (fontLinkColor |> convertColorToElementColor) ]
                                    { url = source.id
                                    , label = text (extractLabelFromLanguageMap language source.label)
                                    }
                                ]
                            ]
                        ]

                Nothing ->
                    none

        summary =
            case result.summary of
                Just fields ->
                    row
                        [ width fill ]
                        [ column
                            [ spacing 5 ]
                            [ row
                                [ width fill ]
                                [ viewSearchResultSummaryField
                                    { language = language
                                    , icon = peopleSvg iconColour
                                    , includeLabelInValue = False
                                    , fieldName = "sourceComposers"
                                    }
                                    fields
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
                                    }
                                    fields
                                , viewSearchResultSummaryField
                                    { language = language
                                    , icon = layerGroupSvg iconColour
                                    , includeLabelInValue = True
                                    , fieldName = "numItems"
                                    }
                                    fields
                                , viewSearchResultSummaryField
                                    { language = language
                                    , icon = sourcesSvg iconColour
                                    , includeLabelInValue = True
                                    , fieldName = "numExemplars"
                                    }
                                    fields
                                ]
                            ]
                        ]

                Nothing ->
                    none

        --case result.summary of
        --    Just fields ->
        --        row
        --            [ width fill
        --            , bodyRegular
        --            ]
        --            [ column
        --                [ width fill
        --                ]
        --                (List.map (\l -> el [] (text (extractLabelFromLanguageMap language l.value))) fields)
        --            ]
        --
        --    Nothing ->
        --        none
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        , Background.color (backgroundColour |> convertColorToElementColor)
        , Font.color (textColor |> convertColorToElementColor)
        , onClick (UserClickedSearchResultForPreview result.id)
        , Border.color (colourScheme.midGrey |> convertColorToElementColor)
        , Border.widthEach { top = 0, bottom = 1, left = 0, right = 0 }
        , Border.dotted
        , pointer
        , paddingXY 20 20

        --, paddingXY 10 5
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 10

            --, Border.widthEach { left = 2, right = 0, bottom = 0, top = 0 }
            --, Border.color (colourScheme.midGrey |> convertColorToElementColor)
            --, paddingXY lineSpacing 0
            ]
            [ row
                [ width fill
                , alignLeft
                , alignTop
                ]
                [ resultTitle
                ]
            , summary
            , partOf
            , resultFlags
            ]
        ]


viewResultFlags : Language -> SearchResultFlags -> Element msg
viewResultFlags language flags =
    let
        flagRow =
            case flags of
                SourceFlags sourceFlags ->
                    viewSourceFlags language sourceFlags

                PersonFlags personFlags ->
                    viewPersonFlags language personFlags

                InstitutionFlags institutionFlags ->
                    viewInstitutionFlags language institutionFlags

                IncipitFlags incipitFlags ->
                    viewIncipitFlags language incipitFlags
    in
    row
        [ width fill
        , alignLeft
        , spacing 8
        , paddingEach { top = 8, bottom = 0, left = 0, right = 0 }
        ]
        [ column
            [ width fill ]
            [ flagRow ]
        ]


viewSourceFlags : Language -> SourceResultFlags -> Element msg
viewSourceFlags language flags =
    let
        -- TODO: Translate the labels!
        incipitFlag =
            if flags.hasIncipits == True then
                makeFlagIcon
                    { foreground = colourScheme.white
                    , background = colourScheme.red
                    }
                    (musicNotationSvg colourScheme.white)
                    "Has incipits"

            else
                none

        hasDigitizationFlag =
            if flags.hasDigitization == True then
                makeFlagIcon
                    { foreground = colourScheme.white
                    , background = colourScheme.turquoise
                    }
                    (digitizedImagesSvg colourScheme.white)
                    "Has digitization"

            else
                none

        numExemplars =
            if flags.numberOfExemplars > 1 then
                makeFlagIcon
                    { foreground = colourScheme.white
                    , background = colourScheme.darkOrange
                    }
                    (penSvg colourScheme.white)
                    (formatNumberByLanguage language (toFloat flags.numberOfExemplars) ++ " Exemplars")

            else
                none
    in
    row
        [ width fill
        , spacing 10
        ]
        [ incipitFlag
        , hasDigitizationFlag
        , numExemplars
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


viewIncipitFlags : Language -> IncipitResultFlags -> Element msg
viewIncipitFlags language flags =
    let
        incipits =
            case flags.highlightedResult of
                Just renderedIncipits ->
                    viewRenderedIncipits renderedIncipits

                Nothing ->
                    none
    in
    row
        [ width fill
        , spacing 10
        ]
        [ incipits ]
