module Page.Keyboard.Utilities exposing (comparableToSymHelper, symToStringHelper)

{-| Takes a list of (comparable, sym) and returns the sym for a given comparable, with a
default value specified if that comparable is not available in the list.
-}

import Dict


comparableToSymHelper :
    { defaultValue : sym
    , target : comparable
    , valueMap : List ( comparable, sym )
    }
    -> sym
comparableToSymHelper cfg =
    Dict.fromList cfg.valueMap
        |> Dict.get cfg.target
        |> Maybe.withDefault cfg.defaultValue


{-|

    Takes a list of (String, a) and returns the first string value for a given 'a', or a default value
    if that 'a' is not found in the list.

-}
symToStringHelper :
    { defaultValue : String
    , target : a
    , valueMap : List ( String, a )
    }
    -> String
symToStringHelper cfg =
    List.filter (\( _, cc ) -> cc == cfg.target) cfg.valueMap
        |> List.map Tuple.first
        |> List.head
        |> Maybe.withDefault cfg.defaultValue
