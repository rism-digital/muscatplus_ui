module Records.Views.Source exposing (..)

import Api.Records exposing (Incipit, IncipitFormat(..), IncipitList, RenderedIncipit(..), SourceBody)
import Element exposing (Element, alignTop, column, fill, fillPortion, height, paddingXY, px, row, spacing, text, width)
import Language exposing (Language)
import Records.DataTypes exposing (Msg)
import Records.Views.Shared exposing (viewSummaryField)
import SvgParser
import UI.Components exposing (h2, h4)
import UI.Style exposing (borderBottom)


viewSourceRecord : SourceBody -> Language -> Element Msg
viewSourceRecord body language =
    row
        [ alignTop ]
        [ column
            []
            [ row
                [ width fill
                , height (px 120)
                ]
                [ h2 language body.label ]
            , row
                [ width fill
                , height (fillPortion 10)
                ]
                [ column
                    [ width fill
                    , spacing 20
                    ]
                    [ viewSummarySection body language
                    , viewIncipitSection body language
                    ]
                ]
            ]
        ]


viewSummarySection : SourceBody -> Language -> Element Msg
viewSummarySection body language =
    row
        (List.append borderBottom [ width fill, paddingXY 0 10 ])
        [ column
            [ width fill ]
            [ viewSummaryField body.summary language ]
        ]


viewIncipitSection : SourceBody -> Language -> Element Msg
viewIncipitSection body language =
    let
        incipitSection =
            case body.incipits of
                Just _ ->
                    viewIncipits body language

                Nothing ->
                    Element.none
    in
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ incipitSection ]
        ]


viewIncipits : SourceBody -> Language -> Element Msg
viewIncipits source language =
    let
        incipitDisplay =
            case source.incipits of
                Just incipitList ->
                    viewIncipitList incipitList language

                Nothing ->
                    column [] [ Element.none ]
    in
    row [ width fill ]
        [ incipitDisplay ]


viewIncipitList : IncipitList -> Language -> Element Msg
viewIncipitList incipitlist language =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                []
                [ column
                    []
                    [ h4 language incipitlist.label ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    (List.map (viewSingleIncipit language) incipitlist.incipits)
                ]
            ]
        ]


viewSingleIncipit : Language -> Incipit -> Element Msg
viewSingleIncipit language incipit =
    let
        renderedIncipits =
            case incipit.rendered of
                Just renderedIncipitList ->
                    viewRenderedIncipits renderedIncipitList

                Nothing ->
                    Element.none
    in
    row (List.append borderBottom [ width fill, paddingXY 0 20 ])
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewSummaryField incipit.summary language
                    , renderedIncipits
                    ]
                ]
            ]
        ]


viewRenderedIncipits : List RenderedIncipit -> Element Msg
viewRenderedIncipits incipitlist =
    let
        incipitSVG =
            List.map
                (\rendered ->
                    case rendered of
                        RenderedIncipit RenderedSVG svgdata ->
                            viewSVGRenderedIncipit svgdata

                        _ ->
                            Element.none
                )
                incipitlist
    in
    row
        [ paddingXY 0 5 ]
        incipitSVG


viewSVGRenderedIncipit : String -> Element Msg
viewSVGRenderedIncipit incipitData =
    let
        svgData =
            SvgParser.parse incipitData

        svgResponse =
            case svgData of
                Ok html ->
                    Element.html html

                Err error ->
                    text "Could not parse SVG"
    in
    svgResponse
