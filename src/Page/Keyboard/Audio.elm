module Page.Keyboard.Audio exposing (generateNotes)

import Page.Keyboard.Model exposing (KeyNoteName(..), Octave)
import WebAudio
import WebAudio.Property


stepsFromA : KeyNoteName -> Int
stepsFromA note =
    case note of
        KC ->
            -9

        KCn ->
            -9

        KCs ->
            -8

        KDf ->
            -8

        KD ->
            -7

        KDn ->
            -7

        KDs ->
            -6

        KEf ->
            -6

        KE ->
            -5

        KEn ->
            -5

        KF ->
            -4

        KFn ->
            -4

        KFs ->
            -3

        KGf ->
            -3

        KG ->
            -2

        KGn ->
            -2

        KGs ->
            -1

        KAf ->
            -1

        KA ->
            0

        KAn ->
            0

        KAs ->
            1

        KBf ->
            1

        KB ->
            2

        KBn ->
            2


fundamentalAFrequency : Float
fundamentalAFrequency =
    440.0


calculateFrequency : Int -> Float
calculateFrequency steps =
    fundamentalAFrequency * ((2 ^ (1 / 12)) ^ toFloat steps)


calculateSteps : KeyNoteName -> Octave -> Int
calculateSteps note octave =
    ((octave - 4) * 12) + stepsFromA note


generateNotes : List ( KeyNoteName, Octave ) -> List WebAudio.Node
generateNotes noteList =
    case noteList of
        [] ->
            []

        _ ->
            List.concat
                [ [ WebAudio.gain
                        [ WebAudio.Property.gain 0.3 ]
                        [ WebAudio.dac ]
                        |> WebAudio.keyed "dac"
                  ]
                , List.map generateNote noteList
                ]


generateNote : ( KeyNoteName, Octave ) -> WebAudio.Node
generateNote ( note, octave ) =
    let
        freq =
            calculateSteps note octave
                |> calculateFrequency
    in
    WebAudio.oscillator
        [ WebAudio.Property.frequency freq
        ]
        [ WebAudio.ref "dac"
        ]
