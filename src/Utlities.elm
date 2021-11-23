module Utlities exposing (..)


flip : (a -> b -> c) -> b -> a -> c
flip function argB argA =
    function argA argB
