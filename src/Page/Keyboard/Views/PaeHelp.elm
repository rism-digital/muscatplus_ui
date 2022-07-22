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
            , label = text "Plaine and Easie Code. "
            }
        , text """The most basic query
        uses upper-case letters, A-G, to represent pitches; for example, """
        , el [ spacing lineSpacing, Font.family [ Font.monospace ], padding 2, Background.color (colourScheme.lightGrey |> convertColorToElementColor) ] (text "EDCDEEE")
        , text """. You can vary the note properties by using different characters immediately preceding it. The "'"
        (single quote) character will specify a note in the C4 octave, while the "," (comma) will shift the note to the
        C3 octave. Successive octave shifts up and down are accomplished by adding additional characters; "''" is a note
          in the C5 octave, and ",," is a note in the C2 octave. The "x", "b", and "n" characters immediately preceding
          the pitch name indicates sharps, flats, and naturals, respectively. For example, to query for the
          B-A-C-H figure, you might specify: """
        , el [ spacing lineSpacing, Font.family [ Font.monospace ], padding 2, Background.color (colourScheme.lightGrey |> convertColorToElementColor) ] (text "'bB'A''C'nB")
        , text """The preview will show you what your query will look like as you enter the notes. """
        , text """The piano keyboard will print the corresponding Plaine and Easie code in the input box as you press
        the keys, so you can use this input method to enter a search query. Search queries must be longer than three
        pitches."""
        , text """Durations, measures, and figures beyond pitch and interval
        are shown in the preview, but are not used in the search. Support for these features is planned for later versions. """
        ]
    , paragraph
        [ width fill, spacing lineSpacing ]
        [ text """The Clef, Time signature, and Key signature options control how the search query preview
         is rendered. In the case of the Key signature field, it will also determine the steps between
         the notes, since it "pre-sets" the pitches that should be raised or lowered from their naturals.
         However, they will not serve as filters to your search query; that is, indicating an "F-4" clef will only
         control how the incipit query is displayed, and will not limit your searches to incipits encoded with that
         clef. If you wish to limit your searches to specific clefs, key signatures, and time signatures, use the
         controls below.""" ]
    , paragraph
        [ width fill, spacing lineSpacing ]
        [ text """The Query mode option how your query in interpreted. If "Intervals" is chosen (the default),
         then the query will be interpreted as a sequence of chromatic intervals, and your query will match in any
         transposition. If you wish to match the pitches exactly, choose the "Exact pitches" option. This will match 
         the query in the exact transposition given. """
        ]
    ]
