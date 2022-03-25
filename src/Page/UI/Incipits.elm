module Page.UI.Incipits exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, maximum, minimum, paddingXY, row, text, width)
import Element.Background as Background
import Html.Attributes as HTA
import Language exposing (Language)
import List.Extra as LE
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Incipit exposing (IncipitBody, IncipitFormat(..), RenderedIncipit(..))
import Page.RecordTypes.Source exposing (IncipitsSectionBody)
import Page.UI.Attributes exposing (sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import SvgParser


splitWorkNumFromId : String -> String
splitWorkNumFromId incipitId =
    String.split "/" incipitId
        |> LE.last
        |> Maybe.withDefault "1.1.1"


viewIncipitsSection : Language -> IncipitsSectionBody -> Element msg
viewIncipitsSection language incipSection =
    sectionTemplate language incipSection (List.map (\incipit -> viewIncipit language incipit) incipSection.items)


viewIncipit : Language -> IncipitBody -> Element msg
viewIncipit language incipit =
    row
        ([ width fill
         , height fill
         , alignTop
         ]
            ++ sectionBorderStyles
        )
        [ column
            [ width fill
            , height fill
            , alignTop
            , HTA.id ("incipit-" ++ splitWorkNumFromId incipit.id) |> htmlAttribute
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
    row
        [ width (fill |> minimum 500 |> maximum 1000)
        , paddingXY 10 0
        , htmlAttribute (HTA.class "search-results-rendered-incipit")
        , Background.color (colourScheme.white |> convertColorToElementColor)
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

    Parses an Elm SVG tree (returns SVG data in Html) from the JSON incipit data.
    Converts it to an elm-ui structure to match the other view functions

-}
viewSVGRenderedIncipit : String -> Element msg
viewSVGRenderedIncipit incipitData =
    case SvgParser.parse incipitData of
        Ok svgData ->
            Element.html svgData

        Err _ ->
            text "Could not parse SVG"
