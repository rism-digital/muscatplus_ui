module Language.Tooltips exposing (tooltips)

import Language exposing (Language(..), LanguageMap, LanguageValues(..))


englishComposerAuthorTooltip : List String
englishComposerAuthorTooltip =
    [ """English composer author tooltip""" ]


frenchComposerAuthorTooltip : List String
frenchComposerAuthorTooltip =
    [ """French composer author tooltip""" ]


englishIncipitSearchTooltip : List String
englishIncipitSearchTooltip =
    [ """English incipit search tooltip""" ]


frenchIncipitSearchTooltip : List String
frenchIncipitSearchTooltip =
    [ """French incipit search tooltip""" ]


tooltips :
    { composerAuthor : LanguageMap
    , incipit : LanguageMap
    }
tooltips =
    { composerAuthor =
        [ LanguageValues English englishComposerAuthorTooltip
        , LanguageValues French frenchComposerAuthorTooltip
        ]
    , incipit =
        [ LanguageValues English englishIncipitSearchTooltip
        , LanguageValues French frenchIncipitSearchTooltip
        ]
    }
