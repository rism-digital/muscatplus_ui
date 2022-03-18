module Page.Keyboard.Views.FormInput exposing (..)

import Element exposing (Attribute, Element, alignTop, centerX, centerY, column, el, fill, height, px, row, shrink, spacing, text, width)
import Element.Input as Input exposing (button)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Keyboard.Model exposing (Keyboard(..), QueryMode(..), clefStringMap)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (clefStrToClef, queryModeStrToQueryMode)
import Page.RecordTypes.Search exposing (NotationFacet)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (dropdownSelect)


viewFormInput : Language -> NotationFacet -> Keyboard -> Element KeyboardMsg
viewFormInput language notationFacet (Keyboard model config) =
    let
        clefObjList =
            .options (.clef notationFacet.notationOptions)
                |> List.map (\{ label, value } -> ( value, extractLabelFromLanguageMap language label ))

        clefSelect =
            el
                [ width shrink
                ]
                (dropdownSelect
                    (\clefStr -> UserClickedPianoKeyboardChangeClef <| clefStrToClef clefStr)
                    clefObjList
                    (\selected -> clefStrToClef selected)
                    (.clef model.query)
                )

        searchModeSelect =
            el [ width shrink ]
                (dropdownSelect
                    (\s -> UserChangedQueryMode <| queryModeStrToQueryMode s)
                    [ ( "intervals", "Intervals" ), ( "exact-pitches", "Exact Pitches" ) ]
                    (\selected -> queryModeStrToQueryMode selected)
                    (.queryMode model.query)
                )

        timeSigInput =
            el
                [ width fill ]
                (Input.text
                    [ width fill ]
                    { onChange = \_ -> NothingHappenedWithTheKeyboard
                    , text = "time sig"
                    , placeholder = Nothing
                    , label = Input.labelHidden "Time signature"
                    }
                )

        keySigInput =
            el
                [ width fill ]
                (Input.text
                    [ width fill ]
                    { onChange = \_ -> NothingHappenedWithTheKeyboard
                    , text = "key sig"
                    , placeholder = Nothing
                    , label = Input.labelHidden "Key signature"
                    }
                )

        paeText =
            Maybe.withDefault "" (.noteData model.query)

        paeInput =
            column
                [ width fill ]
                [ row
                    [ width fill
                    , height fill
                    ]
                    [ el
                        [ width fill ]
                        (Input.text
                            [ width fill ]
                            { onChange = UserInteractedWithPAEText
                            , text = paeText
                            , placeholder = Nothing
                            , label = Input.labelHidden "PAE Input"
                            }
                        )
                    , el
                        [ width (px 25)
                        , height fill
                        ]
                        (button [] { onPress = Just UserRequestedProbeUpdate, label = text "R" })
                    ]
                ]
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
            , spacing lineSpacing
            ]
            [ row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ clefSelect ]
                , column
                    [ width fill ]
                    [ searchModeSelect ]
                ]
            , row
                [ width fill ]
                [ keySigInput ]
            , row
                [ width fill ]
                [ timeSigInput ]
            , row
                [ width fill ]
                [ paeInput ]
            ]
        ]
