module KeyCodes exposing (ArrowDirection(..), keyDecoder)

import Json.Decode as Decode exposing (Decoder)


type ArrowDirection
    = ArrowUp Bool
    | ArrowDown Bool
    | ArrowLeft
    | ArrowRight
    | NotAnArrowKey


toArrowDirection : String -> Bool -> ArrowDirection
toArrowDirection keyCode shiftPressed =
    case keyCode of
        "ArrowDown" ->
            ArrowDown shiftPressed

        "ArrowLeft" ->
            ArrowLeft

        "ArrowRight" ->
            ArrowRight

        "ArrowUp" ->
            ArrowUp shiftPressed

        _ ->
            NotAnArrowKey


keyDecoder : Decoder ArrowDirection
keyDecoder =
    Decode.map2 toArrowDirection
        (Decode.field "key" Decode.string)
        (Decode.field "shiftKey" Decode.bool)
