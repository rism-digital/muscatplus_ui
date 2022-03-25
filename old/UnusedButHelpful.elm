

{-|

    Takes a range query string, such as "[1900 TO 2000]", and parses
    it to a tuple pair representing the start and end dates. Also supports
    wildcards, e.g., "[* TO 1700]", "[1700 TO *]" and "[* TO *]".

    If the query string cannot be parsed it returns a ("", "") pair, and lets
    the downstream components do any validation on this input.

-}
rangeStringParser : String -> ( String, String )
rangeStringParser rString =
    let
        isStar : Char -> Bool
        isStar c =
            c == '*'

        -- chooses one of the following for valid input
        --  - A number (float)
        --  - A star "*"
        oneOfParser : Parser String
        oneOfParser =
            P.oneOf
                [ P.map String.fromFloat P.float
                , P.map identity <| P.getChompedString (P.chompIf isStar)
                ]

        qParser =
            P.succeed Tuple.pair
                |. P.symbol "["
                |= oneOfParser
                |. P.spaces
                |. P.symbol "TO"
                |. P.spaces
                |= oneOfParser
                |. P.symbol "]"
                |. P.end
    in
    case P.run qParser rString of
        Ok res ->
            res

        Err _ ->
            ( "", "" )
