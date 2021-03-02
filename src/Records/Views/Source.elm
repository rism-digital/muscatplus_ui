module Records.Views.Source exposing (..)

import Api.Records exposing (Incipit, IncipitFormat(..), IncipitList, NoteList, RenderedIncipit(..), SourceBody)
import Element exposing (Element, alignTop, column, el, fill, fillPortion, height, paddingXY, px, row, spacing, text, width)
import Language exposing (Language)
import Records.DataTypes exposing (Msg)
import Records.Views.Shared exposing (viewSummaryField)
import SvgParser
import UI.Components exposing (h2, h4, label, value)
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
                    , viewNotesSection body language
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


viewNotesSection : SourceBody -> Language -> Element Msg
viewNotesSection body language =
    case body.notes of
        Just notelist ->
            viewNotes notelist language

        Nothing ->
            Element.none


viewNotes : NoteList -> Language -> Element Msg
viewNotes notelist language =
    row
        (List.append borderBottom [ width fill, paddingXY 0 10 ])
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ column
                    []
                    [ h4 language notelist.label ]
                ]
            , viewSummaryField notelist.notes language
            ]
        ]


viewIncipitSection : SourceBody -> Language -> Element Msg
viewIncipitSection body language =
    case body.incipits of
        Just incipitList ->
            viewIncipits incipitList language

        Nothing ->
            Element.none


viewIncipits : IncipitList -> Language -> Element Msg
viewIncipits incipitlist language =
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
