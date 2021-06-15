module Page.Views.SearchPage.Results exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, el, fill, link, none, paddingEach, paddingXY, pointer, row, spacing, text, width)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg(..))
import Page.RecordTypes.Search exposing (SearchResult)
import Page.UI.Attributes exposing (bodyRegular)
import Page.UI.Components exposing (h5)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


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

        ----digitizedImagesFlag =
        ----    flags.hasDigitization
        ----
        ----isContentsFlag =
        ----    flags.isContentsRecord
        ----
        ----hasIncipits =
        ----    flags.hasIncipits
        --
        --isFullSource =
        --    result.type_ == Source && flags.isContentsRecord == False
        --
        --fullSourceIcon =
        --    if isFullSource == True then
        --        makeFlagIcon (fromRgb255 iconColour) (sourceSvg iconColour) "Source record"
        --
        --    else
        --        none
        --
        --digitalImagesIcon =
        --    if digitizedImagesFlag == True then
        --        makeFlagIcon (fromRgb255 iconColour) (digitizedImagesSvg iconColour) "Digitization available"
        --
        --    else
        --        none
        --
        --isContentsIcon =
        --    if isContentsFlag == True then
        --        makeFlagIcon (fromRgb255 iconColour) (bookOpenSvg iconColour) "Contents record"
        --
        --    else
        --        none
        --
        --incipitIcon =
        --    if hasIncipits == True then
        --        makeFlagIcon (fromRgb255 iconColour) (musicNotationSvg iconColour) "Has incipits"
        --
        --    else
        --        none
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
            ]
            [ row
                [ width fill
                , alignLeft
                , spacing 10
                ]
                [ resultTitle
                ]
            , partOf
            , summary
            , row
                [ width fill
                , alignLeft
                , spacing 8
                , paddingEach { top = 8, bottom = 0, left = 0, right = 0 }
                ]
                []

            --[ digitalImagesIcon
            --, fullSourceIcon
            --, isContentsIcon
            --, incipitIcon
            --]
            ]
        ]
