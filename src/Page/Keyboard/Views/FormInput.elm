module Page.Keyboard.Views.FormInput exposing (..)

import Element exposing (Attribute, Element, alignTop, column, el, fill, height, px, row, text, width)
import Element.Input as Input
import Language exposing (Language)
import Page.Keyboard.Model exposing (Keyboard(..), clefStringMap)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (clefStrToClef)
import Page.UI.Components exposing (dropdownSelect)


viewFormInput : Language -> Keyboard -> Element KeyboardMsg
viewFormInput language (Keyboard model config) =
    let
        clefSelect =
            el
                [ width (px 100) ]
                (dropdownSelect
                    (\clefStr -> UserClickedPianoKeyboardChangeClef <| clefStrToClef clefStr)
                    (List.map (\( s, _ ) -> ( s, s )) clefStringMap)
                    (\selected -> clefStrToClef selected)
                    (.clef model.query)
                )

        paeText =
            Maybe.withDefault [] (.noteData model.query)
                |> String.join ""

        paeInput =
            el
                [ width fill ]
                (Input.text
                    [ width fill ]
                    { onChange = UserEnteredPAEText
                    , text = paeText
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "PAE Input")
                    }
                )
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill ]
                [ clefSelect ]
            , row
                [ width fill ]
                [ text "Key signature" ]
            , row
                [ width fill ]
                [ text "Time signature" ]
            , row
                [ width fill ]
                [ paeInput ]
            , row
                [ width fill ]
                [ text "Search mode select" ]
            ]
        ]
