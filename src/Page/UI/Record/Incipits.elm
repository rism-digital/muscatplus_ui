module Page.UI.Record.Incipits exposing (splitWorkNumFromId, viewIncipit, viewIncipitsSection, viewLaunchNewIncipitSearch, viewPAESearchLink, viewRenderedIncipits, viewSVGRenderedIncipit)

import Element exposing (Element, above, alignLeft, alignTop, centerY, column, el, fill, height, htmlAttribute, link, maximum, minimum, none, padding, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language)
import List.Extra as LE
import Page.RecordTypes.Incipit exposing (EncodedIncipit(..), EncodingFormat(..), IncipitBody, IncipitFormat(..), RenderedIncipit(..))
import Page.RecordTypes.Source exposing (IncipitsSectionBody)
import Page.UI.Attributes exposing (linkColour, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (searchSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)
import Request exposing (serverUrl)
import SvgParser
import Url.Builder


splitWorkNumFromId : String -> String
splitWorkNumFromId incipitId =
    String.split "/" incipitId
        |> LE.last
        |> Maybe.withDefault "1.1.1"


viewIncipit : Language -> IncipitBody -> Element msg
viewIncipit language incipit =
    row
        (width fill
            :: height fill
            :: alignTop
            :: sectionBorderStyles
        )
        [ column
            [ width fill
            , height fill
            , alignTop
            , HTA.id ("incipit-" ++ splitWorkNumFromId incipit.id) |> htmlAttribute
            ]
            [ viewMaybe (viewSummaryField language) incipit.summary
            , row
                [ width fill ]
                [ column
                    [ width fill
                    , spacing 0
                    ]
                    [ viewMaybe viewRenderedIncipits incipit.rendered
                    , viewMaybe (viewLaunchNewIncipitSearch language) incipit.encodings
                    ]
                ]
            ]
        ]


viewIncipitsSection : Language -> IncipitsSectionBody -> Element msg
viewIncipitsSection language incipSection =
    List.map (\incipit -> viewIncipit language incipit) incipSection.items
        |> sectionTemplate language incipSection


viewLaunchNewIncipitSearch : Language -> List EncodedIncipit -> Element msg
viewLaunchNewIncipitSearch language incipits =
    row
        [ width fill
        , paddingXY 10 0
        ]
        (List.map
            (\encoded ->
                case encoded of
                    EncodedIncipit label PAEEncoding data ->
                        viewPAESearchLink language encoded

                    _ ->
                        none
            )
            incipits
        )


viewPAESearchLink : Language -> EncodedIncipit -> Element msg
viewPAESearchLink language (EncodedIncipit label encodingType data) =
    let
        clefQueryParam =
            case data.clef of
                Just cl ->
                    [ Url.Builder.string "ic" cl ]

                Nothing ->
                    []

        keySigQueryParam =
            case data.keysig of
                Just ks ->
                    [ Url.Builder.string "ik" ks ]

                Nothing ->
                    []

        modeQueryParam =
            Url.Builder.string "mode" "incipits"

        noteQueryParam =
            Url.Builder.string "n" data.data

        searchUrl =
            serverUrl
                [ "search" ]
                (noteQueryParam :: modeQueryParam :: keySigQueryParam ++ clefQueryParam ++ timeSigQueryParam)

        timeSigQueryParam =
            case data.timesig of
                Just ts ->
                    [ Url.Builder.string "it" ts ]

                Nothing ->
                    []
    in
    link
        [ centerY
        , alignLeft
        , linkColour
        , Border.width 1
        , Border.color (colourScheme.lightBlue |> convertColorToElementColor)
        , padding 2
        , Background.color (colourScheme.lightBlue |> convertColorToElementColor)
        ]
        { label =
            el
                [ width (px 12)
                , height (px 12)
                , centerY
                , el tooltipStyle (text "New search with this incipit")
                    |> tooltip above
                ]
                (searchSvg colourScheme.white)
        , url = searchUrl
        }


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
                        none
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
