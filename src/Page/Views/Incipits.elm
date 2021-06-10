module Page.Views.Incipits exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, paddingXY, row, spacing, text, width)
import Element.Border as Border
import Html.Attributes as HTA
import Language exposing (Language)
import Page.RecordTypes.Incipit exposing (IncipitBody, IncipitFormat(..), RenderedIncipit(..))
import Page.RecordTypes.Source exposing (IncipitsSectionBody)
import Page.UI.Components exposing (h5, viewSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.Views.Helpers exposing (viewMaybe)
import SvgParser


viewIncipitsSection : Language -> IncipitsSectionBody -> Element msg
viewIncipitsSection language incipSection =
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
                [ width fill
                , htmlAttribute (HTA.id incipSection.sectionToc)
                ]
                [ h5 language incipSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                (List.map (\l -> viewIncipit language l) incipSection.items)
            ]
        ]


viewIncipit : Language -> IncipitBody -> Element msg
viewIncipit language incipit =
    row
        [ width fill
        , height fill
        , Border.widthEach { left = 2, right = 0, top = 0, bottom = 0 }
        , Border.color colourScheme.midGrey
        , paddingXY 10 0
        , alignTop
        ]
        [ column
            [ height fill
            , width fill
            , spacing 10
            , alignTop
            ]
            [ viewMaybe (viewSummaryField language) incipit.summary
            , viewMaybe viewRenderedIncipits incipit.rendered
            ]
        ]


{-|

    An incipit can be 'rendered' in at least two ways: SVG or MIDI. This function
    takes a mixed list of binary incipit data and chooses the function for rendering
    the data.

    At present, only SVG incipits are rendered. TODO: Add MIDI rendering.

-}
viewRenderedIncipits : List RenderedIncipit -> Element msg
viewRenderedIncipits incipits =
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
                incipits
    in
    row
        [ paddingXY 0 10
        , width fill
        ]
        incipitSVG


{-|

    Parses an Elm SVG tree (returns Html) from the JSON incipit data.
    Converts it to an elm-ui structure to match the other view functions

-}
viewSVGRenderedIncipit : String -> Element msg
viewSVGRenderedIncipit incipitData =
    let
        svgData =
            SvgParser.parse incipitData

        svgResponse =
            case svgData of
                Ok html ->
                    Element.html html

                Err _ ->
                    text "Could not parse SVG"
    in
    svgResponse
