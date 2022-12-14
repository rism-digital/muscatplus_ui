module Language.LocalTranslations exposing (errorMessages, facetPanelTitles, localTranslations)

{-|

    Local translations that do not come from the server

    Some values use string interpolation for providing additional information after
    translation.

-}

import Language exposing (Language(..), LanguageMap, LanguageValues(..))


localTranslations :
    { applyFiltersToUpdateResults : LanguageMap
    , description : LanguageMap
    , errorLoadingProbeResults : LanguageMap
    , first : LanguageMap
    , fullRecord : LanguageMap
    , globalCollection : LanguageMap
    , home : LanguageMap
    , incipits : LanguageMap
    , institutions : LanguageMap
    , keywordQuery : LanguageMap
    , last : LanguageMap
    , next : LanguageMap
    , noResultsBody : LanguageMap
    , noResultsHeader : LanguageMap
    , noResultsWouldBeFound : LanguageMap
    , page : LanguageMap
    , people : LanguageMap
    , previous : LanguageMap
    , wordsAnywhere : LanguageMap
    , recordPreview : LanguageMap
    , recordTop : LanguageMap
    , recordURI : LanguageMap
    , resetAll : LanguageMap
    , numberOfResults : LanguageMap
    , search : LanguageMap
    , searchNumberOfRecords : LanguageMap
    , showAllRecords : LanguageMap
    , showResults : LanguageMap
    , sourceContents : LanguageMap
    , sources : LanguageMap
    , updateResults : LanguageMap
    }
