module Page.Keyboard.Views.FormInput exposing (..)

import Element exposing (Element, alignTop, column, el, fill, height, px, row, shrink, spacing, text, width)
import Element.Input as Input
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Keyboard.Model exposing (Keyboard(..))
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (clefStrToClef, keySigStrToKeySignature, timeSigStrToTimeSignature)
import Page.RecordTypes.Search exposing (NotationFacet)
import Page.UI.Attributes exposing (bodySM, lineSpacing)
import Page.UI.Components exposing (dropdownSelect)


viewPaeInput : Language -> NotationFacet -> Keyboard KeyboardMsg -> Element KeyboardMsg
viewPaeInput language notationFacet (Keyboard model config) =
    row
        [ width fill ]
        [ column
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
                        , text = Maybe.withDefault "" (.noteData model.query)
                        , placeholder = Nothing
                        , label = Input.labelLeft [] (text "PAE Input")
                        }
                    )
                ]
            ]
        ]


viewRenderControls : Language -> NotationFacet -> Keyboard KeyboardMsg -> Element KeyboardMsg
viewRenderControls language notationFacet (Keyboard model config) =
    let
        clefLabel =
            .label (.clef notationFacet.notationOptions)

        clefObjList =
            .options (.clef notationFacet.notationOptions)
                |> List.map (\{ label, value } -> ( value, extractLabelFromLanguageMap language label ))

        clefSelect =
            column
                [ width shrink
                , bodySM
                ]
                [ dropdownSelect
                    { selectedMsg = \clefStr -> UserClickedPianoKeyboardChangeClef <| clefStrToClef clefStr
                    , choices = clefObjList
                    , choiceFn = \selected -> clefStrToClef selected
                    , currentChoice = .clef model.query
                    , selectIdent = "keyboard-clef-select"
                    , label = Just clefLabel
                    , language = language
                    }
                ]

        tsigLabel =
            .label (.timesig notationFacet.notationOptions)

        tsigList =
            .options (.timesig notationFacet.notationOptions)
                |> List.map (\{ label, value } -> ( value, extractLabelFromLanguageMap language label ))

        timeSigSelect =
            column
                [ width shrink
                , bodySM
                ]
                [ dropdownSelect
                    { selectedMsg = \tsigStr -> UserClickedPianoKeyboardChangeTimeSignature <| timeSigStrToTimeSignature tsigStr
                    , choices = tsigList
                    , choiceFn = \selected -> timeSigStrToTimeSignature selected
                    , currentChoice = .timeSignature model.query
                    , selectIdent = "keyboard-time-sig-select"
                    , label = Just tsigLabel
                    , language = language
                    }
                ]

        keySigLabel =
            .label (.keysig notationFacet.notationOptions)

        keySigList =
            .options (.keysig notationFacet.notationOptions)
                |> List.map (\{ label, value } -> ( value, extractLabelFromLanguageMap language label ))

        keySigSelect =
            column
                [ width shrink
                , bodySM
                ]
                [ dropdownSelect
                    { selectedMsg = \ksigStr -> UserClickedPianoKeyboardChangeKeySignature <| keySigStrToKeySignature ksigStr
                    , choices = keySigList
                    , choiceFn = \selected -> keySigStrToKeySignature selected
                    , currentChoice = .keySignature model.query
                    , selectIdent = "keyboard-key-sig-select"
                    , label = Just keySigLabel
                    , language = language
                    }
                ]
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width (px 200)
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                ]
                [ clefSelect
                ]
            , row
                [ width fill ]
                [ timeSigSelect ]
            , row
                [ width fill ]
                [ keySigSelect ]
            ]
        ]