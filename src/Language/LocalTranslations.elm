module Language.LocalTranslations exposing (errorMessages, facetPanelTitles, localTranslations)

{-|

    Local translations that do not come from the server

    Some values use string interpolation for providing additional information after
    translation.

-}

import Language exposing (Language(..), LanguageMap, LanguageValues(..))


localTranslations :
    { about : LanguageMap
    , addTermsToQuery : LanguageMap
    , additionalFilters : LanguageMap
    , applyFiltersToUpdateResults : LanguageMap
    , chooseCollection : LanguageMap
    , collapse : LanguageMap
    , description : LanguageMap
    , downloadMEI : LanguageMap
    , downloadPNG : LanguageMap
    , errorLoadingProbeResults : LanguageMap
    , first : LanguageMap
    , fullRecord : LanguageMap
    , globalCollection : LanguageMap
    , hasDigitization : LanguageMap
    , hasIIIFManifest : LanguageMap
    , hasIncipits : LanguageMap
    , heldBy : LanguageMap
    , home : LanguageMap
    , incipitSearchHelpHide : LanguageMap
    , incipitSearchHelpShow : LanguageMap
    , incipits : LanguageMap
    , institution : LanguageMap
    , institutions : LanguageMap
    , keywordQuery : LanguageMap
    , last : LanguageMap
    , liturgicalFeasts : LanguageMap
    , location : LanguageMap
    , muscatEdit : LanguageMap
    , muscatView : LanguageMap
    , nearbyInstitutions : LanguageMap
    , newSearchWithIncipit : LanguageMap
    , next : LanguageMap
    , noResultsBody : LanguageMap
    , noResultsHeader : LanguageMap
    , noResultsWouldBeFound : LanguageMap
    , notationQueryLength : LanguageMap
    , numberOfResults : LanguageMap
    , optionsWithAnd : LanguageMap
    , optionsWithOr : LanguageMap
    , orChooseCollection : LanguageMap
    , paeInput : LanguageMap
    , page : LanguageMap
    , partOf : LanguageMap
    , partOfCollection : LanguageMap
    , people : LanguageMap
    , person : LanguageMap
    , place : LanguageMap
    , previous : LanguageMap
    , queryTerms : LanguageMap
    , recordPreview : LanguageMap
    , recordTop : LanguageMap
    , recordURI : LanguageMap
    , reportAnIssue : LanguageMap
    , resetAll : LanguageMap
    , rowsPerPage : LanguageMap
    , search : LanguageMap
    , searchNumberOfRecords : LanguageMap
    , seeAll : LanguageMap
    , showAllRecords : LanguageMap
    , showNumItems : LanguageMap
    , showResults : LanguageMap
    , sortAlphabetically : LanguageMap
    , sortBy : LanguageMap
    , sortByCount : LanguageMap
    , source : LanguageMap
    , sourceContents : LanguageMap
    , sources : LanguageMap
    , unknownError : LanguageMap
    , updateResults : LanguageMap
    , viewImages : LanguageMap
    , wordsAnywhere : LanguageMap
    }
