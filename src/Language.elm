module Language exposing
    ( Language(..)
    , LanguageMap
    , LanguageValues(..)
    , dateFormatter
    , extractLabelFromLanguageMap
    , extractTextFromLanguageMap
    , formatNumberByLanguage
    , languageMapDecoder
    , languageOptionsForDisplay
    , parseLocaleToLanguage
    , setLanguage
    )

import DateFormat
import Dict
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Decimals(..), Locale, base)
import Json.Decode as Decode exposing (Decoder)
import Time exposing (Posix, Zone)


type Language
    = English
    | French
    | German
    | Italian
    | Portugese
    | Spanish
    | Polish
    | None


type LanguageValues
    = LanguageValues Language (List String)


type alias LanguageMap =
    List LanguageValues


setLanguage : Language -> { a | language : Language } -> { a | language : Language }
setLanguage newValue oldRecord =
    { oldRecord | language = newValue }


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


{-|

    For display (e.g., the dropdown list) we just need
    a list of the languages that removes the type and
    filters out the 'none' value ('none' is used to indicate
    no declared linguistic content in the server response, but it's
    confusing if we show that to our users.)

-}
languageOptionsForDisplay : List ( String, String )
languageOptionsForDisplay =
    List.map (\( l, n, _ ) -> ( l, n )) languageOptions
        |> List.filter (\( l, _ ) -> l /= "none")


{-|

    Takes a string and returns the corresponding language type, e.g.,
    "en" -> English.

-}
parseLocaleToLanguage : String -> Language
parseLocaleToLanguage locale =
    -- defaults to English if no language is detected
    List.map (\( l, _, s ) -> ( l, s )) languageOptions
        |> Dict.fromList
        |> Dict.get locale
        |> Maybe.withDefault English


{-|

    Takes a language type and returns the string representation,
    e.g., "en", "de", etc.

-}
parseLanguageToLocale : Language -> String
parseLanguageToLocale lang =
    -- it's unlikely that a language will get passed in that doesn't exist,
    -- but this will use English as the default language if that ever happens
    -- creates a new list with just the locale and language type, then filters
    List.map (\( l, _, s ) -> ( l, s )) languageOptions
        |> List.filter (\( _, sym ) -> sym == lang)
        |> List.head
        |> Maybe.withDefault ( "en", English )
        |> Tuple.first


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
    -}
    let
        firstChoice =
            langMap
                |> List.filter (\(LanguageValues l _) -> l == lang)
                |> List.head

        fallback =
            langMap
                |> List.filter (\(LanguageValues l _) -> l == None)
                |> List.head

        lastResort =
            [ "[No language value found]" ]
    in
    case firstChoice of
        Just (LanguageValues _ t) ->
            t

        Nothing ->
            case fallback of
                Just (LanguageValues _ t) ->
                    t

                Nothing ->
                    lastResort


languageDecoder : String -> Decoder Language
languageDecoder locale =
    let
        lang =
            parseLocaleToLanguage locale
    in
    Decode.succeed lang


languageValuesDecoder : ( String, List String ) -> Decoder LanguageValues
languageValuesDecoder ( locale, translations ) =
    languageDecoder locale
        |> Decode.map (\lang -> LanguageValues lang translations)


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


englishLocale : Locale
englishLocale =
    { base
        | decimals = Max 2
        , thousandSeparator = ","
    }


germanLocale : Locale
germanLocale =
    { base
        | decimals = Max 2
        , thousandSeparator = "."
        , decimalSeparator = ","
    }


frenchLocale : Locale
frenchLocale =
    { base
        | decimals = Max 3
        , thousandSeparator = "\u{202F}"
        , decimalSeparator = ","
    }


polishLocale : Locale
polishLocale =
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


portugeseLocale : Locale
portugeseLocale =
    { base
        | decimals = Max 3
        , thousandSeparator = "\u{202F}"
        , decimalSeparator = ","
    }


italianLocale : Locale
italianLocale =
    { base
        | decimals = Max 2
        , thousandSeparator = "."
        , decimalSeparator = ","
    }


{-|

    Formats a number according to a particular regional locale.
    Returns a string corresponding to the formatted number.

-}
formatNumberByLanguage : Language -> Float -> String
formatNumberByLanguage lang num =
    let
        formatterLocale =
            case lang of
                English ->
                    englishLocale

                German ->
                    germanLocale

                French ->
                    frenchLocale

                Italian ->
                    italianLocale

                Spanish ->
                    spanishLocale

                Portugese ->
                    portugeseLocale

                Polish ->
                    polishLocale

                None ->
                    englishLocale
    in
    format formatterLocale num



-- DATE FORMATTING
-- TODO: Change this to work with languages


dateFormatter : Zone -> Posix -> String
dateFormatter =
    DateFormat.format
        [ DateFormat.monthNameFull
        , DateFormat.text " "
        , DateFormat.dayOfMonthSuffix
        , DateFormat.text ", "
        , DateFormat.yearNumber
        ]
