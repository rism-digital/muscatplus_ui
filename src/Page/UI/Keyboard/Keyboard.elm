module Page.UI.Keyboard.Keyboard exposing (..)

import Element exposing (Attr, Attribute, Element, alignLeft, alignTop, el, html, htmlAttribute, moveLeft)
import Html.Attributes
import Page.UI.Keyboard.Model exposing (Key(..), KeyNoteName(..))
import Page.UI.Keyboard.PAE exposing (keyNoteNameToNoteString)
import Svg exposing (Svg, svg)
import Svg.Attributes exposing (cursor, d, height, pointerEvents, style, version, viewBox, width, x, y)
import Svg.Events exposing (onClick)


type alias KeyNoteConfig =
    { keyType : Key
    }


octaveConfig : List KeyNoteConfig
octaveConfig =
    [ { keyType = WhiteKey KC
      }
    , { keyType = BlackKey KCs KDf
      }
    , { keyType = WhiteKey KD
      }
    , { keyType = BlackKey KDs KEf
      }
    , { keyType = WhiteKey KE
      }
    , { keyType = WhiteKey KF
      }
    , { keyType = BlackKey KFs KGf
      }
    , { keyType = WhiteKey KG
      }
    , { keyType = BlackKey KGs KAf
      }
    , { keyType = WhiteKey KA
      }
    , { keyType = BlackKey KAs KBf
      }
    , { keyType = WhiteKey KB
      }
    ]


whiteKey : Attribute msg -> Maybe String -> msg -> Element msg
whiteKey offset keyLabel keyMsg =
    let
        whiteKeyWidth =
            toFloat blackKeyWidth * whiteKeyWidthScale

        keyNoteLabel =
            case keyLabel of
                Just label ->
                    Svg.text_
                        [ style "fill: rgb(51, 51, 51); font-family: Inter, sans-serif; font-size: 40px; font-weight: 600; white-space: pre;"
                        , x "26"
                        , y "432"
                        , onClick keyMsg
                        , cursor "pointer"
                        ]
                        [ Svg.text label ]

                Nothing ->
                    Svg.text ""

        -- The original key shape was 100 x 500, so when scaling we just multiply the
        -- width by 5 to maintain the same ratio.
        keyShape =
            html
                (svg
                    [ width (String.fromFloat whiteKeyWidth)
                    , height (String.fromFloat (whiteKeyWidth * 5))
                    , viewBox "0 0 100 500"
                    , version "1.1"
                    ]
                    [ Svg.path
                        [ style "fill:rgba(255, 255, 255, 1); stroke: rgb(0, 0, 0); paint-order: fill; stroke-width: 4px;"
                        , d "M 2.437 0.518 H 97.83 V 490.442 A 8 8 0 0 1 89.83 498.442 H 10.437 A 8 8 0 0 1 2.437 490.442 V 0.518 Z"
                        , onClick keyMsg
                        , cursor "pointer"
                        ]
                        []
                    , keyNoteLabel
                    ]
                )
    in
    el
        [ alignTop
        , alignLeft
        , htmlAttribute (Html.Attributes.style "z-index" "0")
        , offset
        ]
        keyShape


{-|

    All measurements in the keyboard are based on the width of the black keys.
    Adjust this number if you want to increase or decrease the size of the
    keyboard.

-}
blackKeyWidth : Int
blackKeyWidth =
    20


blackKeyHalfWidth : Int
blackKeyHalfWidth =
    ceiling (toFloat blackKeyWidth / 2) + 1


offsetPadding : Int
offsetPadding =
    -(blackKeyHalfWidth - 3)


{-|

    The width relationship of the white key to the black key. This
    was created with an original size of 100 for white keys, making
    black keys 61. Since we are defining all scaling based on the
    full width of the black key, we use this factor to compute the
    corresponding width of the white keys.

-}
whiteKeyWidthScale : Float
whiteKeyWidthScale =
    1.6393442623


{-|

    The scaling factor by which the width of a black key
    is related to height. The original measurements were (w x h)
    61 x 309.

-}
blackKeyHeightScale : Float
blackKeyHeightScale =
    5.0655737705


