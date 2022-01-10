module Page.UI.Incipits exposing (..)

import Element exposing (Element, column, fill, htmlAttribute, maximum, minimum, row, text, width)
import Html.Attributes as HTA
import Language exposing (Language)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Incipit exposing (IncipitBody, IncipitFormat(..), RenderedIncipit(..))
import Page.RecordTypes.Source exposing (IncipitsSectionBody)
import Page.UI.Attributes exposing (sectionBorderStyles, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import SvgParser


viewIncipitsSection : Language -> IncipitsSectionBody -> Element msg
viewIncipitsSection language incipSection =
    sectionTemplate language incipSection (List.map (\incipit -> viewIncipit language incipit) incipSection.items)


viewIncipit : Language -> IncipitBody -> Element msg
viewIncipit language incipit =
    row
        (List.append widthFillHeightFill sectionBorderStyles)
        [ column
            widthFillHeightFill
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
    row
        [ width (fill |> minimum 400 |> maximum 1000)
        , htmlAttribute (HTA.class "search-results-rendered-incipit")
        ]
        (List.map
            (\rendered ->
                case rendered of
                    RenderedIncipit RenderedSVG svgdata ->
                        viewSVGRenderedIncipit svgdata

                    _ ->
                        Element.none
            )
            incipits
        )


{-|

    Parses an Elm SVG tree (returns Html) from the JSON incipit data.
    Converts it to an elm-ui structure to match the other view functions

-}
viewSVGRenderedIncipit : String -> Element msg
viewSVGRenderedIncipit incipitData =
    case SvgParser.parse incipitData of
        Ok html ->
            Element.html html

        Err _ ->
            text "Could not parse SVG"