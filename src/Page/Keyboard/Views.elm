module Page.Keyboard.Views exposing (..)

import Element exposing (Attribute, Element, alignLeft, alignTop, column, el, fill, height, paddingXY, px, row, text, width)
import Element.Input as Input
import Language exposing (Language)
import Page.Keyboard.Model exposing (Keyboard(..))
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.Views.FormInput exposing (viewFormInput)
import Page.Keyboard.Views.PianoInput exposing (viewPianoInput)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Incipits exposing (viewSVGRenderedIncipit)


view : Language -> Keyboard -> Element KeyboardMsg
view language (Keyboard model config) =
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , height fill
            , alignLeft
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ column
                    [ width fill
                    , height fill
                    ]
                    [ viewPianoInput language (Keyboard model config) ]
                , column
                    [ width fill
                    , height fill
                    , alignTop
                    , alignLeft
                    ]
                    [ viewFormInput language (Keyboard model config) ]
                ]
            , row
                [ width fill
                , height (px 120)
                , paddingXY 0 10
                ]
                [ el
                    [ width fill
                    , height (px 120)
                    ]
                    (viewMaybe viewSVGRenderedIncipit model.notation)
                ]
            ]
        ]
