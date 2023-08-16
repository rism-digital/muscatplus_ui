module Page.Keyboard.Views.FullKeyboard exposing (fullKeyboard)

import Element exposing (Element)
import Page.Keyboard.Model exposing (KeyNoteName(..), KeyboardKeyPress(..))
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (keyNoteNameToHumanNoteString)
import Svg
import Svg.Attributes exposing (class)
import Svg.Events as SE
import VirtualDom exposing (Attribute, attribute)


keyMsg : Bool -> KeyNoteName -> Int -> KeyboardMsg
keyMsg muted note octave =
    if muted then
        UserClickedPianoKeyboardKeyOn (Muted note octave)

    else
        UserClickedPianoKeyboardKeyOn (Sounding note octave)


upKeyMsg : Bool -> KeyNoteName -> Int -> KeyboardMsg
upKeyMsg muted note octave =
    if muted then
        UserClickedPianoKeyboardKeyOff (Muted note octave)

    else
        UserClickedPianoKeyboardKeyOff (Sounding note octave)


whiteKey :
    Bool
    ->
        { keyLabel : Maybe (Svg.Svg KeyboardMsg)
        , naturalNote : KeyNoteName
        , octave : Int
        , plainNote : KeyNoteName
        , showSymbols : Bool
        }
    -> List (Svg.Svg KeyboardMsg)
whiteKey muted { keyLabel, naturalNote, octave, plainNote, showSymbols } =
    let
        naturalLabel =
            keyNoteNameToHumanNoteString naturalNote ++ String.fromInt octave

        plainLabel =
            keyNoteNameToHumanNoteString plainNote ++ String.fromInt octave

        syms =
            if showSymbols then
                Svg.node "path"
                    [ attribute "d" "M 238.421 467.261 C 238.141 467.029 237.953 466.446 237.953 465.979 L 237.953 408.308 L 240.491 408.308 L 240.491 428.696 L 252.327 424.618 L 252.703 424.618 C 253.454 424.618 254.019 425.202 254.019 426.132 L 254.019 483.806 L 251.39 483.806 L 251.39 463.418 L 239.55 467.492 C 239.456 467.492 239.269 467.61 239.174 467.61 C 238.892 467.61 238.611 467.492 238.421 467.261 Z M 251.39 434.641 L 240.491 438.369 L 240.491 457.591 L 251.39 453.745 L 251.39 434.641 Z"
                    , class "accidental-symbol"
                    , SE.onMouseDown (keyMsg muted naturalNote octave)
                    , SE.onMouseUp (upKeyMsg muted naturalNote octave)
                    ]
                    []

            else
                Svg.text ""

        keyLabelPath =
            case keyLabel of
                Just s ->
                    s

                Nothing ->
                    Svg.text ""
    in
    [ Svg.node "title"
        []
        [ Svg.text plainLabel
        ]
    , Svg.node "rect"
        [ attribute "x" "172.763"
        , attribute "y" "-4.462"
        , attribute "width" "91.739"
        , attribute "height" "403.887"
        , class "white-key"
        , SE.onMouseDown (keyMsg muted plainNote octave)
        , SE.onMouseUp (upKeyMsg muted plainNote octave)
        ]
        []
    , Svg.node "g"
        [ attribute "transform" "matrix(1.056198, 0, 0, 1, -41.310081, 0.211746)"
        , class "natural-key-parent"
        ]
        [ Svg.node "rect"
            [ attribute "x" "202.666"
            , attribute "y" "401.462"
            , attribute "width" "86.64"
            , attribute "height" "89.191"
            , class "natural-key"
            , SE.onMouseDown (keyMsg muted naturalNote octave)
            , SE.onMouseUp (upKeyMsg muted naturalNote octave)
            ]
            [ Svg.node "title"
                []
                [ Svg.text naturalLabel
                ]
            ]
        , Svg.node "line"
            [ class "white-key-divider"
            , attribute "x1" "201.246"
            , attribute "y1" "400.648"
            , attribute "x2" "290.474"
            , attribute "y2" "400.648"
            ]
            []
        , syms
        ]
    , Svg.node "path"
        [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
        , attribute "d" "M 170.799 -5.194 L 266.192 -5.194 L 266.192 484.73 C 266.192 489.148 262.61 492.73 258.192 492.73 L 178.615 492.73 C 174.196 492.73 170.741 489.175 170.741 484.757"
        ]
        [ Svg.node "title"
            []
            [ Svg.text naturalLabel
            ]
        ]
    , keyLabelPath
    ]


