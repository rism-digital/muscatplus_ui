module Page.Views.SearchPage.Results exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, link, none, paddingEach, paddingXY, pointer, row, spacing, text, width)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg(..))
import Page.RecordTypes.Search exposing (InstitutionResultFlags, PersonResultFlags, SearchResult, SearchResultFlags(..), SourceResultFlags)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (h5, makeFlagIcon)
import Page.UI.Images exposing (digitizedImagesSvg, musicNotationSvg, penSvg, sourcesSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.Helpers exposing (viewMaybe)
import String.Extra as SE


viewSearchResult : Language -> Maybe String -> SearchResult -> Element Msg
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
                (h5 language result.label)

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

        --, height (px 100)
        , alignTop

        --, Border.widthEach { left = 2, right = 0, bottom = 0, top = 0 }
        --, Border.color colourScheme.midGrey
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
                    viewPersonFlags personFlags

                InstitutionFlags institutionFlags ->
                    viewInstitutionFlags institutionFlags
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
            if flags.numberOfExemplars > 0 then
                let
                    labelText =
                        SE.pluralize "Exemplar" "Exemplars" flags.numberOfExemplars
                in
                makeFlagIcon
                    { foreground = colourScheme.white
                    , background = colourScheme.darkOrange
                    }
                    (penSvg colourScheme.white)
                    labelText

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


viewPersonFlags : PersonResultFlags -> Element msg
viewPersonFlags flags =
    let
        numSources =
            if flags.numberOfSources > 0 then
                let
                    labelText =
                        SE.pluralize "Source" "Sources" flags.numberOfSources
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


viewInstitutionFlags : InstitutionResultFlags -> Element msg
viewInstitutionFlags flags =
    let
        numSources =
            if flags.numberOfSources > 0 then
                let
                    labelText =
                        SE.pluralize "Source" "Sources" flags.numberOfSources
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
