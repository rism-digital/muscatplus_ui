module Language exposing (Language(..), LanguageMap, LanguageValues(..), extractLabelFromLanguageMap, parseLanguageToLocale, parseLocaleToLanguage)


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


parseLocaleToLanguage : String -> Language
parseLocaleToLanguage locale =
    -- defaults to English if no language is detected
    case locale of
        "en" ->
            English

        "de" ->
            German

        "fr" ->
            French

        "it" ->
            Italian

        "es" ->
            Spanish

        "pt" ->
            Portugese

        "pl" ->
            Polish

        "none" ->
            None

        _ ->
            English


parseLanguageToLocale : Language -> String
parseLanguageToLocale lang =
    case lang of
        English ->
            "en"

        German ->
            "de"

        French ->
            "fr"

        Italian ->
            "it"

        Spanish ->
            "es"

        Portugese ->
            "pt"

        Polish ->
            "pl"

        None ->
            "none"


extractLabelFromLanguageMap : Language -> LanguageMap -> String
extractLabelFromLanguageMap lang langMap =
    -- if there is a language value that matches one in the language map, return the string value of the concatenated list.
    -- if there is no language value that matches the language map, but there is a "None" language, return the string value of the concatenated list
    -- if there is no language value matching the language map, and there is no None language in the map, return the string value of the concatenated list for English.
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
    String.join "; " chosenLangValues
