module Page.Search.Utilities exposing (..)

import Page.Query exposing (rangeStringParser)


parseRangeFilterValue : List String -> ( String, String )
parseRangeFilterValue currentValue =
    case currentValue of
        [] ->
            ( "*", "*" )

        x :: _ ->
            rangeStringParser x


createRangeString : String -> String -> String
createRangeString lower upper =
    "[" ++ lower ++ " TO " ++ upper ++ "]"
