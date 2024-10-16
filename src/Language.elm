module Language exposing
    ( Language(..)
    , LanguageMap
    , LanguageMapReplacementVariable(..)
    , LanguageValue(..)
    , dateFormatter
    , extractLabelFromLanguageMap
    , extractLabelFromLanguageMapWithVariables
    , extractTextFromLanguageMap
    , formatNumberByLanguage
    , languageMapDecoder
    , languageOptions
    , limitLength
    , parseLanguageToLabel
    , parseLanguageToLocale
    , parseLocaleToLanguage
    , toLanguageMap
    , toLanguageMapWithLanguage
    )

import DateFormat
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Decimals(..), Locale, base)
import Json.Decode as Decode exposing (Decoder)
import List.Extra as LE
import Maybe.Extra as ME
import String.Extra as SE
import Time exposing (Posix, Zone)
import Utilities exposing (namedValue)


type Language
    = English
    | French
    | German
    | Italian
    | Portuguese
    | Spanish
    | Polish
    | None


type alias LanguageMap =
    List LanguageValue


{-|

    For languagemap replacements the first value is the field name,
    and the second is the value to replace it with.

-}
type LanguageMapReplacementVariable
    = LanguageMapReplacementVariable String String


type LanguageValue
    = LanguageValue Language (List String)


{-|

    Takes a string and creates a language map. Used for compatibility
    where the value of a language map is then extracted as a string.

-}
toLanguageMap : String -> LanguageMap
toLanguageMap s =
    toLanguageMapWithLanguage None s


toLanguageMapWithLanguage : Language -> String -> LanguageMap
toLanguageMapWithLanguage language text =
    [ LanguageValue language [ text ] ]


limitLength : Int -> LanguageMap -> LanguageMap
limitLength len langMap =
    List.map
        (\(LanguageValue langCode sVals) ->
            List.map (\sv -> SE.softEllipsis len sv) sVals
                |> LanguageValue langCode
        )
        langMap


{-|

    A simple list of the language options supported by the site.

-}
languageOptions : List ( String, String, Language )
languageOptions =
    [ ( "en", "English", English )
    , ( "de", "Deutsch", German )
    , ( "fr", "Français", French )
    , ( "it", "Italiano", Italian )
    , ( "es", "Español", Spanish )
    , ( "pt", "Português", Portuguese )
    , ( "pl", "Polskie", Polish )
    , ( "none", "None", None )
    ]



-- DATE FORMATTING


dateFormatter : Zone -> Posix -> String
dateFormatter =
    DateFormat.format
        [ DateFormat.monthNameFull
        , DateFormat.text " "
        , DateFormat.dayOfMonthSuffix
        , DateFormat.text ", "
        , DateFormat.yearNumber
        ]


extractLabelFromLanguageMap : Language -> LanguageMap -> String
extractLabelFromLanguageMap lang langMap =
    {-
       Returns a single string from a language map. Multiple values for a single language are
       concatenated together with a semicolon.
    -}
    extractTextFromLanguageMap lang langMap
        |> String.join "; "


extractTextFromLanguageMap : Language -> LanguageMap -> List String
extractTextFromLanguageMap lang langMap =
    {-
       if there is a language value that matches one in the language map, return the string value of the concatenated list.
       if there is no language value that matches the language map, but there is a "None" language, return the string value of the concatenated list
       if there is no language value matching the language map, and there is no None language in the map, return the string value of the concatenated list for English.

       Return a list of the strings, which can either be concatenated together or marked up in paragraphs.

       The 'orListLazy' method will return the first non-Nothing result and then pass that along. If the selected language
       is not English, but the English value was the first non-Nothing result, it means that we're using this as a
       fallback when no other values are available.
    -}
    ME.orListLazy
        [ \() -> LE.find (\(LanguageValue l _) -> l == lang) langMap
        , \() -> LE.find (\(LanguageValue l _) -> l == None) langMap
        , \() -> LE.find (\(LanguageValue l _) -> l == English) langMap
        ]
        |> Maybe.map
            (\(LanguageValue _ v) ->
                v
            )
        |> Maybe.withDefault [ "[No language value found]" ]


