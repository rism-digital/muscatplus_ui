module Language.LocalTranslations exposing (..)

{-|

    Local translations that do not come from the server

    Some values use string interpolation for providing additional information after
    translation.

-}

import Language exposing (Language(..), LanguageValues(..))


localTranslations :
    { search : List LanguageValues
    , home : List LanguageValues
    , keywordQuery : List LanguageValues
    , searchNumberOfRecords : List LanguageValues
    , queryEnter : List LanguageValues
    , next : List LanguageValues
    , previous : List LanguageValues
    , first : List LanguageValues
    , last : List LanguageValues
    , page : List LanguageValues
    , viewRecord : List LanguageValues
    , recordURI : List LanguageValues
    , recordTop : List LanguageValues
    , applyFilters : List LanguageValues
    , resetAll : List LanguageValues
    , globalCollection : List LanguageValues
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
    , keywordQuery =
        [ LanguageValues English [ "Keyword query" ]
        ]
    , searchNumberOfRecords =
        [ LanguageValues English [ "Search {{ numberOfRecords }} {{ recordType }}" ] ]
    , queryEnter =
        [ LanguageValues English [ "Words anywhere" ]
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
    , recordURI =
        [ LanguageValues English [ "Record URI (Permalink)" ] ]
    , recordTop =
        [ LanguageValues English [ "Record top" ] ]
    , applyFilters =
        [ LanguageValues English [ "Apply filters" ] ]
    , resetAll =
        [ LanguageValues English [ "Reset all" ] ]
    , globalCollection =
        [ LanguageValues English [ "Global collection" ] ]
    }