blackKey :
    Bool
    ->
        { flatNote : KeyNoteName
        , octave : Int
        , sharpNote : KeyNoteName
        , showSymbols : Bool
        }
    -> List (Svg.Svg KeyboardMsg)
blackKey muted { flatNote, octave, sharpNote, showSymbols } =
    let
        sharpLabel =
            keyNoteNameToHumanNoteString sharpNote ++ String.fromInt octave

        flatLabel =
            keyNoteNameToHumanNoteString flatNote ++ String.fromInt octave

        syms =
            if showSymbols then
                [ Svg.node "path"
                    [ attribute "d" "M 358.408 267.109 C 362.499 264.68 365.31 263.004 370.298 263.004 C 373.62 263.004 374.77 263.462 377.2 264.982 C 378.861 266.043 380.267 268.018 380.65 270.754 L 381.164 274.551 C 381.164 278.806 379.117 283.211 375.41 288.07 C 372.469 291.869 370.422 294.755 367.103 298.404 L 355.851 310.404 L 355.851 212.568 L 358.408 212.568 L 358.408 267.109 Z M 367.354 267.716 C 363.266 267.716 361.221 269.235 358.408 272.12 L 358.408 301.593 C 362.372 296.885 365.31 292.629 367.483 288.833 C 370.169 283.971 371.575 279.867 371.575 276.07 C 371.575 274.704 371.702 273.642 371.702 273.031 C 371.702 270.905 371.318 269.843 370.298 268.473 L 369.273 268.018 L 367.354 267.716 Z"
                    , class "black-key-accidental-symbol lower"
                    , SE.onMouseDown (keyMsg muted flatNote octave)
                    , SE.onMouseUp (upKeyMsg muted flatNote octave)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text flatLabel
                        ]
                    ]
                , Svg.node "path"
                    [ attribute "d" "M 373.325 81.629 L 373.325 56.067 L 375.507 56.067 L 375.507 80.874 L 381.164 78.757 L 381.164 92.521 L 375.507 94.638 L 375.507 119.596 L 381.164 117.783 L 381.164 131.547 L 375.507 133.514 L 375.507 156.959 L 373.325 156.959 L 373.325 134.269 L 363.559 137.598 L 363.559 161.041 L 361.378 161.041 L 361.378 138.505 L 355.851 140.471 L 355.851 126.859 L 361.378 124.739 L 361.378 99.479 L 355.851 101.594 L 355.851 87.68 L 361.378 85.716 L 361.378 60.15 L 363.559 60.15 L 363.559 84.805 L 373.325 81.629 Z M 363.559 98.722 L 363.559 123.984 L 373.325 120.655 L 373.325 95.24 L 363.559 98.722 Z"
                    , class "black-key-accidental-symbol upper"
                    , SE.onMouseDown (keyMsg muted sharpNote octave)
                    , SE.onMouseUp (upKeyMsg muted sharpNote octave)
                    ]
                    [ Svg.node "title"
                        []
                        [ Svg.text sharpLabel
                        ]
                    ]
                ]

            else
                []
    in
    Svg.node "title"
        []
        [ String.join "/" [ flatLabel, sharpLabel ] |> Svg.text ]
        :: Svg.node "path"
            [ attribute "style" "stroke-width: 0px;"
            , attribute "d" "M 337.459 34.201 L 398.199 34.201 L 398.199 334.931 C 398.199 339.498 394.84 343.201 390.698 343.201 L 344.96 343.201 C 340.818 343.201 337.459 339.498 337.459 334.931 L 337.459 34.201 Z"
            ]
            []
        :: Svg.node "path"
            [ attribute "d" "M 337.481 38.019 H 398.233 V 186.144 H 337.481 V 38.019 Z"
            , SE.onMouseDown (keyMsg muted sharpNote octave)
            , SE.onMouseUp (upKeyMsg muted sharpNote octave)
            , class "black-key upper"
            ]
            [ Svg.node "title"
                []
                [ Svg.text sharpLabel ]
            ]
        :: Svg.node "path"
            [ attribute "d" "M 337.481 188.254 L 398.221 188.254 L 398.221 339.021 C 398.221 341.311 394.862 343.167 390.72 343.167 L 344.982 343.167 C 340.84 343.167 337.481 341.311 337.481 339.021 L 337.481 188.254 Z"
            , SE.onMouseDown (keyMsg muted flatNote octave)
            , SE.onMouseUp (upKeyMsg muted flatNote octave)
            , class "black-key lower"
            ]
            [ Svg.node "title"
                []
                [ Svg.text flatLabel ]
            ]
        :: Svg.node "line"
            [ class "black-key-divider"
            , attribute "x1" "337.687"
            , attribute "y1" "187.513"
            , attribute "x2" "398.211"
            , attribute "y2" "187.513"
            ]
            []
        :: syms


