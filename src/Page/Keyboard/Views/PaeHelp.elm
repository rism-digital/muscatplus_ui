module Page.Keyboard.Views.PaeHelp exposing (viewPaeHelp)

import Element exposing (Element, centerY, column, el, fill, height, link, padding, paddingXY, paragraph, pointer, px, row, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language(..), LanguageMap, LanguageValues(..), extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Keyboard.Model exposing (KeyboardModel)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.UI.Attributes exposing (bodySM, headingLG, lineSpacing, linkColour)
import Page.UI.Helpers exposing (viewIf)
import Page.UI.Images exposing (caretCircleDownSvg, caretCircleRightSvg)
import Page.UI.Markdown as Markdown
import Page.UI.Style exposing (colourScheme)


viewPaeHelp : Language -> KeyboardModel KeyboardMsg -> Element KeyboardMsg
viewPaeHelp language model =
    let
        paeHelpLabel =
            if model.paeHelpExpanded then
                localTranslations.incipitSearchHelpHide

            else
                localTranslations.incipitSearchHelpShow

        toggleIcon =
            if model.paeHelpExpanded then
                caretCircleDownSvg colourScheme.lightBlue

            else
                caretCircleRightSvg colourScheme.lightBlue
    in
    row
        [ width fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , Font.color colourScheme.black
                , Border.dotted
                , paddingXY 0 8
                , spacing 5
                , Font.medium
                , headingLG
                ]
                [ el
                    [ width (px 16)
                    , height (px 16)
                    , centerY
                    , pointer
                    , onClick UserToggledPAEHelpText
                    ]
                    toggleIcon
                , el
                    [ centerY
                    , pointer
                    , onClick UserToggledPAEHelpText
                    ]
                    (text (extractLabelFromLanguageMap language paeHelpLabel))
                ]

            --                  row
            --[ width fill ]
            --[ el
            --    [ bodySM
            --    , linkColour
            --    , pointer
            --    , onClick UserToggledPAEHelpText
            --    ]
            --    (text (extractLabelFromLanguageMap language paeHelpLabel))
            --]
            , viewIf (viewHelpText language) model.paeHelpExpanded
            ]
        ]


viewHelpText : Language -> Element msg
viewHelpText language =
    row
        [ width fill ]
        [ column
            [ width fill
            , padding 10
            , Background.color colourScheme.white
            , Font.size 16
            ]
            [ Markdown.view language paeHelpText ]
        ]


paeHelpText : LanguageMap
paeHelpText =
    [ LanguageValues English [ paeHelpTextEnglish ] ]


paeHelpTextEnglish : String
paeHelpTextEnglish =
    """Search queries can be entered using the [Plaine and Easie Code.](https://www.iaml.info/plaine-easie-code)
The most basic query uses upper-case letters, A-G, to represent pitches; for example, `EDCDEEE`.
You can vary the note properties by using different characters immediately preceding it. The `'`
(single quote) character will specify a note in the C4 octave, while the `,` (comma) will shift the note to the
C3 octave. Successive octave shifts up and down are accomplished by adding additional characters; `''` is a note
in the C5 octave, and `,,` is a note in the C2 octave. The `x`, `b`, and `n` characters immediately preceding
the pitch name indicate sharps, flats, and naturals, respectively. For example, to query for the
B-A-C-H figure, you might specify `'bB'A''C'nB`. The preview will show you what your query will look like as you enter the notes.

The piano keyboard will print the corresponding Plaine and Easie code in the input box as you press
the keys, so you can use this input method to enter a search query. Search queries must be longer than three
pitches.

Accidentals are automatically applied to subsequent notes until they are explicitly
cancelled, or a bar line is provided, following common practice in notation. You can supply
a bar line by inserting a `/` character. Adding a bar line will not otherwise affect your search
results.

Durations, measures, and figures beyond pitch and interval
are shown in the preview, but are not used in the search. Support for these features is planned for later
versions.

The Clef, Time signature, and Key signature options control how the search query preview
is rendered. In the case of the Key signature field, it will also determine the steps between
the notes, since it "pre-sets" the pitches that should be raised or lowered from their naturals.
However, they will not serve as filters to your search query; that is, indicating an "F-4" clef will only
control how the incipit query is displayed, and will not limit your searches to incipits encoded with that
clef. If you wish to limit your searches to specific clefs, key signatures, and time signatures, use the
controls below.

The Query mode option controls how your query in interpreted. If "Intervals" is chosen (the default),
then the query will be interpreted as a sequence of chromatic intervals, and your query will match in any
transposition. If you wish to match the pitches exactly, choose the "Exact pitches" option. This will match
the query in the exact transposition you entered."""
