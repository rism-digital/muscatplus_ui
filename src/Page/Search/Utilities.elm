module Page.Search.Utilities exposing (..)


createRangeString : String -> String -> String
createRangeString lower upper =
    "[" ++ lower ++ " TO " ++ upper ++ "]"
