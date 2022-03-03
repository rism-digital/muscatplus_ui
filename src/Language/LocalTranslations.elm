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
    , viewSourceRecord : List LanguageValues
    , recordURI : List LanguageValues
    , recordTop : List LanguageValues
    , applyFilters : List LanguageValues
    , resetAll : List LanguageValues
    , globalCollection : List LanguageValues
    , noResultsHeader : List LanguageValues
    , noResultsBody : List LanguageValues
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
    , viewSourceRecord =
        -- TODO: Additional translations
        [ LanguageValues English [ "View source record" ]
        ]
    , recordURI =
        [ LanguageValues English [ "Record URI (Permalink)" ] ]
    , recordTop =
        [ LanguageValues English [ "Record top" ] ]
    , applyFilters =
        [ LanguageValues English [ "Apply filters" ] ]
    , resetAll =
        [ LanguageValues English [ "Reset all" ]
        , LanguageValues German [ "Alles zurücksetzen" ]
        , LanguageValues French [ "Effacer tout" ]
        , LanguageValues Italian [ "Resetta tutto" ]
        , LanguageValues Spanish [ "Resetear todo" ]
        , LanguageValues Portugese [ "Reiniciar tudo" ]
        , LanguageValues Polish [ "Zresetować wszystko" ]
        ]
    , globalCollection =
        [ LanguageValues English [ "Global collection" ]
        , LanguageValues German [ "Globale Sammlung" ]
        , LanguageValues French [ "Collecte mondiale" ]
        , LanguageValues Italian [ "Collezione globale" ]
        , LanguageValues Spanish [ "Colección mundial" ]
        , LanguageValues Portugese [ "Coleção global" ]
        , LanguageValues Polish [ "Globalna kolekcja" ]
        ]
    , noResultsHeader =
        [ LanguageValues English [ "No results were found for your search" ]
        , LanguageValues German [ "Es wurden keine Ergebnisse zu ihrer Suchanfrage gefunden" ]
        , LanguageValues French [ "Aucun résultat n'a été trouvé pour votre recherche" ]
        , LanguageValues Italian [ "Nessun risultato è stato trovato per la tua ricerca" ]
        , LanguageValues Spanish [ "No se encontraron resultados para tu búsqueda" ]
        , LanguageValues Portugese [ "Não foram encontrados resultados para a sua pesquisa" ]
        , LanguageValues Polish [ "Nie znaleziono wyników dla Twojego wyszukiwania" ]
        ]
    , noResultsBody =
        [ LanguageValues English [ "Adjust your query options, or reset all filters, to see results." ]
        , LanguageValues German [ "Passen Sie Ihre Abfrageoptionen an oder setzen Sie alle Filter zurück, um Ergebnisse anzuzeigen." ]
        , LanguageValues French [ "Ajustez vos options de requête ou réinitialisez tous les filtres pour voir les résultats." ]
        , LanguageValues Italian [ "Modifica le opzioni di query o reimposta tutti i filtri per visualizzare i risultati." ]
        , LanguageValues Spanish [ "Ajuste sus opciones de consulta o restablezca todos los filtros para ver los resultados." ]
        , LanguageValues Portugese [ "Ajuste suas opções de consulta ou redefina todos os filtros para ver os resultados." ]
        , LanguageValues Polish [ "Dostosuj opcje zapytania lub zresetuj wszystkie filtry, aby zobaczyć wyniki." ]
        ]
    }
