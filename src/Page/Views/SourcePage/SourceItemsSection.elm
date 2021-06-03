module Page.Views.SourcePage.SourceItemsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, link, none, paddingXY, row, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.Source exposing (BasicSourceBody, FullSourceBody, SourceItemsSectionBody)
import Page.UI.Attributes exposing (headingXS)
import Page.UI.Components exposing (h5, viewSummaryField)
import Page.UI.Style exposing (colourScheme)


viewSourceItemsRouter : FullSourceBody -> Language -> Element msg
viewSourceItemsRouter body language =
    case body.items of
        Just sourceItemsSection ->
            viewSourceItemsSection sourceItemsSection language

        Nothing ->
            none


viewSourceItemsSection : SourceItemsSectionBody -> Language -> Element msg
viewSourceItemsSection siSection language =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            , alignTop
            ]
            [ row
                [ width fill ]
                [ h5 language siSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                (List.map (\l -> viewSourceItem l language) siSection.items)
            ]
        ]


viewSourceItem : BasicSourceBody -> Language -> Element msg
viewSourceItem source language =
    let
        summary =
            case source.summary of
                Just sum ->
                    viewSummaryField sum language

                Nothing ->
                    none
    in
    row
        [ width fill
        , Border.widthEach { left = 2, right = 0, bottom = 0, top = 0 }
        , Border.color colourScheme.midGrey
        , paddingXY 10 0
        ]
        [ column
            [ width fill
            , height fill
            , spacing 10
            ]
            [ row
                [ width fill ]
                [ link
                    [ Font.color colourScheme.lightBlue
                    , headingXS
                    , Font.semiBold
                    ]
                    { url = source.id, label = text (extractLabelFromLanguageMap language source.label) }
                ]
            , summary
            ]
        ]