{-|

    Formats a number according to a particular regional locale.
    Returns a string corresponding to the formatted number.

-}
formatNumberByLanguage : Language -> Float -> String
formatNumberByLanguage lang num =
    case lang of
        English ->
            format englishLocale num

        French ->
            format frenchLocale num

        German ->
            format germanLocale num

        Italian ->
            format italianLocale num

        Portuguese ->
            format portugeseLocale num

        Spanish ->
            format spanishLocale num

        Polish ->
            format polishLocale num

        None ->
            format englishLocale num


{-|

    A custom decoder that takes a JSON-LD Language Map and produces a list of
    LanguageValues Language (List String), representing each of the translations
    available for this particular field.

-}
languageMapDecoder : List ( String, List String ) -> Decoder LanguageMap
languageMapDecoder json =
    List.foldl
        (\map maps -> Decode.map2 (::) (languageValuesDecoder map) maps)
        (Decode.succeed [])
        json


{-|

    Takes a string and returns the corresponding language type, e.g.,
    "en" -> English.

-}
parseLocaleToLanguage : String -> Language
parseLocaleToLanguage locale =
    -- defaults to English if no language is detected
    LE.findMap
        (\( l, _, s ) ->
            if l == locale then
                Just s

            else
                Nothing
        )
        languageOptions
        |> Maybe.withDefault English


parseLanguageToLabel : Language -> String
parseLanguageToLabel language =
    LE.findMap
        (\( _, h, s ) ->
            if s == language then
                Just h

            else
                Nothing
        )
        languageOptions
        |> Maybe.withDefault "English"


parseLanguageToLocale : Language -> String
parseLanguageToLocale language =
    LE.findMap
        (\( l, _, s ) ->
            if s == language then
                Just l

            else
                Nothing
        )
        languageOptions
        |> Maybe.withDefault "en"


englishLocale : Locale
englishLocale =
    { base
        | decimals = Max 2
        , thousandSeparator = ","
    }


extractLabelFromLanguageMapWithVariables : Language -> List LanguageMapReplacementVariable -> LanguageMap -> String
extractLabelFromLanguageMapWithVariables lang replacements langMap =
    extractTextFromLanguageMapWithVariables lang replacements langMap
        |> String.join "; "


extractTextFromLanguageMapWithVariables : Language -> List LanguageMapReplacementVariable -> LanguageMap -> List String
extractTextFromLanguageMapWithVariables lang replacements langMap =
    List.map
        (\inputString ->
            List.foldl
                (\(LanguageMapReplacementVariable var val) currString ->
                    namedValue var val currString
                )
                inputString
                replacements
        )
        (extractTextFromLanguageMap lang langMap)


frenchLocale : Locale
frenchLocale =
    { base
        | decimals = Max 3
        , thousandSeparator = "\u{202F}"
        , decimalSeparator = ","
    }


germanLocale : Locale
germanLocale =
    { base
        | decimals = Max 2
        , thousandSeparator = "."
        , decimalSeparator = ","
    }


italianLocale : Locale
italianLocale =
    { base
        | decimals = Max 2
        , thousandSeparator = "."
        , decimalSeparator = ","
    }


languageDecoder : String -> Decoder Language
languageDecoder locale =
    Decode.succeed (parseLocaleToLanguage locale)


languageValuesDecoder : ( String, List String ) -> Decoder LanguageValue
languageValuesDecoder ( locale, translations ) =
    languageDecoder locale
        |> Decode.map (\lang -> LanguageValue lang translations)



--{-|
--
--    Takes a language type and returns the string representation,
--    e.g., "en", "de", etc.
--
---}
--parseLanguageToLocale : Language -> String
--parseLanguageToLocale lang =
--    -- it's unlikely that a language will get passed in that doesn't exist,
--    -- but this will use English as the default language if that ever happens
--    -- creates a new list with just the locale and language type, then filters
--    LE.findMap
--        (\( l, _, s ) ->
--            if s == lang then
--                Just l
--
--            else
--                Nothing
--        )
--        languageOptions
--        |> Maybe.withDefault "en"


polishLocale : Locale
polishLocale =
    { base
        | decimals = Max 3
        , thousandSeparator = "\u{202F}"
        , decimalSeparator = ","
    }


portugeseLocale : Locale
portugeseLocale =
    { base
        | decimals = Max 3
        , thousandSeparator = "\u{202F}"
        , decimalSeparator = ","
    }


spanishLocale : Locale
spanishLocale =
    { base
        | decimals = Max 3
        , thousandSeparator = "."
        , decimalSeparator = ","
    }