localTranslations =
    { about =
        [ LanguageValues English [ "About RISM Online" ] ]
    , addTermsToQuery =
        [ LanguageValues English [ "Add terms to your query" ] ]
    , additionalFilters =
        [ LanguageValues English [ "Additional filters" ] ]
    , applyFiltersToUpdateResults =
        [ LanguageValues English [ "Apply filters" ]
        , LanguageValues German [ "Filter anwenden" ]
        , LanguageValues French [ "Appliquer les filtres" ]
        , LanguageValues Italian [ "Applica filtri" ]
        , LanguageValues Spanish [ "Aplicar filtros" ]
        , LanguageValues Portugese [ "Aplicar filtros" ]
        , LanguageValues Polish [ "Zastosuj filtry" ]
        ]
    , chooseCollection =
        [ LanguageValues English [ "Choose a collection to search" ] ]
    , collapse =
        [ LanguageValues English [ "Collapse" ] ]
    , description =
        [ LanguageValues English [ "Description" ]
        , LanguageValues German [ "Beschreibung" ]
        , LanguageValues French [ "Description" ]
        , LanguageValues Italian [ "Descrizione" ]
        , LanguageValues Spanish [ "Decripción" ]
        , LanguageValues Portugese [ "Descrição" ]
        , LanguageValues Polish [ "Opis" ]
        ]
    , downloadMEI =
        [ LanguageValues English [ "Download MEI" ] ]
    , downloadPNG =
        [ LanguageValues English [ "Download PNG" ] ]
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
    , hasDigitization =
        [ LanguageValues English [ "Has digitization" ] ]
    , hasIIIFManifest =
        [ LanguageValues English [ "Has IIIF manifest" ] ]
    , hasIncipits =
        [ LanguageValues English [ "Has incipits" ] ]
    , heldBy =
        [ LanguageValues English [ "Held by" ] ]
    , home =
        [ LanguageValues English [ "Home" ]
        , LanguageValues German [ "Startseite" ]
        , LanguageValues French [ "Accueil" ]
        , LanguageValues Italian [ "Home" ]
        , LanguageValues Spanish [ "Página principal" ]
        , LanguageValues Portugese [ "Início" ]
        , LanguageValues Polish [ "Strona główna" ]
        ]
    , incipitSearchHelpHide =
        [ LanguageValues English [ "Hide Incipit Search Help" ] ]
    , incipitSearchHelpShow =
        [ LanguageValues English [ "Show Incipit Search Help" ] ]
    , incipits =
        [ LanguageValues Spanish [ "Íncipits" ]
        , LanguageValues Portugese [ "Incipit" ]
        , LanguageValues German [ "Incipits" ]
        , LanguageValues Italian [ "Incipit" ]
        , LanguageValues Polish [ "Incipity" ]
        , LanguageValues English [ "Incipits" ]
        , LanguageValues French [ "Incipits" ]
        ]
    , institution =
        [ LanguageValues English [ "Institution" ] ]
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
    , liturgicalFeasts = []
    , location =
        [ LanguageValues English [ "Location" ]
        , LanguageValues German [ "Ort" ]
        , LanguageValues French [ "Lieu" ]
        , LanguageValues Italian [ "Luogo" ]
        , LanguageValues Spanish [ "Lugar" ]
        , LanguageValues Portugese [ "Local" ]
        , LanguageValues Polish [ "Lokalizacja" ]
        ]
    , muscatEdit =
        [ LanguageValues English [ "Edit" ] ]
    , muscatView =
        [ LanguageValues English [ "View" ] ]
    , nearbyInstitutions =
        [ LanguageValues English [ "Nearby institutions" ]
        , LanguageValues German [ "Nahegelegene Körperschaften" ]
        , LanguageValues French [ "Institutions proches" ]
        , LanguageValues Italian [ "Istituzioni vicine" ]
        , LanguageValues Spanish [ "Instituciones cercanas" ]
        , LanguageValues Portugese [ "Instituições próximas" ]
        , LanguageValues Polish [ "Pobliskie instytucje" ]
        ]
    , newSearchWithIncipit =
        [ LanguageValues English [ "Search for incipits like this" ] ]
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
        , LanguageValues German [ "Passen Sie Ihre Abfrageoptionen an oder setzen Sie alle Filter zurück, um Ergebnisse zu sehen." ]
        , LanguageValues French [ "Ajustez vos options de requête, ou réinitialisez tous les filtres, pour voir les résultats." ]
        , LanguageValues Italian [ "Modifica le opzioni di ricerca o ripristina tutti i filtri per visualizzare nuovi risultati." ]
        , LanguageValues Spanish [ "Ajuste las opciones de consulta, o reinicie todos los filtros, para ver resultados." ]
        , LanguageValues Portugese [ "Ajuste as opções de sua consulta ou redefina todos os filtros para ver os resultados." ]
        , LanguageValues Polish [ "Dostosuj opcje zapytania lub zresetuj wszystkie filtry, aby zobaczyć wyniki." ]
        ]
    , noResultsHeader =
        [ LanguageValues English [ "No results were found for your search" ]
        , LanguageValues German [ "Keine Suchergebnisse gefunden" ]
        , LanguageValues French [ "Aucun résultat trouvé" ]
        , LanguageValues Italian [ "Questa ricerca non produce alcun risultato" ]
        , LanguageValues Spanish [ "No se encontraron resultados con esta búsqueda" ]
        , LanguageValues Portugese [ "Nenhum resultado será encontrado para esta pesquisa" ]
        , LanguageValues Polish [ "Nie znaleziono wyników dla Twojego wyszukiwania" ]
        ]
    , noResultsWouldBeFound =
        [ LanguageValues English [ "No results would be found with this search" ]
        , LanguageValues German [ "Diese Suche brachte keine Ergebnisse" ]
        , LanguageValues French [ "Aucun résultat pour cette recherche" ]
        , LanguageValues Italian [ "Nessun risultato verrebbe trovato con questa ricerca" ]
        , LanguageValues Spanish [ "No se encontrarían resultados con esta búsqueda" ]
        , LanguageValues Portugese [ "Nenhum resultado seria encontrado com esta pesquisa" ]
        , LanguageValues Polish [ "Nie znaleziono żadnych wyników dla tego wyszukiwania" ]
        ]
    , notationQueryLength =
        [ LanguageValues English [ "Queries must be longer than three notes" ] ]
    , numberOfResults =
        [ LanguageValues English [ "Number of results" ]
        , LanguageValues German [ "Ergebnisse mit angewendeten Filtern" ]
        , LanguageValues French [ "Résultats avec filtres appliqués" ]
        , LanguageValues Italian [ "Risultati con filtri applicati" ]
        , LanguageValues Spanish [ "Resultados con filtros aplicados" ]
        , LanguageValues Portugese [ "Resultados com filtros aplicados" ]
        , LanguageValues Polish [ "Wyniki z zastosowanymi filtrami" ]
        ]
    , optionsWithAnd =
        [ LanguageValues English [ "Options are combined with an AND operator" ] ]
    , optionsWithOr =
        [ LanguageValues English [ "Options are combined with an OR operator" ] ]
    , orChooseCollection =
        [ LanguageValues English [ "Or choose a national collection" ] ]
    , paeInput =
        [ LanguageValues English [ "Plaine and Easie Input" ] ]
    , page =
        [ LanguageValues English [ "Page" ]
        , LanguageValues German [ "Seite" ]
        , LanguageValues French [ "Page" ]
        , LanguageValues Italian [ "Pagina" ]
        , LanguageValues Spanish [ "Página" ]
        , LanguageValues Portugese [ "Página" ]
        , LanguageValues Polish [ "Strona" ]
        ]
    , partOf =
        [ LanguageValues English [ "Part of" ] ]
    , partOfCollection =
        [ LanguageValues English [ "This record is part of a collection" ] ]
    , people =
        [ LanguageValues Spanish [ "Personas" ]
        , LanguageValues Portugese [ "Pessoas" ]
        , LanguageValues German [ "Personen" ]
        , LanguageValues Italian [ "Persone" ]
        , LanguageValues Polish [ "Osoby" ]
        , LanguageValues English [ "People" ]
        , LanguageValues French [ "Personnes" ]
        ]
    , person =
        [ LanguageValues English [ "Person" ] ]
    , place =
        [ LanguageValues English [ "Place" ] ]
    , previous =
        [ LanguageValues English [ "Previous" ]
        , LanguageValues German [ "Vorige" ]
        , LanguageValues French [ "Précédent" ]
        , LanguageValues Italian [ "Precedente" ]
        , LanguageValues Spanish [ "Anterior" ]
        , LanguageValues Portugese [ "Anterior" ]
        , LanguageValues Polish [ "Poprzedni" ]
        ]
    , queryTerms =
        [ LanguageValues English [ "Query terms" ] ]
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
    , reportAnIssue =
        [ LanguageValues English [ "Report an issue" ] ]
    , resetAll =
        [ LanguageValues English [ "Reset all" ]
        , LanguageValues German [ "Alles zurücksetzen" ]
        , LanguageValues French [ "Effacer tout" ]
        , LanguageValues Italian [ "Resetta tutto" ]
        , LanguageValues Spanish [ "Resetear todo" ]
        , LanguageValues Portugese [ "Reiniciar tudo" ]
        , LanguageValues Polish [ "Zresetować wszystko" ]
        ]
    , rowsPerPage =
        [ LanguageValues English [ "Rows per page" ] ]
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
    , seeAll =
        [ LanguageValues English [ "See all" ] ]
    , showAllRecords =
        [ LanguageValues English [ "Show all results" ]
        , LanguageValues German [ "Alle Ergebnisse anzeigen" ]
        , LanguageValues French [ "Afficher tous les résultats" ]
        , LanguageValues Italian [ "Mostra tutti i risultati" ]
        , LanguageValues Spanish [ "Mostrar todos los resultados" ]
        , LanguageValues Portugese [ "Mostrar todos os resultados" ]
        , LanguageValues Polish [ "Wyświetl wszystkie wyniki" ]
        ]
    , showNumItems =
        [ LanguageValues English [ "Show {{ numItems }} items" ] ]
    , showResults =
        [ LanguageValues English [ "Show search results" ]
        , LanguageValues German [ "Filter anwenden" ]
        , LanguageValues French [ "Appliquer des filtres" ]
        , LanguageValues Italian [ "Applicare filtri" ]
        , LanguageValues Spanish [ "Aplicar filtros" ]
        , LanguageValues Portugese [ "Aplicar filtros" ]
        , LanguageValues Polish [ "Zastosuj filtry" ]
        ]
    , sortAlphabetically =
        [ LanguageValues English [ "Sort alphabetically (currently sorted by count)" ] ]
    , sortBy =
        [ LanguageValues English [ "Sort by" ] ]
    , sortByCount =
        [ LanguageValues English [ "Sort by count (currently sorted alphabetically)" ] ]
    , source =
        [ LanguageValues English [ "Source" ] ]
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
    , unknownError =
        [ LanguageValues English [ "An unknown error occurred." ] ]
    , updateResults =
        [ LanguageValues English [ "Update search results" ]
        , LanguageValues German [ "Filter anwenden" ]
        , LanguageValues French [ "Appliquer des filtres" ]
        , LanguageValues Italian [ "Applicare filtri" ]
        , LanguageValues Spanish [ "Aplicar filtros" ]
        , LanguageValues Portugese [ "Aplicar filtros" ]
        , LanguageValues Polish [ "Zastosuj filtry" ]
        ]
    , viewImages =
        [ LanguageValues English [ "View images" ] ]
    , wordsAnywhere =
        [ LanguageValues English [ "Words anywhere" ]
        , LanguageValues German [ "Eingabe Ihrer Anfrage" ]
        , LanguageValues French [ "Entrez votre requête" ]
        , LanguageValues Italian [ "Inserisci la tua richiesta" ]
        , LanguageValues Spanish [ "Introduzca su consulta" ]
        , LanguageValues Portugese [ "Introduza a sua consulta" ]
        , LanguageValues Polish [ "Wprowadź swoje zapytanie" ]
        ]
    }


