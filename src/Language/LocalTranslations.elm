module Language.LocalTranslations exposing (..)

{-|

    Local translations that do not come from the server

    Some values use string interpolation for providing additional information after
    translation.

-}

import Language exposing (Language(..), LanguageValues(..))


localTranslations :
    { sources : List LanguageValues
    , people : List LanguageValues
    , institutions : List LanguageValues
    , incipits : List LanguageValues
    , search : List LanguageValues
    , home : List LanguageValues
    , keywordQuery : List LanguageValues
    , searchNumberOfRecords : List LanguageValues
    , queryEnter : List LanguageValues
    , next : List LanguageValues
    , previous : List LanguageValues
    , first : List LanguageValues
    , last : List LanguageValues
    , page : List LanguageValues
    , recordPreview : List LanguageValues
    , viewRecord : List LanguageValues
    , viewSourceRecord : List LanguageValues
    , recordURI : List LanguageValues
    , recordTop : List LanguageValues
    , applyFilters : List LanguageValues
    , resetAll : List LanguageValues
    , globalCollection : List LanguageValues
    , noResultsHeader : List LanguageValues
    , noResultsBody : List LanguageValues
    , resultsWithFilters : List LanguageValues
    , errorLoadingProbeResults : List LanguageValues
    , applyFiltersToUpdateResults : List LanguageValues
    , noResultsWouldBeFound : List LanguageValues
    }
localTranslations =
    { sources =
        [ LanguageValues English [ "Sources" ]
        , LanguageValues German [ "Quellen" ]
        , LanguageValues French [ "Sources" ]
        , LanguageValues Italian [ "Fonti" ]
        , LanguageValues Spanish [ "Fuentes" ]
        , LanguageValues Portugese [ "Fontes" ]
        , LanguageValues Polish [ "Źródła" ]
        ]
    , people =
        [ LanguageValues Spanish [ "Personas" ]
        , LanguageValues Portugese [ "Pessoas" ]
        , LanguageValues German [ "Personen" ]
        , LanguageValues Italian [ "Persone" ]
        , LanguageValues Polish [ "Osoby" ]
        , LanguageValues English [ "People" ]
        , LanguageValues French [ "Personnes" ]
        ]
    , institutions =
        [ LanguageValues Spanish [ "Instituciones" ]
        , LanguageValues Portugese [ "Instituições" ]
        , LanguageValues German [ "Körperschaften" ]
        , LanguageValues Italian [ "Istituzioni" ]
        , LanguageValues Polish [ "Instytucje" ]
        , LanguageValues English [ "Institutions" ]
        , LanguageValues French [ "Institution" ]
        ]
    , incipits =
        [ LanguageValues Spanish [ "Íncipits" ]
        , LanguageValues Portugese [ "Incipit" ]
        , LanguageValues German [ "Incipits" ]
        , LanguageValues Italian [ "Incipit" ]
        , LanguageValues Polish [ "Incipity" ]
        , LanguageValues English [ "Incipits" ]
        , LanguageValues French [ "Incipits" ]
        ]
    , search =
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
    , recordPreview =
        [ LanguageValues English [ "Record preview" ]
        , LanguageValues German [ "Dokumentvorschau" ]
        , LanguageValues French [ "Aperçu de la notice" ]
        , LanguageValues Italian [ "Anteprima la scheda" ]
        , LanguageValues Spanish [ "Vista previa del registro" ]
        , LanguageValues Portugese [ "Visualizar do registro" ]
        , LanguageValues Polish [ "Zapowiedź rekordu" ]
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
        [ LanguageValues English [ "Apply filters" ]
        , LanguageValues German [ "Filter anwenden" ]
        , LanguageValues French [ "Appliquer des filtres" ]
        , LanguageValues Italian [ "Applicare filtri" ]
        , LanguageValues Spanish [ "Aplicar filtros" ]
        , LanguageValues Portugese [ "Aplicar filtros" ]
        , LanguageValues Polish [ "Zastosuj filtry" ]
        ]
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
    , resultsWithFilters =
        [ LanguageValues English [ "Results with filters applied" ]
        , LanguageValues German [ "Ergebnisse mit angewendeten Filtern" ]
        , LanguageValues French [ "Résultats avec filtres appliqués" ]
        , LanguageValues Italian [ "Risultati con filtri applicati" ]
        , LanguageValues Spanish [ "Resultados con filtros aplicados" ]
        , LanguageValues Portugese [ "Resultados com filtros aplicados" ]
        , LanguageValues Polish [ "Wyniki z zastosowanymi filtrami" ]
        ]
    , errorLoadingProbeResults =
        [ LanguageValues English [ "Error loading results" ]
        , LanguageValues German [ "Fehler beim Laden der Ergebnisse" ]
        , LanguageValues French [ "Erreur lors du chargement des résultats" ]
        , LanguageValues Italian [ "Errore durante il caricamento dei risultati" ]
        , LanguageValues Spanish [ "Error al cargar resultados" ]
        , LanguageValues Portugese [ "Erro ao carregar os resultados" ]
        , LanguageValues Polish [ "Błąd podczas ładowania wyników" ]
        ]
    , applyFiltersToUpdateResults =
        [ LanguageValues English [ "Apply filters to update search results" ]
        , LanguageValues German [ "Wenden Sie Filter an, um die Suchergebnisse zu aktualisieren" ]
        , LanguageValues French [ "Appliquer des filtres pour mettre à jour les résultats de recherche" ]
        , LanguageValues Italian [ "Applica filtri per aggiornare i risultati della ricerca" ]
        , LanguageValues Spanish [ "Aplicar filtros para actualizar los resultados de búsqueda" ]
        , LanguageValues Portugese [ "Aplicar filtros para atualizar os resultados da pesquisa" ]
        , LanguageValues Polish [ "Zastosuj filtry, aby zaktualizować wyniki wyszukiwania" ]
        ]
    , noResultsWouldBeFound =
        [ LanguageValues English [ "No results would be found with this search" ]
        , LanguageValues German [ "Bei dieser Suche würden keine Ergebnisse gefunden" ]
        , LanguageValues French [ "Aucun résultat ne sera trouvé avec cette recherche" ]
        , LanguageValues Italian [ "Nessun risultato verrebbe trovato con questa ricerca" ]
        , LanguageValues Spanish [ "No se encontrarían resultados con esta búsqueda" ]
        , LanguageValues Portugese [ "Nenhum resultado seria encontrado com esta pesquisa" ]
        , LanguageValues Polish [ "W tym wyszukiwaniu nie zostaną znalezione żadne wyniki" ]
        ]
    }