fullKeyboard : Bool -> List (Attribute KeyboardMsg) -> Element KeyboardMsg
fullKeyboard muted attrs =
    fullKeyboardImpl muted attrs
        |> Element.html


fullKeyboardImpl : Bool -> List (Attribute KeyboardMsg) -> Svg.Svg KeyboardMsg
fullKeyboardImpl muted attrs =
    let
        -- partially apply these functions with the muted argument for convenience
        whiteKeyFn =
            whiteKey muted

        blackKeyFn =
            blackKey muted
    in
    Svg.node "svg"
        (attribute "viewBox" "0 0 1894 404"
            :: attribute "xmlns" "http://www.w3.org/2000/svg"
            :: attribute "width" "800"
            :: attrs
        )
        [ Svg.style
            []
            [ Svg.text """
                .white-key { fill: rgb(255, 255, 255) }
                .white-key:active { fill: rgb(0, 115, 181); }
                .white-key:active ~ .key-label { fill: rgb(255, 255, 255); }
                .natural-key { fill: rgb(216, 216, 216); stroke-width: 1.1116px; }
                .natural-key:active { fill: rgb(0, 115, 181); }
                .accidental-symbol { fill: rgb(0, 0, 0); }
                .accidental-symbol:active { fill: rgb(255, 255, 255); }
                .natural-key:active ~ .accidental-symbol { fill: rgb(255, 255, 255); }
                .natural-key-parent:has(.accidental-symbol:active) .natural-key { fill: rgb(0, 115, 181); }
                .natural-key:active ~ .white-key-divider { stroke: rgb(0, 59, 92); }
                .black-key { fill: rgb(0, 0, 0); }
                .black-key:active { fill: rgb(0, 115, 181); }
                .black-key:active ~ .accidental-symbol { fill: rgb(255, 255, 255); }
                .black-key:active ~ .black-key-parent { fill: rgb(0, 115, 181); }
                .black-key-accidental-symbol { fill: rgb(255, 255, 255); }
                .black-key-parent:has(.black-key-accidental-symbol.upper:active) .black-key.upper { fill: rgb(0, 115, 181); }
                .black-key-parent:has(.black-key-accidental-symbol.lower:active) .black-key.lower { fill: rgb(0, 115, 181); }
                .white-key-divider { fill: none; paint-order: fill; stroke: rgb(120, 120, 120); stroke-width: 3px; }
                .black-key-divider { stroke: rgb(120, 120, 120); stroke-width: 3px; }
                """
            ]
        , Svg.node "g"
            [ attribute "transform" "matrix(1, 0, 0, 1, -4.882425, 0.794207)"
            ]
            [ Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1645.85498, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KBn
                    , octave = 5
                    , plainNote = KB
                    , showSymbols = True
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1555.85498, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KAn
                    , octave = 5
                    , plainNote = KA
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 1465.756958, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KGn
                    , octave = 5
                    , plainNote = KG
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1375.85498, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KFn
                    , octave = 5
                    , plainNote = KF
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1285.85498, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KEn
                    , octave = 5
                    , plainNote = KE
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1195.85498, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KDn
                    , octave = 5
                    , plainNote = KD
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 1105.85498, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel =
                        Just
                            (Svg.node "path"
                                [ attribute "d" "M -470.212 287.097 L -473.931 287.097 Q -474.09 286.182 -474.517 285.471 Q -474.945 284.76 -475.581 284.263 Q -476.218 283.766 -477.028 283.513 Q -477.839 283.259 -478.773 283.259 Q -480.434 283.259 -481.716 284.089 Q -482.999 284.92 -483.725 286.515 Q -484.451 288.111 -484.451 290.408 Q -484.451 292.745 -483.72 294.341 Q -482.989 295.937 -481.711 296.747 Q -480.434 297.557 -478.783 297.557 Q -477.868 297.557 -477.068 297.314 Q -476.267 297.07 -475.626 296.593 Q -474.985 296.116 -474.542 295.42 Q -474.1 294.723 -473.931 293.829 L -470.212 293.848 Q -470.421 295.3 -471.112 296.573 Q -471.803 297.846 -472.917 298.815 Q -474.03 299.785 -475.522 300.326 Q -477.013 300.868 -478.833 300.868 Q -481.517 300.868 -483.625 299.625 Q -485.733 298.383 -486.946 296.036 Q -488.16 293.689 -488.16 290.408 Q -488.16 287.117 -486.937 284.775 Q -485.714 282.434 -483.606 281.191 Q -481.498 279.948 -478.833 279.948 Q -477.133 279.948 -475.671 280.425 Q -474.209 280.902 -473.066 281.822 Q -471.922 282.742 -471.182 284.069 Q -470.441 285.397 -470.212 287.097 Z M -459.957 300.868 Q -461.945 300.868 -463.516 300.118 Q -465.088 299.367 -466.007 298.054 Q -466.927 296.742 -466.987 295.052 L -463.407 295.052 Q -463.308 296.304 -462.323 297.095 Q -461.339 297.885 -459.957 297.885 Q -458.873 297.885 -458.028 297.388 Q -457.183 296.891 -456.695 296.006 Q -456.208 295.121 -456.218 293.988 Q -456.208 292.834 -456.705 291.939 Q -457.203 291.045 -458.068 290.532 Q -458.933 290.02 -460.056 290.02 Q -460.971 290.01 -461.856 290.358 Q -462.741 290.706 -463.258 291.273 L -466.589 290.726 L -465.525 280.226 L -453.713 280.226 L -453.713 283.309 L -462.472 283.309 L -463.059 288.708 L -462.94 288.708 Q -462.373 288.042 -461.339 287.599 Q -460.305 287.157 -459.072 287.157 Q -457.222 287.157 -455.771 288.027 Q -454.319 288.897 -453.484 290.418 Q -452.649 291.939 -452.649 293.898 Q -452.649 295.917 -453.578 297.493 Q -454.508 299.069 -456.154 299.969 Q -457.799 300.868 -459.957 300.868 Z"
                                , attribute "transform" "matrix(1.055555, 0, 0, 1.240001, 692.847229, 0.51585)"
                                , class "key-label"
                                , SE.onMouseDown (keyMsg muted KC 5)
                                , SE.onMouseUp (upKeyMsg muted KC 5)
                                ]
                                []
                            )
                    , naturalNote = KCn
                    , octave = 5
                    , plainNote = KC
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 1015.756958, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KBn
                    , octave = 4
                    , plainNote = KB
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 925.854919, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KAn
                    , octave = 4
                    , plainNote = KA
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 835.854858, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KGn
                    , octave = 4
                    , plainNote = KG
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 745.854919, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KFn
                    , octave = 4
                    , plainNote = KF
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 655.756958, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KEn
                    , octave = 4
                    , plainNote = KE
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 565.854919, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KDn
                    , octave = 4
                    , plainNote = KD
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 475.756927, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel =
                        Just
                            (Svg.node "path"
                                [ attribute "d" "M 196.021 356.517 L 192.096 356.517 C 191.984 355.76 191.777 355.088 191.477 354.5 C 191.175 353.913 190.801 353.413 190.354 353.002 C 189.905 352.592 189.397 352.282 188.827 352.072 C 188.255 351.863 187.641 351.758 186.985 351.758 C 185.815 351.758 184.78 352.101 183.878 352.787 C 182.975 353.474 182.268 354.476 181.757 355.795 C 181.247 357.114 180.991 358.723 180.991 360.622 C 180.991 362.554 181.248 364.18 181.763 365.499 C 182.277 366.819 182.984 367.813 183.883 368.483 C 184.782 369.152 185.812 369.487 186.974 369.487 C 187.618 369.487 188.221 369.387 188.784 369.186 C 189.348 368.984 189.855 368.686 190.306 368.292 C 190.757 367.897 191.138 367.413 191.451 366.837 C 191.761 366.262 191.976 365.604 192.096 364.864 L 196.021 364.889 C 195.873 366.089 195.557 367.215 195.071 368.267 C 194.585 369.319 193.949 370.246 193.166 371.047 C 192.383 371.849 191.465 372.474 190.416 372.922 C 189.367 373.369 188.202 373.593 186.921 373.593 C 185.032 373.593 183.346 373.079 181.863 372.053 C 180.379 371.025 179.21 369.541 178.358 367.601 C 177.503 365.661 177.076 363.335 177.076 360.622 C 177.076 357.902 177.506 355.573 178.367 353.637 C 179.227 351.702 180.399 350.221 181.883 349.193 C 183.366 348.166 185.046 347.652 186.921 347.652 C 188.117 347.652 189.23 347.849 190.259 348.243 C 191.287 348.638 192.204 349.215 193.009 349.976 C 193.813 350.736 194.476 351.665 194.997 352.762 C 195.519 353.86 195.86 355.111 196.021 356.517 Z M 198.978 368.563 L 198.978 364.925 L 208.099 347.997 L 210.681 347.997 L 210.681 353.175 L 209.107 353.175 L 202.967 364.605 L 202.967 364.802 L 215.698 364.802 L 215.698 368.563 L 198.978 368.563 Z M 209.233 373.248 L 209.233 367.453 L 209.275 365.825 L 209.275 347.997 L 212.948 347.997 L 212.948 373.248 L 209.233 373.248 Z"
                                , class "key-label"
                                , SE.onMouseDown (keyMsg muted KC 4)
                                , SE.onMouseUp (upKeyMsg muted KC 4)
                                ]
                                []
                            )
                    , naturalNote = KCn
                    , octave = 4
                    , plainNote = KC
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 385.854919, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KBn
                    , octave = 3
                    , plainNote = KB
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 295.756927, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KAn
                    , octave = 3
                    , plainNote = KA
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 205.854904, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KGn
                    , octave = 3
                    , plainNote = KG
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.942892, 0, 0, 0.803335, 115.854912, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KFn
                    , octave = 3
                    , plainNote = KF
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, 25.756935, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KEn
                    , octave = 3
                    , plainNote = KE
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.943466, 0, 0, 0.803335, -64.243065, 5.826072)"
                ]
                (whiteKeyFn
                    { keyLabel = Nothing
                    , naturalNote = KDn
                    , octave = 3
                    , plainNote = KD
                    , showSymbols = False
                    }
                )

            --- The first svg shape is special, so we keep it as original
            , Svg.node "g"
                [ attribute "transform" "matrix(0.99588, 0, 0, 0.803335, -192.993332, 5.792036)"
                ]
                [ Svg.node "title"
                    []
                    [ Svg.text "C3" ]
                , Svg.node "rect"
                    [ attribute "x" "203.763"
                    , attribute "y" "-4.575"
                    , attribute "width" "86.551"
                    , attribute "height" "403.887"
                    , class "white-key"
                    , SE.onMouseDown (keyMsg muted KC 3)
                    , SE.onMouseUp (upKeyMsg muted KC 3)
                    ]
                    []
                , Svg.node "path"
                    [ attribute "d" "M -470.212 287.097 L -473.931 287.097 Q -474.09 286.182 -474.517 285.471 Q -474.945 284.76 -475.581 284.263 Q -476.218 283.766 -477.028 283.513 Q -477.838 283.259 -478.773 283.259 Q -480.434 283.259 -481.716 284.089 Q -482.999 284.92 -483.725 286.515 Q -484.451 288.111 -484.451 290.408 Q -484.451 292.745 -483.72 294.341 Q -482.989 295.937 -481.711 296.747 Q -480.434 297.557 -478.783 297.557 Q -477.868 297.557 -477.068 297.314 Q -476.267 297.07 -475.626 296.593 Q -474.985 296.116 -474.542 295.42 Q -474.1 294.723 -473.931 293.829 L -470.212 293.848 Q -470.421 295.3 -471.112 296.573 Q -471.803 297.846 -472.917 298.815 Q -474.03 299.785 -475.522 300.326 Q -477.013 300.868 -478.833 300.868 Q -481.517 300.868 -483.625 299.625 Q -485.733 298.383 -486.946 296.036 Q -488.159 293.689 -488.159 290.408 Q -488.159 287.117 -486.936 284.775 Q -485.713 282.434 -483.606 281.191 Q -481.498 279.948 -478.833 279.948 Q -477.133 279.948 -475.671 280.425 Q -474.209 280.902 -473.066 281.822 Q -471.922 282.742 -471.182 284.069 Q -470.441 285.397 -470.212 287.097 Z M -459.734 300.868 Q -461.882 300.868 -463.548 300.133 Q -465.213 299.397 -466.178 298.084 Q -467.142 296.772 -467.202 295.052 L -463.463 295.052 Q -463.413 295.877 -462.916 296.488 Q -462.419 297.1 -461.594 297.438 Q -460.769 297.776 -459.744 297.776 Q -458.651 297.776 -457.805 297.393 Q -456.96 297.01 -456.483 296.324 Q -456.006 295.638 -456.016 294.743 Q -456.006 293.819 -456.493 293.113 Q -456.98 292.407 -457.9 292.009 Q -458.82 291.611 -460.112 291.611 L -461.912 291.611 L -461.912 288.768 L -460.112 288.768 Q -459.048 288.768 -458.248 288.4 Q -457.447 288.032 -456.99 287.361 Q -456.533 286.689 -456.543 285.804 Q -456.533 284.939 -456.925 284.298 Q -457.318 283.657 -458.029 283.299 Q -458.74 282.941 -459.695 282.941 Q -460.629 282.941 -461.425 283.279 Q -462.22 283.617 -462.707 284.238 Q -463.195 284.86 -463.224 285.715 L -466.774 285.715 Q -466.734 284.005 -465.785 282.707 Q -464.835 281.41 -463.244 280.679 Q -461.653 279.948 -459.675 279.948 Q -457.636 279.948 -456.13 280.709 Q -454.624 281.469 -453.798 282.752 Q -452.973 284.035 -452.973 285.586 Q -452.963 287.306 -453.982 288.469 Q -455.001 289.633 -456.652 289.991 L -456.652 290.15 Q -454.504 290.448 -453.356 291.736 Q -452.207 293.023 -452.217 294.932 Q -452.217 296.643 -453.187 297.99 Q -454.156 299.337 -455.852 300.103 Q -457.547 300.868 -459.734 300.868 Z"
                    , attribute "transform" "matrix(1, 0, 0, 1.240001, 694.940796, 1.246563)"
                    , class "key-label"
                    , SE.onMouseDown (keyMsg muted KC 3)
                    , SE.onMouseUp (upKeyMsg muted KC 3)
                    ]
                    []
                , Svg.node "g"
                    [ attribute "transform" "matrix(1, 0, 0, 1, 0.000007, 0)" ]
                    [ Svg.node "rect"
                        [ attribute "x" "202.666"
                        , attribute "y" "401.462"
                        , attribute "width" "86.64"
                        , attribute "height" "89.191"
                        , class "natural-key"
                        , SE.onMouseDown (keyMsg muted KCn 3)
                        , SE.onMouseUp (upKeyMsg muted KCn 3)
                        ]
                        []
                    , Svg.node "line"
                        [ class "white-key-divider"
                        , attribute "x1" "201.246"
                        , attribute "y1" "400.648"
                        , attribute "x2" "290.474"
                        , attribute "y2" "400.648"
                        ]
                        []
                    , Svg.node "path"
                        [ attribute "d" "M 241.5 469.375 C 241.219 469.143 241.031 468.56 241.031 468.093 L 241.031 410.422 L 243.569 410.422 L 243.569 430.81 L 255.405 426.732 L 255.781 426.732 C 256.533 426.732 257.097 427.316 257.097 428.246 L 257.097 485.92 L 254.469 485.92 L 254.469 465.532 L 242.628 469.606 C 242.534 469.606 242.347 469.724 242.252 469.724 C 241.97 469.724 241.689 469.606 241.5 469.375 Z M 254.469 436.755 L 243.569 440.483 L 243.569 459.705 L 254.469 455.859 L 254.469 436.755 Z"
                        , class "accidental-symbol"
                        , SE.onMouseDown (keyMsg muted KCn 3)
                        , SE.onMouseUp (upKeyMsg muted KCn 3)
                        ]
                        []
                    ]
                , Svg.node "path"
                    [ attribute "style" "stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px; fill: none;"
                    , attribute "d" "M 200.799 -5.094 L 291.171 -5.094 L 291.171 484.486 C 291.171 488.901 287.761 492.83 283.576 492.83 L 208.378 492.481 C 204.19 492.481 200.799 488.901 200.799 484.486 L 200.799 -5.094 Z"
                    ]
                    []
                ]
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, -266.321503, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KDf
                    , octave = 3
                    , sharpNote = KCs
                    , showSymbols = True
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, -176.321503, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KEf
                    , octave = 3
                    , sharpNote = KDs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 3.678497, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KGf
                    , octave = 3
                    , sharpNote = KFs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 93.678497, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KAf
                    , octave = 3
                    , sharpNote = KGs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 183.678497, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KBf
                    , octave = 3
                    , sharpNote = KAs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 363.678497, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KDf
                    , octave = 4
                    , sharpNote = KCs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 453.678497, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KEf
                    , octave = 4
                    , sharpNote = KDs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 633.678467, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KGf
                    , octave = 4
                    , sharpNote = KFs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 723.678467, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KAf
                    , octave = 4
                    , sharpNote = KGs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 813.678467, -28.770775)" ]
                (blackKeyFn
                    { flatNote = KBf
                    , octave = 4
                    , sharpNote = KAs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 993.678467, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KDf
                    , octave = 5
                    , sharpNote = KCs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 1083.678467, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KEf
                    , octave = 5
                    , sharpNote = KDs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 1263.678467, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KGf
                    , octave = 5
                    , sharpNote = KFs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 1353.678467, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KAf
                    , octave = 5
                    , sharpNote = KGs
                    , showSymbols = False
                    }
                )
            , Svg.node "g"
                [ attribute "transform" "matrix(0.987622, 0, 0, 0.841424, 1443.678467, -28.770775)"
                , class "black-key-parent"
                ]
                (blackKeyFn
                    { flatNote = KBf
                    , octave = 5
                    , sharpNote = KAs
                    , showSymbols = True
                    }
                )
            ]
        ]
