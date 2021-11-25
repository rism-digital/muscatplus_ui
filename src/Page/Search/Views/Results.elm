module Page.Search.Views.Results exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, link, none, paddingEach, paddingXY, pointer, row, spacing, text, width)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Page.RecordTypes.Search exposing (IncipitResultFlags, InstitutionResultFlags, PersonResultFlags, SearchResult, SearchResultFlags(..), SourceResultFlags)
import Page.Search.Msg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (h3, makeFlagIcon)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (digitizedImagesSvg, musicNotationSvg, penSvg, sourcesSvg)
import Page.UI.Incipits exposing (viewRenderedIncipits)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


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

        resultTitle =
            el
                [ Font.color (fontLinkColor |> convertColorToElementColor)
                , width fill
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
                        [ width fill
                        , bodyRegular
                        ]
                        [ column
                            [ width fill
                            ]
                            (List.map (\l -> el [] (text (extractLabelFromLanguageMap language l.value))) fields)
                        ]

                Nothing ->
                    none
    in
    row
        [ width fill
        , alignTop
        , paddingXY 20 20
        , Background.color (backgroundColour |> convertColorToElementColor)
        , Font.color (textColor |> convertColorToElementColor)
        , onClick (UserClickedSearchResultForPreview result.id)
        , pointer
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 10
            ]
            [ row
                [ width fill
                , alignLeft
                , spacing 10
                ]
                [ resultTitle
                ]
            , row
                [ width fill
                , alignLeft
                ]
                [ link
                    [ Font.color (fontLinkColor |> convertColorToElementColor) ]
                    { url = result.id, label = text result.id }
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
                    (formatNumberByLanguage (toFloat flags.numberOfExemplars) language ++ " Exemplars")

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
                            formatNumberByLanguage (toFloat flags.numberOfSources) language ++ " Sources"
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
                            formatNumberByLanguage (toFloat flags.numberOfSources) language ++ " Sources"
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
