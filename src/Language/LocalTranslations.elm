module Language.LocalTranslations exposing (errorMessages, facetPanelTitles, localTranslations)

{-|

    Local translations that do not come from the server

    Some values use string interpolation for providing additional information after
    translation.

-}

import Language exposing (Language(..), LanguageMap, LanguageValue(..))


localTranslations :
    { about : LanguageMap
    , aboutAndHelp : LanguageMap
    , addTermsToQuery : LanguageMap
    , additionalFilters : LanguageMap
    , applyFiltersToUpdateResults : LanguageMap
    , chooseCollection : LanguageMap
    , collapse : LanguageMap
    , contentTypes : LanguageMap
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
    , recordType : LanguageMap
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
    , sourceType : LanguageMap
    , sources : LanguageMap
    , unknownError : LanguageMap
    , updateResults : LanguageMap
    , viewImages : LanguageMap
    , wordsAnywhere : LanguageMap
    }
localTranslations =
    { about =
        [ LanguageValue English [ "About RISM Online" ] ]
    , aboutAndHelp =
        [ LanguageValue English [ "About and Help" ] ]
    , addTermsToQuery =
        [ LanguageValue English [ "Add terms to your query" ] ]
    , additionalFilters =
        [ LanguageValue English [ "Additional filters" ] ]
    , applyFiltersToUpdateResults =
        [ LanguageValue English [ "Apply filters" ]
        , LanguageValue German [ "Filter anwenden" ]
        , LanguageValue French [ "Appliquer les filtres" ]
        , LanguageValue Italian [ "Applica filtri" ]
        , LanguageValue Spanish [ "Aplicar filtros" ]
        , LanguageValue Portugese [ "Aplicar filtros" ]
        , LanguageValue Polish [ "Zastosuj filtry" ]
        ]
    , chooseCollection =
        [ LanguageValue English [ "Choose a collection to search" ] ]
    , collapse =
        [ LanguageValue English [ "Collapse" ] ]
    , contentTypes =
        [ LanguageValue English [ "Content types" ] ]
    , description =
        [ LanguageValue English [ "Description" ]
        , LanguageValue German [ "Beschreibung" ]
        , LanguageValue French [ "Description" ]
        , LanguageValue Italian [ "Descrizione" ]
        , LanguageValue Spanish [ "Decripción" ]
        , LanguageValue Portugese [ "Descrição" ]
        , LanguageValue Polish [ "Opis" ]
        ]
    , downloadMEI =
        [ LanguageValue English [ "Download MEI" ] ]
    , downloadPNG =
        [ LanguageValue English [ "Download PNG" ] ]
    , errorLoadingProbeResults =
        [ LanguageValue English [ "Error loading results" ]
        , LanguageValue German [ "Fehler beim Laden der Ergebnisse" ]
        , LanguageValue French [ "Erreur lors du chargement des résultats" ]
        , LanguageValue Italian [ "Errore durante il caricamento dei risultati" ]
        , LanguageValue Spanish [ "Error al cargar resultados" ]
        , LanguageValue Portugese [ "Erro ao carregar os resultados" ]
        , LanguageValue Polish [ "Błąd podczas ładowania wyników" ]
        ]
    , first =
        [ LanguageValue English [ "First" ]
        , LanguageValue German [ "Erste" ]
        , LanguageValue French [ "Première" ]
        , LanguageValue Italian [ "Primo" ]
        , LanguageValue Spanish [ "Primero" ]
        , LanguageValue Portugese [ "Primeiro" ]
        , LanguageValue Polish [ "Pierwszy" ]
        ]
    , fullRecord =
        [ LanguageValue English [ "Full Record" ]
        , LanguageValue German [ "Vollanzeige" ]
        , LanguageValue French [ "Enregistrement complet" ]
        , LanguageValue Italian [ "Scheda completa" ]
        , LanguageValue Spanish [ "Registro completo" ]
        , LanguageValue Portugese [ "Registro completo" ]
        , LanguageValue Polish [ "Globalna kolekcja" ]
        ]
    , globalCollection =
        [ LanguageValue English [ "Global collection" ]
        , LanguageValue German [ "Globale Sammlung" ]
        , LanguageValue French [ "Collecte mondiale" ]
        , LanguageValue Italian [ "Collezione globale" ]
        , LanguageValue Spanish [ "Colección mundial" ]
        , LanguageValue Portugese [ "Coleção global" ]
        , LanguageValue Polish [ "Pełny widok rekordu" ]
        ]
    , hasDigitization =
        [ LanguageValue English [ "Digital images available" ] ]
    , hasIIIFManifest =
        [ LanguageValue English [ "IIIF manifest available" ] ]
    , hasIncipits =
        [ LanguageValue English [ "Has incipits" ] ]
    , heldBy =
        [ LanguageValue English [ "Held by" ] ]
    , home =
        [ LanguageValue English [ "Home" ]
        , LanguageValue German [ "Startseite" ]
        , LanguageValue French [ "Accueil" ]
        , LanguageValue Italian [ "Home" ]
        , LanguageValue Spanish [ "Página principal" ]
        , LanguageValue Portugese [ "Início" ]
        , LanguageValue Polish [ "Strona główna" ]
        ]
    , incipitSearchHelpHide =
        [ LanguageValue English [ "Hide Incipit Search Help" ] ]
    , incipitSearchHelpShow =
        [ LanguageValue English [ "Show Incipit Search Help" ] ]
    , incipits =
        [ LanguageValue Spanish [ "Íncipits" ]
        , LanguageValue Portugese [ "Incipit" ]
        , LanguageValue German [ "Incipits" ]
        , LanguageValue Italian [ "Incipit" ]
        , LanguageValue Polish [ "Incipity" ]
        , LanguageValue English [ "Incipits" ]
        , LanguageValue French [ "Incipits" ]
        ]
    , institution =
        [ LanguageValue English [ "Institution" ] ]
    , institutions =
        [ LanguageValue Spanish [ "Instituciones" ]
        , LanguageValue Portugese [ "Instituições" ]
        , LanguageValue German [ "Körperschaften" ]
        , LanguageValue Italian [ "Istituzioni" ]
        , LanguageValue Polish [ "Instytucje" ]
        , LanguageValue English [ "Institutions" ]
        , LanguageValue French [ "Institutions" ]
        ]
    , keywordQuery =
        [ LanguageValue English [ "Keyword query" ]
        , LanguageValue Portugese [ "Consulta por palavra-chave" ]
        , LanguageValue German [ "Stichwortsuche" ]
        , LanguageValue Italian [ "Ricerca per parola chiave" ]
        , LanguageValue Polish [ "Zapytanie o słowo kluczowe" ]
        , LanguageValue French [ "Recherche par mot-clé" ]
        , LanguageValue Spanish [ "Consulta de palabra clave" ]
        ]
    , last =
        [ LanguageValue English [ "Last" ]
        , LanguageValue German [ "Letzte" ]
        , LanguageValue French [ "Dernière" ]
        , LanguageValue Italian [ "Ultimo" ]
        , LanguageValue Spanish [ "Último" ]
        , LanguageValue Portugese [ "Último" ]
        , LanguageValue Polish [ "Ostatni" ]
        ]
    , liturgicalFeasts = []
    , location =
        [ LanguageValue English [ "Location" ]
        , LanguageValue German [ "Ort" ]
        , LanguageValue French [ "Lieu" ]
        , LanguageValue Italian [ "Luogo" ]
        , LanguageValue Spanish [ "Lugar" ]
        , LanguageValue Portugese [ "Local" ]
        , LanguageValue Polish [ "Lokalizacja" ]
        ]
    , muscatEdit =
        [ LanguageValue English [ "Edit" ] ]
    , muscatView =
        [ LanguageValue English [ "View" ] ]
    , nearbyInstitutions =
        [ LanguageValue English [ "Nearby institutions" ]
        , LanguageValue German [ "Nahegelegene Körperschaften" ]
        , LanguageValue French [ "Institutions proches" ]
        , LanguageValue Italian [ "Istituzioni vicine" ]
        , LanguageValue Spanish [ "Instituciones cercanas" ]
        , LanguageValue Portugese [ "Instituições próximas" ]
        , LanguageValue Polish [ "Pobliskie instytucje" ]
        ]
    , newSearchWithIncipit =
        [ LanguageValue English [ "Search for incipits like this" ] ]
    , next =
        [ LanguageValue English [ "Next" ]
        , LanguageValue German [ "Nächste" ]
        , LanguageValue French [ "Suivante" ]
        , LanguageValue Italian [ "Prossimo" ]
        , LanguageValue Spanish [ "Siguiente" ]
        , LanguageValue Portugese [ "Próximo" ]
        , LanguageValue Polish [ "Następny" ]
        ]
    , noResultsBody =
        [ LanguageValue English [ "Adjust your query options, or reset all filters, to see results." ]
        , LanguageValue German [ "Passen Sie Ihre Abfrageoptionen an oder setzen Sie alle Filter zurück, um Ergebnisse zu sehen." ]
        , LanguageValue French [ "Ajustez vos options de requête, ou réinitialisez tous les filtres, pour voir les résultats." ]
        , LanguageValue Italian [ "Modifica le opzioni di ricerca o ripristina tutti i filtri per visualizzare nuovi risultati." ]
        , LanguageValue Spanish [ "Ajuste las opciones de consulta, o reinicie todos los filtros, para ver resultados." ]
        , LanguageValue Portugese [ "Ajuste as opções de sua consulta ou redefina todos os filtros para ver os resultados." ]
        , LanguageValue Polish [ "Dostosuj opcje zapytania lub zresetuj wszystkie filtry, aby zobaczyć wyniki." ]
        ]
    , noResultsHeader =
        [ LanguageValue English [ "No results were found for your search" ]
        , LanguageValue German [ "Keine Suchergebnisse gefunden" ]
        , LanguageValue French [ "Aucun résultat trouvé" ]
        , LanguageValue Italian [ "Questa ricerca non produce alcun risultato" ]
        , LanguageValue Spanish [ "No se encontraron resultados con esta búsqueda" ]
        , LanguageValue Portugese [ "Nenhum resultado será encontrado para esta pesquisa" ]
        , LanguageValue Polish [ "Nie znaleziono wyników dla Twojego wyszukiwania" ]
        ]
    , noResultsWouldBeFound =
        [ LanguageValue English [ "No results would be found with this search" ]
        , LanguageValue German [ "Diese Suche brachte keine Ergebnisse" ]
        , LanguageValue French [ "Aucun résultat pour cette recherche" ]
        , LanguageValue Italian [ "Nessun risultato verrebbe trovato con questa ricerca" ]
        , LanguageValue Spanish [ "No se encontrarían resultados con esta búsqueda" ]
        , LanguageValue Portugese [ "Nenhum resultado seria encontrado com esta pesquisa" ]
        , LanguageValue Polish [ "Nie znaleziono żadnych wyników dla tego wyszukiwania" ]
        ]
    , notationQueryLength =
        [ LanguageValue English [ "Queries must be longer than three notes" ] ]
    , numberOfResults =
        [ LanguageValue English [ "Number of results" ]
        , LanguageValue German [ "Ergebnisse mit angewendeten Filtern" ]
        , LanguageValue French [ "Résultats avec filtres appliqués" ]
        , LanguageValue Italian [ "Risultati con filtri applicati" ]
        , LanguageValue Spanish [ "Resultados con filtros aplicados" ]
        , LanguageValue Portugese [ "Resultados com filtros aplicados" ]
        , LanguageValue Polish [ "Wyniki z zastosowanymi filtrami" ]
        ]
    , optionsWithAnd =
        [ LanguageValue English [ "Options are combined with an AND operator" ] ]
    , optionsWithOr =
        [ LanguageValue English [ "Options are combined with an OR operator" ] ]
    , orChooseCollection =
        [ LanguageValue English [ "Or choose a national collection" ] ]
    , paeInput =
        [ LanguageValue English [ "Plaine and Easie Input" ] ]
    , page =
        [ LanguageValue English [ "Page" ]
        , LanguageValue German [ "Seite" ]
        , LanguageValue French [ "Page" ]
        , LanguageValue Italian [ "Pagina" ]
        , LanguageValue Spanish [ "Página" ]
        , LanguageValue Portugese [ "Página" ]
        , LanguageValue Polish [ "Strona" ]
        ]
    , partOf =
        [ LanguageValue English [ "Part of" ] ]
    , partOfCollection =
        [ LanguageValue English [ "This record is part of a collection" ] ]
    , people =
        [ LanguageValue Spanish [ "Personas" ]
        , LanguageValue Portugese [ "Pessoas" ]
        , LanguageValue German [ "Personen" ]
        , LanguageValue Italian [ "Persone" ]
        , LanguageValue Polish [ "Osoby" ]
        , LanguageValue English [ "People" ]
        , LanguageValue French [ "Personnes" ]
        ]
    , person =
        [ LanguageValue English [ "Person" ] ]
    , place =
        [ LanguageValue English [ "Place" ] ]
    , previous =
        [ LanguageValue English [ "Previous" ]
        , LanguageValue German [ "Vorige" ]
        , LanguageValue French [ "Précédent" ]
        , LanguageValue Italian [ "Precedente" ]
        , LanguageValue Spanish [ "Anterior" ]
        , LanguageValue Portugese [ "Anterior" ]
        , LanguageValue Polish [ "Poprzedni" ]
        ]
    , queryTerms =
        [ LanguageValue English [ "Query terms" ] ]
    , recordPreview =
        [ LanguageValue English [ "Record preview" ]
        , LanguageValue German [ "Dokumentvorschau" ]
        , LanguageValue French [ "Aperçu de la notice" ]
        , LanguageValue Italian [ "Anteprima la scheda" ]
        , LanguageValue Spanish [ "Vista previa del registro" ]
        , LanguageValue Portugese [ "Visualizar do registro" ]
        , LanguageValue Polish [ "Zapowiedź rekordu" ]
        ]
    , recordTop =
        [ LanguageValue English [ "Record top" ] ]
    , recordType =
        [ LanguageValue English [ "Record type" ] ]
    , recordURI =
        [ LanguageValue English [ "Record URI (Permalink)" ]
        , LanguageValue German [ "URI des Datensatzes (Permalink)" ]
        , LanguageValue French [ "Record URI (Permalink)" ]
        , LanguageValue Italian [ "Link alla scheda (permalink)" ]
        , LanguageValue Spanish [ "Record URI (Permalink)" ]
        , LanguageValue Portugese [ "Record URI (Permalink)" ]
        , LanguageValue Polish [ "URI rekordu (Odnośnik bezpośredni)" ]
        ]
    , reportAnIssue =
        [ LanguageValue English [ "Report an issue" ] ]
    , resetAll =
        [ LanguageValue English [ "Reset all" ]
        , LanguageValue German [ "Alles zurücksetzen" ]
        , LanguageValue French [ "Effacer tout" ]
        , LanguageValue Italian [ "Resetta tutto" ]
        , LanguageValue Spanish [ "Resetear todo" ]
        , LanguageValue Portugese [ "Reiniciar tudo" ]
        , LanguageValue Polish [ "Zresetować wszystko" ]
        ]
    , rowsPerPage =
        [ LanguageValue English [ "Rows per page" ] ]
    , search =
        [ LanguageValue English [ "Search" ]
        , LanguageValue German [ "Suche" ]
        , LanguageValue French [ "Chercher" ]
        , LanguageValue Italian [ "Cerca" ]
        , LanguageValue Spanish [ "Búsqueda" ]
        , LanguageValue Portugese [ "Busca" ]
        , LanguageValue Polish [ "Wyszukiwanie" ]
        ]
    , searchNumberOfRecords =
        [ LanguageValue English [ "Search {{ numberOfRecords }} {{ recordType }}" ] ]
    , seeAll =
        [ LanguageValue English [ "See all" ] ]
    , showAllRecords =
        [ LanguageValue English [ "Show all results" ]
        , LanguageValue German [ "Alle Ergebnisse anzeigen" ]
        , LanguageValue French [ "Afficher tous les résultats" ]
        , LanguageValue Italian [ "Mostra tutti i risultati" ]
        , LanguageValue Spanish [ "Mostrar todos los resultados" ]
        , LanguageValue Portugese [ "Mostrar todos os resultados" ]
        , LanguageValue Polish [ "Wyświetl wszystkie wyniki" ]
        ]
    , showNumItems =
        [ LanguageValue English [ "Show {{ numItems }} items" ] ]
    , showResults =
        [ LanguageValue English [ "Show search results" ]
        , LanguageValue German [ "Filter anwenden" ]
        , LanguageValue French [ "Appliquer des filtres" ]
        , LanguageValue Italian [ "Applicare filtri" ]
        , LanguageValue Spanish [ "Aplicar filtros" ]
        , LanguageValue Portugese [ "Aplicar filtros" ]
        , LanguageValue Polish [ "Zastosuj filtry" ]
        ]
    , sortAlphabetically =
        [ LanguageValue English [ "Sort alphabetically (currently sorted by count)" ] ]
    , sortBy =
        [ LanguageValue English [ "Sort by" ] ]
    , sortByCount =
        [ LanguageValue English [ "Sort by count (currently sorted alphabetically)" ] ]
    , source =
        [ LanguageValue English [ "Source" ] ]
    , sourceContents =
        [ LanguageValue English [ "Source contents" ]
        , LanguageValue German [ "Inhalt der Quelle" ]
        , LanguageValue French [ "Contenu de la source" ]
        , LanguageValue Italian [ "Contenuto delle fonti" ]
        , LanguageValue Polish [ "Treść źródła" ]
        , LanguageValue Portugese [ "Conteúdo da fonte" ]
        ]
    , sourceType =
        [ LanguageValue English [ "Source type" ] ]
    , sources =
        [ LanguageValue English [ "Sources" ]
        , LanguageValue German [ "Quellen" ]
        , LanguageValue French [ "Sources" ]
        , LanguageValue Italian [ "Fonti" ]
        , LanguageValue Spanish [ "Fuentes" ]
        , LanguageValue Portugese [ "Fontes" ]
        , LanguageValue Polish [ "Źródła" ]
        ]
    , unknownError =
        [ LanguageValue English [ "An unknown error occurred." ] ]
    , updateResults =
        [ LanguageValue English [ "Update search results" ]
        , LanguageValue German [ "Filter anwenden" ]
        , LanguageValue French [ "Appliquer des filtres" ]
        , LanguageValue Italian [ "Applicare filtri" ]
        , LanguageValue Spanish [ "Aplicar filtros" ]
        , LanguageValue Portugese [ "Aplicar filtros" ]
        , LanguageValue Polish [ "Zastosuj filtry" ]
        ]
    , viewImages =
        [ LanguageValue English [ "View images" ] ]
    , wordsAnywhere =
        [ LanguageValue English [ "Words anywhere" ]
        , LanguageValue German [ "Eingabe Ihrer Anfrage" ]
        , LanguageValue French [ "Entrez votre requête" ]
        , LanguageValue Italian [ "Inserisci la tua richiesta" ]
        , LanguageValue Spanish [ "Introduzca su consulta" ]
        , LanguageValue Portugese [ "Introduza a sua consulta" ]
        , LanguageValue Polish [ "Wprowadź swoje zapytanie" ]
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
        [ LanguageValue English [ "Biographical details" ]
        , LanguageValue German [ "Biografische Details" ]
        , LanguageValue French [ "Détails biographiques" ]
        , LanguageValue Italian [ "Dati biografici" ]
        , LanguageValue Spanish [ "Detalles biográficos" ]
        , LanguageValue Portugese [ "Detalhes biográficos" ]
        , LanguageValue Polish [ "Szczegóły bibliograficzne" ]
        ]
    , clefKeyTime =
        [ LanguageValue English [ "Clef, key signature, time signature" ] ]
    , composerComposition =
        [ LanguageValue English [ "Composer and composition" ] ]
    , digitizations =
        [ LanguageValue English [ "Digital facsimiles" ]
        , LanguageValue German [ "Digitale Faksimiles" ]
        , LanguageValue French [ "Fac-similés numériques" ]
        , LanguageValue Italian [ "Facsimili digitali" ]
        , LanguageValue Spanish [ "Facsímiles digitales" ]
        , LanguageValue Portugese [ "Facsimiles digitais" ]
        , LanguageValue Polish [ "Cyfrowe faksymile" ]
        ]
    , holdingInstitutions =
        [ LanguageValue English [ "Holding institutions" ]
        , LanguageValue German [ "Besitzende Institution" ]
        , LanguageValue French [ "Institution" ]
        , LanguageValue Italian [ "Dove trovarlo" ]
        , LanguageValue Spanish [ "Instituciones participantes" ]
        , LanguageValue Portugese [ "Responsabilidade das Instituições" ]
        , LanguageValue Polish [ "Instytucje przechowujące" ]
        ]
    , location =
        [ LanguageValue English [ "Location" ]
        , LanguageValue German [ "Ort" ]
        , LanguageValue Spanish [ "Lugar" ]
        , LanguageValue French [ "Lieu" ]
        , LanguageValue Italian [ "Luogo" ]
        , LanguageValue Polish [ "Lokalizacja" ]
        , LanguageValue Portugese [ "Local" ]
        ]
    , publicationDetails =
        [ LanguageValue English [ "Publication details" ]
        , LanguageValue German [ "Veröffentlichungsinformationen" ]
        , LanguageValue French [ "Détails de publication" ]
        , LanguageValue Italian [ "Pubblicazione" ]
        , LanguageValue Spanish [ "Detalles de publicación" ]
        , LanguageValue Portugese [ "Detalhes de Publicação" ]
        , LanguageValue Polish [ "Szczegóły publikacji" ]
        ]
    , results =
        [ LanguageValue English [ "Result types" ]
        , LanguageValue German [ "Ergebnisarten" ]
        , LanguageValue French [ "Type du résultat" ]
        , LanguageValue Italian [ "Tipo di risultato" ]
        , LanguageValue Spanish [ "Tipo de resultado" ]
        , LanguageValue Portugese [ "Tipos de resultado" ]
        , LanguageValue Polish [ "Rodzaje wyników wyszukiwania" ]
        ]
    , roleAndProfession =
        [ LanguageValue English [ "Role and profession" ]
        , LanguageValue German [ "Funktion und Beruf" ]
        , LanguageValue French [ "Rôle et profession" ]
        , LanguageValue Italian [ "Ruolo e professione" ]
        , LanguageValue Spanish [ "Función y profesión" ]
        , LanguageValue Portugese [ "Cargo e profissão" ]
        , LanguageValue Polish [ "Funkcja i zawód" ]
        ]
    , sourceContents =
        [ LanguageValue English [ "Source contents" ]
        , LanguageValue German [ "Inhalt der Quelle" ]
        , LanguageValue French [ "Contenu de la source" ]
        , LanguageValue Italian [ "Contenuto delle fonti" ]
        , LanguageValue Spanish [ "Contenido de la fuente" ]
        , LanguageValue Portugese [ "Facsimiles digitais" ]
        , LanguageValue Polish [ "Conteúdo da fonte" ]
        ]
    , sourceRelationships =
        [ LanguageValue English [ "Source relationships" ]
        , LanguageValue German [ "Quellen-Beziehungen" ]
        , LanguageValue French [ "Relation" ]
        , LanguageValue Italian [ "Relazioni tra fonti" ]
        , LanguageValue Spanish [ "Relaciones de resultado" ]
        , LanguageValue Portugese [ "Relações da fonte" ]
        , LanguageValue Polish [ "Relacje do źródła" ]
        ]
    }


errorMessages :
    { badQuery : LanguageMap
    , notFound : LanguageMap
    }
errorMessages =
    { badQuery =
        [ LanguageValue English [ "There was a problem with the query" ]
        , LanguageValue German [ "Es gibt ein Problem mit der Abfrage" ]
        , LanguageValue Spanish [ "Ha habido un problema con la búsqueda" ]
        , LanguageValue French [ "Il y a eu un problème avec la requête" ]
        , LanguageValue Italian [ "C'è stato un problema nella ricerca" ]
        , LanguageValue Polish [ "Wystąpił problem z zapytaniem" ]
        , LanguageValue Portugese [ "Houve um problema com a consulta" ]
        ]
    , notFound =
        [ LanguageValue English [ "The page was not found" ]
        , LanguageValue German [ "Diese Seite wurde nicht gefunden" ]
        , LanguageValue Spanish [ "¡Ups! No encontramos esta página" ]
        , LanguageValue French [ "Page non trouvée" ]
        , LanguageValue Italian [ "Pagina non trovata" ]
        , LanguageValue Polish [ "Strona nie została znaleziona" ]
        , LanguageValue Portugese [ "A página não foi encontrada" ]
        ]
    }
