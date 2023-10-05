module KeyCodes exposing (ArrowDirection(..), keyDecoder)

import Json.Decode as Decode exposing (Decoder)


type ArrowDirection
    = ArrowUp
    | ArrowDown
    | ArrowLeft
    | ArrowRight
    | NotAnArrowKey


toArrowDirection : String -> ArrowDirection
toArrowDirection keyCode =
    case keyCode of
        "ArrowLeft" ->
            ArrowLeft

        "ArrowRight" ->
            ArrowRight

        "ArrowUp" ->
            ArrowUp

        "ArrowDown" ->
            ArrowDown

        _ ->
            NotAnArrowKey


keyDecoder : Decoder ArrowDirection
keyDecoder =
    Decode.field "key" Decode.string
        |> Decode.map toArrowDirection