facetPanelTitles :
    { biographicalDetails : LanguageMap
    , clefKeyTime : LanguageMap
    , composerComposition : LanguageMap
    , digitizations : LanguageMap
    , holdingInstitutions : LanguageMap
    , location : LanguageMap
    , publicationDetails : LanguageMap
    , results : LanguageMap
    , roleAndProfession : LanguageMap
    , sourceContents : LanguageMap
    , sourceRelationships : LanguageMap
    }
facetPanelTitles =
    { biographicalDetails =
        [ LanguageValues English [ "Biographical details" ]
        , LanguageValues German [ "Biografische Details" ]
        , LanguageValues French [ "Détails biographiques" ]
        , LanguageValues Italian [ "Dati biografici" ]
        , LanguageValues Spanish [ "Detalles biográficos" ]
        , LanguageValues Portugese [ "Detalhes biográficos" ]
        , LanguageValues Polish [ "Szczegóły bibliograficzne" ]
        ]
    , clefKeyTime =
        [ LanguageValues English [ "Clef, key signature, time signature" ] ]
    , composerComposition =
        [ LanguageValues English [ "Composer and composition" ] ]
    , digitizations =
        [ LanguageValues English [ "Digital facsimiles" ]
        , LanguageValues German [ "Digitale Faksimiles" ]
        , LanguageValues French [ "Fac-similés numériques" ]
        , LanguageValues Italian [ "Facsimili digitali" ]
        , LanguageValues Spanish [ "Facsímiles digitales" ]
        , LanguageValues Portugese [ "Facsimiles digitais" ]
        , LanguageValues Polish [ "Cyfrowe faksymile" ]
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
    , location =
        [ LanguageValues English [ "Location" ]
        , LanguageValues German [ "Ort" ]
        , LanguageValues Spanish [ "Lugar" ]
        , LanguageValues French [ "Lieu" ]
        , LanguageValues Italian [ "Luogo" ]
        , LanguageValues Polish [ "Lokalizacja" ]
        , LanguageValues Portugese [ "Local" ]
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
    , results =
        [ LanguageValues English [ "Result types" ]
        , LanguageValues German [ "Ergebnisarten" ]
        , LanguageValues French [ "Type du résultat" ]
        , LanguageValues Italian [ "Tipo di risultato" ]
        , LanguageValues Spanish [ "Tipo de resultado" ]
        , LanguageValues Portugese [ "Tipos de resultado" ]
        , LanguageValues Polish [ "Rodzaje wyników wyszukiwania" ]
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
    , sourceContents =
        [ LanguageValues English [ "Source contents" ]
        , LanguageValues German [ "Inhalt der Quelle" ]
        , LanguageValues French [ "Contenu de la source" ]
        , LanguageValues Italian [ "Contenuto delle fonti" ]
        , LanguageValues Spanish [ "Contenido de la fuente" ]
        , LanguageValues Portugese [ "Facsimiles digitais" ]
        , LanguageValues Polish [ "Conteúdo da fonte" ]
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
    }


errorMessages :
    { badQuery : LanguageMap
    , notFound : LanguageMap
    }
errorMessages =
    { badQuery =
        [ LanguageValues English [ "There was a problem with the query" ]
        , LanguageValues German [ "Es gibt ein Problem mit der Abfrage" ]
        , LanguageValues Spanish [ "Ha habido un problema con la búsqueda" ]
        , LanguageValues French [ "Il y a eu un problème avec la requête" ]
        , LanguageValues Italian [ "C'è stato un problema nella ricerca" ]
        , LanguageValues Polish [ "Wystąpił problem z zapytaniem" ]
        , LanguageValues Portugese [ "Houve um problema com a consulta" ]
        ]
    , notFound =
        [ LanguageValues English [ "The page was not found" ]
        , LanguageValues German [ "Diese Seite wurde nicht gefunden" ]
        , LanguageValues Spanish [ "¡Ups! No encontramos esta página" ]
        , LanguageValues French [ "Page non trouvée" ]
        , LanguageValues Italian [ "Pagina non trovata" ]
        , LanguageValues Polish [ "Strona nie została znaleziona" ]
        , LanguageValues Portugese [ "A página não foi encontrada" ]
        ]
    }