blackKey : Attribute msg -> msg -> msg -> Element msg
blackKey offset upper lower =
    let
        blackKeyHeight =
            toFloat blackKeyWidth * blackKeyHeightScale

        keyShape =
            html
                (svg
                    [ width (String.fromInt blackKeyWidth)
                    , height (String.fromFloat blackKeyHeight)
                    , viewBox "0 0 61 309"
                    , version "1.1"
                    , pointerEvents "bounding-box"
                    ]
                    [ Svg.path
                        [ d "M 0 0 L 60.74 0 L 60.74 300.73 C 60.74 305.297 57.381 309 53.239 309 L 7.501 309 C 3.359 309 0 305.297 0 300.73 L 0 0 Z"
                        ]
                        []
                    , Svg.rect
                        [ x "0.71"
                        , y "0.088"
                        , width "59.58"
                        , height "142.97"
                        , style "fill: black;"
                        , onClick upper
                        , cursor "pointer"
                        ]
                        []
                    , Svg.path
                        [ d "M 35.711 34.908 L 35.711 11.424 L 38.073 11.424 L 38.073 34.214 L 44.188 32.269 L 44.188 44.914 L 38.073 46.86 L 38.073 69.788 L 44.188 68.121 L 44.188 80.767 L 38.073 82.573 L 38.073 104.113 L 35.711 104.113 L 35.711 83.268 L 25.15 86.325 L 25.15 107.864 L 22.787 107.864 L 22.787 87.159 L 16.812 88.965 L 16.812 76.459 L 22.787 74.513 L 22.787 51.306 L 16.812 53.252 L 16.812 40.467 L 22.787 38.661 L 22.787 15.176 L 25.15 15.176 L 25.15 37.827 Z M 25.15 50.611 L 25.15 73.818 L 35.711 70.761 L 35.711 47.415 Z"
                        , style "fill: rgb(255, 255, 255);"
                        , onClick upper
                        , cursor "pointer"
                        ]
                        []
                    , Svg.rect
                        [ x "0.71"
                        , y "157.306"
                        , width "59.58"
                        , height "142.97"
                        , style "fill: black"
                        , onClick lower
                        , cursor "pointer"
                        ]
                        []
                    , Svg.path
                        [ d "M 20.963 260.438 C 24.827 258.506 27.483 257.178 32.191 257.178 C 35.33 257.178 36.416 257.54 38.71 258.748 C 40.279 259.593 41.607 261.162 41.969 263.335 L 42.452 266.353 C 42.452 269.733 40.521 273.234 37.02 277.097 C 34.243 280.116 32.311 282.409 29.173 285.307 L 18.549 294.844 L 18.549 217.098 L 20.963 217.098 L 20.963 260.438 Z M 29.414 260.921 C 25.551 260.921 23.619 262.128 20.963 264.421 L 20.963 287.842 C 24.706 284.099 27.483 280.719 29.535 277.701 C 32.07 273.838 33.398 270.578 33.398 267.56 C 33.398 266.474 33.519 265.629 33.519 265.146 C 33.519 263.456 33.157 262.611 32.191 261.524 L 31.225 261.162 Z"
                        , style "fill: rgb(255, 255, 255);"
                        , onClick lower
                        , cursor "pointer"
                        ]
                        []
                    ]
                )
    in
    el
        [ alignTop
        , alignLeft
        , offset
        , htmlAttribute (Html.Attributes.style "z-index" "1")
        ]
        keyShape


renderKey : (KeyNoteName -> Int -> msg) -> Int -> KeyNoteConfig -> Element msg
renderKey keyMsg idx keyConfig =
    let
        -- determines whether we're on an 'e-f' interval, which requires special layout
        -- adjustments due to the missing black key. This occurs at the 5th, 17th, 29th, etc.
        -- semitones, which we can determine by checking if the calculation for the current
        -- index when divided by 12 semitones gives a remainder of 5.
        -- For example:
        --    (5  % 12) = 5
        --    (29 % 12) = 5
        --    (41 % 12) = 5
        efInterval : Bool
        efInterval =
            modBy 12 idx == 5

        indexPadding =
            if efInterval then
                floor (toFloat (idx + 1) / 6)

            else
                floor (toFloat idx / 6)

        -- the current offset is calculated from the padding applied to the shape multiplied by
        -- the padding calculated by the current keyboard position, added to half the black key size
        -- (so that the black key half-overlaps the white keys).
        indexedOffset =
            idx * blackKeyHalfWidth + (offsetPadding * indexPadding)

        moveOffset =
            moveLeft (toFloat indexedOffset)

        -- start the octave numbers at C3
        octave =
            floor (toFloat idx / 12) + 3

        keyDrawingFunction =
            case keyConfig.keyType of
                WhiteKey keyName ->
                    let
                        keyNameForLabel =
                            case keyName of
                                KC ->
                                    Just (keyNoteNameToNoteString keyName ++ String.fromInt octave)

                                _ ->
                                    Nothing
                    in
                    whiteKey moveOffset keyNameForLabel (keyMsg keyName octave)

                BlackKey upperKey lowerKey ->
                    blackKey moveOffset (keyMsg upperKey octave) (keyMsg lowerKey octave)
    in
    keyDrawingFunction
