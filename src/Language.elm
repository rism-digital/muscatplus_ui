module Language exposing
    ( Language(..)
    , LanguageMap
    , LanguageNumericMap
    , LanguageNumericValues(..)
    , LanguageValues(..)
    , extractLabelFromLanguageMap
    , extractTextFromLanguageMap
    , formatNumberByLanguage
    , languageDecoder
    , languageMapDecoder
    , languageNumericMapDecoder
    , languageOptions
    , languageOptionsForDisplay
    , languageValuesDecoder
    , localTranslations
    , parseLanguageToLocale
    , parseLocaleToLanguage
    )

import Dict exposing (Dict)
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Decimals(..), Locale, base, usLocale)
import Json.Decode as Decode exposing (Decoder)


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


{-|

    Used for cases where the values being decoded are numbers, not strings

-}
type LanguageNumericValues
    = LanguageNumericValues Language (List Int)


type alias LanguageMap =
    List LanguageValues


type alias LanguageNumericMap =
    List LanguageNumericValues


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

        chosenLangValues =
            case firstChoice of
                Just (LanguageValues _ t) ->
                    t

                Nothing ->
                    case fallback of
                        Just (LanguageValues _ t) ->
                            t

                        Nothing ->
                            lastResort
    in
    chosenLangValues


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


languageNumericValuesDecoder : ( String, List Int ) -> Decoder LanguageNumericValues
languageNumericValuesDecoder ( locale, translations ) =
    languageDecoder locale
        |> Decode.map (\lang -> LanguageNumericValues lang translations)


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


languageNumericMapDecoder : List ( String, List Int ) -> Decoder LanguageNumericMap
languageNumericMapDecoder json =
    List.foldl
        (\map maps -> Decode.map2 (::) (languageNumericValuesDecoder map) maps)
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
formatNumberByLanguage : Float -> Language -> String
formatNumberByLanguage num lang =
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


{-|

    Local translations that do not come from the server

-}
localTranslations :
    { search : List LanguageValues
    , home : List LanguageValues
    , queryEnter : List LanguageValues
    , next : List LanguageValues
    , previous : List LanguageValues
    , first : List LanguageValues
    , last : List LanguageValues
    , page : List LanguageValues
    , viewRecord : List LanguageValues
    }
localTranslations =
    { search =
        [ LanguageValues English [ "Search" ]
        , LanguageValues German [ "Suche" ]
        , LanguageValues French [ "Chercher" ]
        , LanguageValues Italian [ "Cerca" ]
        , LanguageValues Spanish [ "Búsqueda" ]
        , LanguageValues Portugese [ "Busca" ]
        , LanguageValues Polish [ "Wyszukiwanie" ]
        ]
    , home =
        [ LanguageValues English [ "Home" ]
        , LanguageValues German [ "Startseite" ]
        , LanguageValues French [ "Accueil" ]
        , LanguageValues Italian [ "Home" ]
        , LanguageValues Spanish [ "Página principal" ]
        , LanguageValues Portugese [ "Início" ]
        , LanguageValues Polish [ "Strona główna" ]
        ]
    , queryEnter =
        [ LanguageValues English [ "Enter your query" ]
        , LanguageValues German [ "Eingabe Ihrer Anfrage" ]
        , LanguageValues French [ "Entrez votre requête" ]
        , LanguageValues Italian [ "Inserisci la tua richiesta" ]
        , LanguageValues Spanish [ "Introduzca su consulta" ]
        , LanguageValues Portugese [ "Introduza a sua consulta" ]
        , LanguageValues Polish [ "Wprowadź swoje zapytanie" ]
        ]
    , next =
        [ LanguageValues English [ "Next" ]
        , LanguageValues German [ "Nächste" ]
        , LanguageValues French [ "Suivante" ]
        , LanguageValues Italian [ "Prossimo" ]
        , LanguageValues Spanish [ "Siguiente" ]
        , LanguageValues Portugese [ "Próximo" ]
        , LanguageValues Polish [ "Następny" ]
        ]
    , previous =
        [ LanguageValues English [ "Previous" ]
        , LanguageValues German [ "Vorige" ]
        , LanguageValues French [ "Précédent" ]
        , LanguageValues Italian [ "Precedente" ]
        , LanguageValues Spanish [ "Anterior" ]
        , LanguageValues Portugese [ "Anterior" ]
        , LanguageValues Polish [ "Poprzedni" ]
        ]
    , first =
        [ LanguageValues English [ "First" ]
        , LanguageValues German [ "Erste" ]
        , LanguageValues French [ "Première" ]
        , LanguageValues Italian [ "Primo" ]
        , LanguageValues Spanish [ "Primero" ]
        , LanguageValues Portugese [ "Primeiro" ]
        , LanguageValues Polish [ "Pierwszy" ]
        ]
    , last =
        [ LanguageValues English [ "Last" ]
        , LanguageValues German [ "Letzte" ]
        , LanguageValues French [ "Dernière" ]
        , LanguageValues Italian [ "Ultimo" ]
        , LanguageValues Spanish [ "Último" ]
        , LanguageValues Portugese [ "Último" ]
        , LanguageValues Polish [ "Ostatni" ]
        ]
    , page =
        [ LanguageValues English [ "Page" ]
        , LanguageValues German [ "Seite" ]
        , LanguageValues French [ "Page" ]
        , LanguageValues Italian [ "Pagina" ]
        , LanguageValues Spanish [ "Página" ]
        , LanguageValues Portugese [ "Página" ]
        , LanguageValues Polish [ "Strona" ]
        ]
    , viewRecord =
        -- TODO: Additional translations
        [ LanguageValues English [ "View full record" ]
        ]
    }
