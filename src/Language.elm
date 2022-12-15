module Language exposing
    ( Language(..)
    , LanguageMap
    , LanguageMapReplacementVariable(..)
    , LanguageValues(..)
    , dateFormatter
    , extractLabelFromLanguageMap
    , extractLabelFromLanguageMapWithVariables
    , extractTextFromLanguageMap
    , formatNumberByLanguage
    , languageMapDecoder
    , languageOptionsForDisplay
    , parseLocaleToLanguage
    )

import DateFormat
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Decimals(..), Locale, base)
import Json.Decode as Decode exposing (Decoder)
import List.Extra as LE
import Maybe.Extra as ME
import Time exposing (Posix, Zone)
import Utilities exposing (namedValue)


type Language
    = English
    | French
    | German
    | Italian
    | Portugese
    | Spanish
    | Polish
    | None


type alias LanguageMap =
    List LanguageValues


{-|

    For languagemap replacements the first value is the field name,
    and the second is the value to replace it with.

-}
type LanguageMapReplacementVariable
    = LanguageMapReplacementVariable String String


type LanguageValues
    = LanguageValues Language (List String)


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
    , ( "pt", "Português", Portugese )
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
    String.join "; " (extractTextFromLanguageMap lang langMap)


extractTextFromLanguageMap : Language -> LanguageMap -> List String
extractTextFromLanguageMap lang langMap =
    {-
       if there is a language value that matches one in the language map, return the string value of the concatenated list.
       if there is no language value that matches the language map, but there is a "None" language, return the string value of the concatenated list
       if there is no language value matching the language map, and there is no None language in the map, return the string value of the concatenated list for English.

       Return a list of the strings, which can either be concatenated together or marked up in paragraphs.

       The 'orListLazy' method will return the first non-Nothing result and then pass that along. If the selected language
       is not English, but the English value was the first non-Nothing result, it means that we're using this as a
       fallback when no other values are available, so append an '<Untranslated>' string to the value to signify that
       it's not available in that language.
    -}
    ME.orListLazy
        [ \() -> LE.find (\(LanguageValues l _) -> l == lang) langMap
        , \() -> LE.find (\(LanguageValues l _) -> l == None) langMap
        , \() -> LE.find (\(LanguageValues l _) -> l == English) langMap
        ]
        |> Maybe.map
            (\(LanguageValues l v) ->
                if l == English && lang /= English then
                    List.map (\t -> t ++ " ❋") v

                else
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

        Portugese ->
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

    For display (e.g., the dropdown list) we just need
    a list of the languages that removes the type and
    filters out the 'none' value ('none' is used to indicate
    no declared linguistic content in the server response, but it's
    confusing if we show that to our users.)

-}
languageOptionsForDisplay : List ( String, String )
languageOptionsForDisplay =
    List.filterMap
        (\( l, n, _ ) ->
            if l /= "none" then
                Just ( l, n )

            else
                Nothing
        )
        languageOptions


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


englishLocale : Locale
englishLocale =
    { base
        | decimals = Max 2
        , thousandSeparator = ","
    }


extractLabelFromLanguageMapWithVariables : Language -> List LanguageMapReplacementVariable -> LanguageMap -> String
extractLabelFromLanguageMapWithVariables lang replacements langMap =
    extractTextFromLanguageMapWithVariables lang replacements langMap
        |> String.join ";"


extractTextFromLanguageMapWithVariables : Language -> List LanguageMapReplacementVariable -> LanguageMap -> List String
extractTextFromLanguageMapWithVariables lang replacements langMap =
    List.map
        (\inputString ->
            List.foldl
                (\replacementPattern currString ->
                    let
                        (LanguageMapReplacementVariable var val) =
                            replacementPattern
                    in
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


languageValuesDecoder : ( String, List String ) -> Decoder LanguageValues
languageValuesDecoder ( locale, translations ) =
    languageDecoder locale
        |> Decode.map (\lang -> LanguageValues lang translations)


{-|

    Takes a language type and returns the string representation,
    e.g., "en", "de", etc.

-}
parseLanguageToLocale : Language -> String
parseLanguageToLocale lang =
    -- it's unlikely that a language will get passed in that doesn't exist,
    -- but this will use English as the default language if that ever happens
    -- creates a new list with just the locale and language type, then filters
    LE.findMap
        (\( l, _, s ) ->
            if s == lang then
                Just l

            else
                Nothing
        )
        languageOptions
        |> Maybe.withDefault "en"


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


setLanguage : Language -> { a | language : Language } -> { a | language : Language }
setLanguage newValue oldRecord =
    { oldRecord | language = newValue }


spanishLocale : Locale
spanishLocale =
    { base
        | decimals = Max 3
        , thousandSeparator = "."
        , decimalSeparator = ","
    }