localTranslations =
    { applyFiltersToUpdateResults =
        [ LanguageValues English [ "Apply Filters" ]
        , LanguageValues German [ "Wenden Sie Filter an, um Suchergebnisse anzuzeigen" ]
        , LanguageValues French [ "Appliquer des filtres pour mettre à jour les résultats de recherche" ]
        , LanguageValues Italian [ "Applica filtri per aggiornare i risultati della ricerca" ]
        , LanguageValues Spanish [ "Aplicar filtros para actualizar los resultados de búsqueda" ]
        , LanguageValues Portugese [ "Aplicar filtros para atualizar os resultados da pesquisa" ]
        , LanguageValues Polish [ "Zastosuj filtry, aby zaktualizować wyniki wyszukiwania" ]
        ]
    , description =
        [ LanguageValues English [ "Description" ]
        , LanguageValues German [ "Beschreibung" ]
        , LanguageValues French [ "Description" ]
        , LanguageValues Italian [ "Descrizione" ]
        , LanguageValues Spanish [ "Decripción" ]
        , LanguageValues Portugese [ "Descrição" ]
        , LanguageValues Polish [ "Opis" ]
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
    , first =
        [ LanguageValues English [ "First" ]
        , LanguageValues German [ "Erste" ]
        , LanguageValues French [ "Première" ]
        , LanguageValues Italian [ "Primo" ]
        , LanguageValues Spanish [ "Primero" ]
        , LanguageValues Portugese [ "Primeiro" ]
        , LanguageValues Polish [ "Pierwszy" ]
        ]
    , fullRecord =
        [ LanguageValues English [ "Full Record" ]
        , LanguageValues German [ "Vollanzeige" ]
        , LanguageValues French [ "Enregistrement complet" ]
        , LanguageValues Italian [ "Scheda completa" ]
        , LanguageValues Spanish [ "Registro completo" ]
        , LanguageValues Portugese [ "Registro completo" ]
        , LanguageValues Polish [ "Globalna kolekcja" ]
        ]
    , globalCollection =
        [ LanguageValues English [ "Global collection" ]
        , LanguageValues German [ "Globale Sammlung" ]
        , LanguageValues French [ "Collecte mondiale" ]
        , LanguageValues Italian [ "Collezione globale" ]
        , LanguageValues Spanish [ "Colección mundial" ]
        , LanguageValues Portugese [ "Coleção global" ]
        , LanguageValues Polish [ "Pełny widok rekordu" ]
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
    , incipits =
        [ LanguageValues Spanish [ "Íncipits" ]
        , LanguageValues Portugese [ "Incipit" ]
        , LanguageValues German [ "Incipits" ]
        , LanguageValues Italian [ "Incipit" ]
        , LanguageValues Polish [ "Incipity" ]
        , LanguageValues English [ "Incipits" ]
        , LanguageValues French [ "Incipits" ]
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
    , keywordQuery =
        [ LanguageValues English [ "Keyword query" ]
        , LanguageValues Portugese [ "Consulta por palavra-chave" ]
        , LanguageValues German [ "Stichwortsuche" ]
        , LanguageValues Italian [ "Ricerca per parola chiave" ]
        , LanguageValues Polish [ "Zapytanie o słowo kluczowe" ]
        , LanguageValues French [ "Recherche par mot-clé" ]
        , LanguageValues Spanish [ "Consulta de palabra clave" ]
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
    , next =
        [ LanguageValues English [ "Next" ]
        , LanguageValues German [ "Nächste" ]
        , LanguageValues French [ "Suivante" ]
        , LanguageValues Italian [ "Prossimo" ]
        , LanguageValues Spanish [ "Siguiente" ]
        , LanguageValues Portugese [ "Próximo" ]
        , LanguageValues Polish [ "Następny" ]
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
    , noResultsHeader =
        [ LanguageValues English [ "No results were found for your search" ]
        , LanguageValues German [ "Es wurden keine Ergebnisse zu ihrer Suchanfrage gefunden" ]
        , LanguageValues French [ "Aucun résultat n'a été trouvé pour votre recherche" ]
        , LanguageValues Italian [ "Nessun risultato è stato trovato per la tua ricerca" ]
        , LanguageValues Spanish [ "No se encontraron resultados para tu búsqueda" ]
        , LanguageValues Portugese [ "Não foram encontrados resultados para a sua pesquisa" ]
        , LanguageValues Polish [ "Nie znaleziono wyników dla Twojego wyszukiwania" ]
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
    , page =
        [ LanguageValues English [ "Page" ]
        , LanguageValues German [ "Seite" ]
        , LanguageValues French [ "Page" ]
        , LanguageValues Italian [ "Pagina" ]
        , LanguageValues Spanish [ "Página" ]
        , LanguageValues Portugese [ "Página" ]
        , LanguageValues Polish [ "Strona" ]
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
    , previous =
        [ LanguageValues English [ "Previous" ]
        , LanguageValues German [ "Vorige" ]
        , LanguageValues French [ "Précédent" ]
        , LanguageValues Italian [ "Precedente" ]
        , LanguageValues Spanish [ "Anterior" ]
        , LanguageValues Portugese [ "Anterior" ]
        , LanguageValues Polish [ "Poprzedni" ]
        ]
    , wordsAnywhere =
        [ LanguageValues English [ "Words anywhere" ]
        , LanguageValues German [ "Eingabe Ihrer Anfrage" ]
        , LanguageValues French [ "Entrez votre requête" ]
        , LanguageValues Italian [ "Inserisci la tua richiesta" ]
        , LanguageValues Spanish [ "Introduzca su consulta" ]
        , LanguageValues Portugese [ "Introduza a sua consulta" ]
        , LanguageValues Polish [ "Wprowadź swoje zapytanie" ]
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
    , recordTop =
        [ LanguageValues English [ "Record top" ] ]
    , recordURI =
        [ LanguageValues English [ "Record URI (Permalink)" ]
        , LanguageValues German [ "URI des Datensatzes (Permalink)" ]
        , LanguageValues French [ "Record URI (Permalink)" ]
        , LanguageValues Italian [ "Link alla scheda (permalink)" ]
        , LanguageValues Spanish [ "Record URI (Permalink)" ]
        , LanguageValues Portugese [ "Record URI (Permalink)" ]
        , LanguageValues Polish [ "URI rekordu (Odnośnik bezpośredni)" ]
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
    , numberOfResults =
        [ LanguageValues English [ "Number of results" ]
        , LanguageValues German [ "Ergebnisse mit angewendeten Filtern" ]
        , LanguageValues French [ "Résultats avec filtres appliqués" ]
        , LanguageValues Italian [ "Risultati con filtri applicati" ]
        , LanguageValues Spanish [ "Resultados con filtros aplicados" ]
        , LanguageValues Portugese [ "Resultados com filtros aplicados" ]
        , LanguageValues Polish [ "Wyniki z zastosowanymi filtrami" ]
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
    , searchNumberOfRecords =
        [ LanguageValues English [ "Search {{ numberOfRecords }} {{ recordType }}" ] ]
    , showAllRecords =
        [ LanguageValues English [ "Show all results" ]
        , LanguageValues German [ "Alle Ergebnisse anzeigen" ]
        , LanguageValues French [ "Afficher tous les résultats" ]
        , LanguageValues Italian [ "Mostra tutti i risultati" ]
        , LanguageValues Spanish [ "Mostrar todos los resultados" ]
        , LanguageValues Portugese [ "Mostrar todos os resultados" ]
        , LanguageValues Polish [ "Wyświetl wszystkie wyniki" ]
        ]
    , showResults =
        [ LanguageValues English [ "Show search results" ]
        , LanguageValues German [ "Filter anwenden" ]
        , LanguageValues French [ "Appliquer des filtres" ]
        , LanguageValues Italian [ "Applicare filtri" ]
        , LanguageValues Spanish [ "Aplicar filtros" ]
        , LanguageValues Portugese [ "Aplicar filtros" ]
        , LanguageValues Polish [ "Zastosuj filtry" ]
        ]
    , sourceContents =
        [ LanguageValues English [ "Source contents" ]
        , LanguageValues German [ "Inhalt der Quelle" ]
        , LanguageValues French [ "Contenu de la source" ]
        , LanguageValues Italian [ "Contenuto delle fonti" ]
        , LanguageValues Polish [ "Treść źródła" ]
        , LanguageValues Portugese [ "Conteúdo da fonte" ]
        ]
    , sources =
        [ LanguageValues English [ "Sources" ]
        , LanguageValues German [ "Quellen" ]
        , LanguageValues French [ "Sources" ]
        , LanguageValues Italian [ "Fonti" ]
        , LanguageValues Spanish [ "Fuentes" ]
        , LanguageValues Portugese [ "Fontes" ]
        , LanguageValues Polish [ "Źródła" ]
        ]
    , updateResults =
        [ LanguageValues English [ "Update search results" ]
        , LanguageValues German [ "Filter anwenden" ]
        , LanguageValues French [ "Appliquer des filtres" ]
        , LanguageValues Italian [ "Applicare filtri" ]
        , LanguageValues Spanish [ "Aplicar filtros" ]
        , LanguageValues Portugese [ "Aplicar filtros" ]
        , LanguageValues Polish [ "Zastosuj filtry" ]
        ]
    }


facetPanelTitles :
    { results : LanguageMap
    , sourceRelationships : LanguageMap
    , holdingInstitutions : LanguageMap
    , digitizations : LanguageMap
    , sourceContents : LanguageMap
    , publicationDetails : LanguageMap
    , biographicalDetails : LanguageMap
    , roleAndProfession : LanguageMap
    , location : LanguageMap
    , clefKeyTime : LanguageMap
    , composerComposition : LanguageMap
    }
facetPanelTitles =
    { results =
        [ LanguageValues English [ "Result types" ]
        , LanguageValues German [ "Ergebnisarten" ]
        , LanguageValues French [ "Type du résultat" ]
        , LanguageValues Italian [ "Tipo di risultato" ]
        , LanguageValues Spanish [ "Tipo de resultado" ]
        , LanguageValues Portugese [ "Tipos de resultado" ]
        , LanguageValues Polish [ "Rodzaje wyników wyszukiwania" ]
        ]
    , sourceRelationships =
        [ LanguageValues English [ "Source relationships" ]
        , LanguageValues German [ "Quellen-Beziehungen" ]
        , LanguageValues French [ "Relation" ]
        , LanguageValues Italian [ "Relazioni tra fonti" ]
        , LanguageValues Spanish [ "Relaciones de resultado" ]
        , LanguageValues Portugese [ "Relações da fonte" ]
        , LanguageValues Polish [ "Relacje do źródła" ]
        ]
    , holdingInstitutions =
        [ LanguageValues English [ "Holding institutions" ]
        , LanguageValues German [ "Besitzende Institution" ]
        , LanguageValues French [ "Institution" ]
        , LanguageValues Italian [ "Dove trovarlo" ]
        , LanguageValues Spanish [ "Instituciones participantes" ]
        , LanguageValues Portugese [ "Responsabilidade das Instituições" ]
        , LanguageValues Polish [ "Instytucje przechowujące" ]
        ]
    , digitizations =
        [ LanguageValues English [ "Digital facsimiles" ]
        , LanguageValues German [ "Digitale Faksimiles" ]
        , LanguageValues French [ "Fac-similés numériques" ]
        , LanguageValues Italian [ "Facsimili digitali" ]
        , LanguageValues Spanish [ "Facsímiles digitales" ]
        , LanguageValues Portugese [ "Facsimiles digitais" ]
        , LanguageValues Polish [ "Cyfrowe faksymile" ]
        ]
    , sourceContents =
        [ LanguageValues English [ "Source contents" ]
        , LanguageValues German [ "Inhalt der Quelle" ]
        , LanguageValues French [ "Contenu de la source" ]
        , LanguageValues Italian [ "Contenuto delle fonti" ]
        , LanguageValues Spanish [ "Contenido de la fuente" ]
        , LanguageValues Portugese [ "Facsimiles digitais" ]
        , LanguageValues Polish [ "Conteúdo da fonte" ]
        ]
    , publicationDetails =
        [ LanguageValues English [ "Publication details" ]
        , LanguageValues German [ "Veröffentlichungsinformationen" ]
        , LanguageValues French [ "Détails de publication" ]
        , LanguageValues Italian [ "Pubblicazione" ]
        , LanguageValues Spanish [ "Detalles de publicación" ]
        , LanguageValues Portugese [ "Detalhes de Publicação" ]
        , LanguageValues Polish [ "Szczegóły publikacji" ]
        ]
    , biographicalDetails =
        [ LanguageValues English [ "Biographical details" ]
        , LanguageValues German [ "Biografische Details" ]
        , LanguageValues French [ "Détails biographiques" ]
        , LanguageValues Italian [ "Dati biografici" ]
        , LanguageValues Spanish [ "Detalles biográficos" ]
        , LanguageValues Portugese [ "Detalhes biográficos" ]
        , LanguageValues Polish [ "Szczegóły bibliograficzne" ]
        ]
    , roleAndProfession =
        [ LanguageValues English [ "Role and profession" ]
        , LanguageValues German [ "Funktion und Beruf" ]
        , LanguageValues French [ "Rôle et profession" ]
        , LanguageValues Italian [ "Ruolo e professione" ]
        , LanguageValues Spanish [ "Función y profesión" ]
        , LanguageValues Portugese [ "Cargo e profissão" ]
        , LanguageValues Polish [ "Funkcja i zawód" ]
        ]
    , location =
        [ LanguageValues English [ "Location" ]
        , LanguageValues German [ "Ort" ]
        , LanguageValues Spanish [ "Lugar" ]
        , LanguageValues French [ "Lieu" ]
        , LanguageValues Italian [ "Luogo" ]
        , LanguageValues Polish [ "Lokalizacja" ]
        , LanguageValues Portugese [ "Local" ]
        ]
    , clefKeyTime =
        [ LanguageValues English [ "Clef, key signature, time signature" ] ]
    , composerComposition =
        [ LanguageValues English [ "Composer and composition" ] ]
    }


errorMessages :
    { notFound : LanguageMap
    , badQuery : LanguageMap
    }
errorMessages =
    { notFound =
        [ LanguageValues English [ "The page was not found" ] ]
    , badQuery =
        [ LanguageValues English [ "There was a problem with the query" ] ]
    }
