module Page.Keyboard.Views.FormInput exposing (viewPaeInput, viewRenderControls)

import Element exposing (Element, alignTop, column, el, fill, height, px, row, shrink, spacing, text, width)
import Element.Font as Font
import Element.Input as Input
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Keyboard.Model exposing (KeyboardModel)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (clefStrToClef, keySigStrToKeySignature, timeSigStrToTimeSignature)
import Page.RecordTypes.Search exposing (NotationFacet)
import Page.UI.Attributes exposing (bodySM, headingMD, lineSpacing)
import Page.UI.Components exposing (dropdownSelect)


viewPaeInput : Language -> KeyboardModel KeyboardMsg -> Element KeyboardMsg
viewPaeInput language model =
    row
        [ width fill ]
        [ column
            [ width fill ]
            [ row
                [ width fill
                , height fill
                ]
                [ Input.text
                    [ width fill ]
                    { label =
                        Input.labelAbove
                            [ Font.semiBold
                            , headingMD
                            ]
                            (row
                                [ spacing lineSpacing ]
                                [ column
                                    []
                                    [ text (extractLabelFromLanguageMap language localTranslations.paeInput) ]
                                , column
                                    []
                                    [ el
                                        [ bodySM
                                        , Font.regular
                                        ]
                                        (text (extractLabelFromLanguageMap language localTranslations.notationQueryLength))
                                    ]
                                ]
                            )
                    , onChange = UserInteractedWithPAEText
                    , placeholder = Nothing
                    , text = Maybe.withDefault "" (.noteData model.query)
                    }
                ]
            ]
        ]


viewRenderControls : Language -> NotationFacet -> KeyboardModel KeyboardMsg -> Element KeyboardMsg
viewRenderControls language notationFacet model =
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
                    { selectedMsg = \clefStr -> UserClickedPianoKeyboardChangeClef (clefStrToClef clefStr)
                    , mouseDownMsg = Nothing
                    , mouseUpMsg = Nothing
                    , choices = clefObjList
                    , choiceFn = \selected -> clefStrToClef selected
                    , currentChoice = .clef model.query
                    , selectIdent = "keyboard-clef-select"
                    , label = Just clefLabel
                    , language = language
                    , inverted = False
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
                    { selectedMsg = \ksigStr -> UserClickedPianoKeyboardChangeKeySignature (keySigStrToKeySignature ksigStr)
                    , mouseDownMsg = Nothing
                    , mouseUpMsg = Nothing
                    , choices = keySigList
                    , choiceFn = \selected -> keySigStrToKeySignature selected
                    , currentChoice = .keySignature model.query
                    , selectIdent = "keyboard-key-sig-select"
                    , label = Just keySigLabel
                    , language = language
                    , inverted = False
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
                    { selectedMsg = \tsigStr -> UserClickedPianoKeyboardChangeTimeSignature (timeSigStrToTimeSignature tsigStr)
                    , mouseDownMsg = Nothing
                    , mouseUpMsg = Nothing
                    , choices = tsigList
                    , choiceFn = \selected -> timeSigStrToTimeSignature selected
                    , currentChoice = .timeSignature model.query
                    , selectIdent = "keyboard-time-sig-select"
                    , label = Just tsigLabel
                    , language = language
                    , inverted = False
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
