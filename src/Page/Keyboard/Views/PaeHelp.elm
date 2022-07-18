module Page.Keyboard.Views.PaeHelp exposing (..)

import Element exposing (Element, column, el, fill, link, padding, paragraph, pointer, row, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language(..))
import Page.Keyboard.Model exposing (Keyboard(..))
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.UI.Attributes exposing (bodySM, lineSpacing, linkColour)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


viewPaeHelp : Language -> Keyboard KeyboardMsg -> Element KeyboardMsg
viewPaeHelp language (Keyboard model config) =
    let
        paeHelpLabel =
            if model.paeHelpExpanded then
                "Hide Incipit Search Help"

            else
                "Show Incipit Search Help"
    in
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ el
                    [ bodySM
                    , linkColour
                    , pointer
                    , onClick UserToggledPAEHelpText
                    ]
                    (text paeHelpLabel)
                ]
            , viewIf (viewHelpText language) model.paeHelpExpanded
            ]
        ]


viewHelpText : Language -> Element msg
viewHelpText language =
    let
        helpText =
            case language of
                English ->
                    englishPaeHelpText

                _ ->
                    -- TODO: Change this as more languages are translated.
                    englishPaeHelpText
    in
    row
        [ width fill ]
        [ column
            [ width fill
            , padding 10
            , Background.color (colourScheme.white |> convertColorToElementColor)
            ]
            [ textColumn [ spacing lineSpacing ] helpText ]
        ]


englishPaeHelpText : List (Element msg)
englishPaeHelpText =
    [ paragraph
        [ width fill, spacing lineSpacing ]
        [ text "Search queries can be entered using the "
        , link
            [ linkColour ]
            { url = "https://www.iaml.info/plaine-easie-code"
            , label = text "Plaine and Easie Code"
            }
        , text """ at varying levels of complexity. The most basic query
        uses upper-case letters, A-G, to represent pitches; for example, """
        , el [ spacing lineSpacing, Font.family [ Font.monospace ], padding 2, Background.color (colourScheme.lightGrey |> convertColorToElementColor) ] (text "EDCDEEE")
        , text """. Using the "x", "b", and "n" characters, you can indicate sharps, flats, and naturals, respectively.
        The incipit preview above will show you what this will look like."""
        , text """The keyboard input will print the corresponding Plaine and Easie code in the input box, so
        you can also use this interface to enter a search query."""
        , text """Search queries must be longer than three pitches."""
        ]
    , paragraph
        [ width fill, spacing lineSpacing ]
        [ text """The Clef, Time signature, and Key signature options also control how the search
         is rendered. In the case of the Key signature field, it will also determine the steps between
         the notes. However, they will not serve as filters to your search query; that is, indicating
         an "F-4" clef will only control how the incipit is displayed, it will not limit your searches
         to only incipits encoded with that clef. If you wish to limit your searches to specific clefs,
         key signatures, and time signatures, use the facet controls below.""" ]
    , paragraph
        [ width fill, spacing lineSpacing ]
        [ text """The Query mode controls how your query in interpreted. If "Intervals" is chosen (the default),
         then the query will be interpreted as a sequence of intervals, allowing your query to match any
         transposition. If you are only interested matching exactly the pitches in the query, choose the
         "Exact pitches" option. This will only match the query in the exact transposition given. """
        , text """Note durations, measures, octaves, and more extensive notational figures beyond pitch and interval
        are not used in the search. These are features that are planned for later versions."""
        ]
    ]
