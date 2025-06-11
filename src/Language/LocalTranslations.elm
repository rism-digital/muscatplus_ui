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
    , downloadResults : LanguageMap
    , downloadsHelpOne : LanguageMap
    , downloadsHelpTwo : LanguageMap
    , downloadsLimited : LanguageMap
    , downloadsSearchUrlHelp : LanguageMap
    , errorLoadingProbeResults : LanguageMap
    , exemplarURI : LanguageMap
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
    , noAdditionalDetails : LanguageMap
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
    , resultsOfOtherTypes : LanguageMap
    , resultsWereFoundForOthers : LanguageMap
    , rowsPerPage : LanguageMap
    , search : LanguageMap
    , searchNumberOfRecords : LanguageMap
    , seeAll : LanguageMap
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
    , workCatalogues : LanguageMap
    }
localTranslations =
    { about =
        [ LanguageValue English [ "About RISM Online" ]
        , LanguageValue German
            [ "Über RISM Online" ]
        , LanguageValue French
            [ "À propos de RISM Online" ]
        , LanguageValue Italian
            [ "Informazioni su RISM Online" ]
        , LanguageValue Spanish
            [ "Acerca de RISM Online" ]
        , LanguageValue Portuguese
            [ "Sobre o RISM Online" ]
        , LanguageValue Polish
            [ "O RISM Online" ]
        ]
    , aboutAndHelp =
        [ LanguageValue English [ "About and Help" ]
        , LanguageValue German
            [ "Über und Hilfe" ]
        , LanguageValue French
            [ "À propos et aide" ]
        , LanguageValue Italian
            [ "Informazioni e aiuto" ]
        , LanguageValue Spanish
            [ "Acerca de y ayuda" ]
        , LanguageValue Portuguese
            [ "Sobre e ajuda" ]
        , LanguageValue Polish
            [ "O nas i pomoc" ]
        ]
    , addTermsToQuery =
        [ LanguageValue English [ "Add terms to your query" ]
        , LanguageValue German
            [ "Fügen Sie Begriffe zu Ihrer Anfrage hinzu" ]
        , LanguageValue French
            [ "Ajoutez des termes à votre requête" ]
        , LanguageValue Italian
            [ "Aggiungi termini alla tua ricerca" ]
        , LanguageValue Spanish
            [ "Añadir términos a su consulta" ]
        , LanguageValue Portuguese
            [ "Adicione termos à sua consulta" ]
        , LanguageValue Polish
            [ "Dodaj terminy do swojego zapytania" ]
        ]
    , additionalFilters =
        [ LanguageValue English [ "Additional filters" ]
        , LanguageValue German
            [ "Zusätzliche Filter" ]
        , LanguageValue French
            [ "Filtres supplémentaires" ]
        , LanguageValue Italian
            [ "Filtri aggiuntivi" ]
        , LanguageValue Spanish
            [ "Filtros adicionales" ]
        , LanguageValue Portuguese
            [ "Filtros adicionais" ]
        , LanguageValue Polish
            [ "Dodatkowe filtry" ]
        ]
    , applyFiltersToUpdateResults =
        [ LanguageValue English [ "Apply filters" ]
        , LanguageValue German [ "Filter anwenden" ]
        , LanguageValue French [ "Appliquer les filtres" ]
        , LanguageValue Italian [ "Applica filtri" ]
        , LanguageValue Spanish [ "Aplicar filtros" ]
        , LanguageValue Portuguese [ "Aplicar filtros" ]
        , LanguageValue Polish [ "Zastosuj filtry" ]
        ]
    , chooseCollection =
        [ LanguageValue English [ "Choose a collection to search" ]
        , LanguageValue German
            [ "Wählen Sie eine Sammlung zum Durchsuchen" ]
        , LanguageValue French
            [ "Choisissez une collection à rechercher" ]
        , LanguageValue Italian
            [ "Scegli una collezione da cercare" ]
        , LanguageValue Spanish
            [ "Elija una colección para buscar" ]
        , LanguageValue Portuguese
            [ "Escolha uma coleção para pesquisar" ]
        , LanguageValue Polish
            [ "Wybierz kolekcję do przeszukania" ]
        ]
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
        , LanguageValue Portuguese [ "Descrição" ]
        , LanguageValue Polish [ "Opis" ]
        ]
    , downloadMEI =
        [ LanguageValue English [ "Download MEI" ]
        , LanguageValue German
            [ "MEI herunterladen" ]
        , LanguageValue French
            [ "Télécharger MEI" ]
        , LanguageValue Italian
            [ "Scarica MEI" ]
        , LanguageValue Spanish
            [ "Descargar MEI" ]
        , LanguageValue Portuguese
            [ "Baixar MEI" ]
        , LanguageValue Polish
            [ "Pobierz MEI" ]
        ]
    , downloadPNG =
        [ LanguageValue English [ "Download PNG" ]
        , LanguageValue German
            [ "PNG herunterladen" ]
        , LanguageValue French
            [ "Télécharger PNG" ]
        , LanguageValue Italian
            [ "Scarica PNG" ]
        , LanguageValue Spanish
            [ "Descargar PNG" ]
        , LanguageValue Portuguese
            [ "Baixar PNG" ]
        , LanguageValue Polish
            [ "Pobierz PNG" ]
        ]
    , downloadResults =
        [ LanguageValue English
            [ "Download results " ]
        , LanguageValue German
            [ "Ergebnisse herunterladen" ]
        , LanguageValue French
            [ "Télécharger les résultats" ]
        , LanguageValue Italian
            [ "Scarica i risultati" ]
        , LanguageValue Spanish
            [ "Descargar resultados" ]
        , LanguageValue Portuguese
            [ "Baixar resultados" ]
        , LanguageValue Polish
            [ "Pobierz wyniki" ]
        ]
    , downloadsHelpOne =
        [ LanguageValue English
            [ """Downloads are in Comma Separated Values (CSV) format. Start your download by clicking on the "Download" button. When the download completes, a file save window will appear to save your results to your local computer.""" ]
        , LanguageValue German
            [ """Die Downloads liegen im CSV-Format (Comma Separated Values) vor. 
                    Starten Sie Ihren Download, indem Sie auf die Schaltfläche „Download“ klicken. 
                    Sobald der Download abgeschlossen ist, erscheint ein Fenster zum Speichern der Datei auf Ihrem lokalen Computer.""" ]
        , LanguageValue French
            [ """Les téléchargements sont au format CSV (Comma Separated Values). 
                    Commencez votre téléchargement en cliquant sur le bouton "Télécharger". 
                    Une fois le téléchargement terminé, une fenêtre de sauvegarde apparaîtra 
                    pour enregistrer votre fichier sur votre ordinateur local.""" ]
        , LanguageValue Italian
            [ """I download sono in formato CSV (Comma Separated Values). 
                    Avvia il download facendo clic sul pulsante "Scarica". 
                    Al termine del download, apparirà una finestra di salvataggio 
                    per salvare il file sul tuo computer locale.""" ]
        , LanguageValue Spanish
            [ """Las descargas están en formato CSV (Comma Separated Values). 
                    Inicie la descarga haciendo clic en el botón "Descargar". 
                    Cuando la descarga se complete, aparecerá una ventana de guardado 
                    para guardar el archivo en su computadora local.""" ]
        , LanguageValue Portuguese
            [ """Os downloads estão no formato CSV (Comma Separated Values). 
                    Inicie o download clicando no botão "Baixar". 
                    Quando o download for concluído, uma janela de salvamento aparecerá 
                    para salvar o arquivo no seu computador local.""" ]
        , LanguageValue Polish
            [ """Pobrane pliki są w formacie CSV (Comma Separated Values). 
                    Rozpocznij pobieranie, klikając przycisk „Pobierz”. 
                    Po zakończeniu pobierania pojawi się okno zapisu, 
                    aby zapisać plik na komputerze lokalnym.""" ]
        ]
    , downloadsHelpTwo =
        [ LanguageValue English
            [ """While the results are downloading do not close your browser or navigate away from this page. You can continue browsing in another tab or window.""" ]
        , LanguageValue German
            [ """Während die Ergebnisse heruntergeladen werden, schließen Sie bitte nicht Ihren Browser 
                      und verlassen Sie diese Seite nicht. Sie können weiterhin in einem anderen Tab oder Fenster surfen.""" ]
        , LanguageValue French
            [ """Pendant le téléchargement des résultats, ne fermez pas votre navigateur 
                      et ne quittez pas cette page. Vous pouvez continuer à naviguer dans un autre onglet ou une autre fenêtre.""" ]
        , LanguageValue Italian
            [ """Durante il download dei risultati, non chiudere il browser 
                      e non lasciare questa pagina. Puoi continuare a navigare in un'altra scheda o finestra.""" ]
        , LanguageValue Spanish
            [ """Mientras se descargan los resultados, no cierre su navegador 
                      ni navegue fuera de esta página. Puede seguir navegando en otra pestaña o ventana.""" ]
        , LanguageValue Portuguese
            [ """Enquanto os resultados estão sendo baixados, não feche o navegador 
                      nem saia desta página. Você pode continuar navegando em outra aba ou janela.""" ]
        , LanguageValue Polish
            [ """Podczas pobierania wyników nie zamykaj przeglądarki 
                      ani nie opuszczaj tej strony. Możesz kontynuować przeglądanie w innej karcie lub oknie.""" ]
        ]
    , downloadsLimited =
        [ LanguageValue English [ "Downloads are limited to {{numResults}} search results." ]
        , LanguageValue German [ "Downloads sind auf {{numResults}} Suchergebnisse beschränkt." ]
        , LanguageValue French [ "Les téléchargements sont limités à {{numResults}} résultats de recherche." ]
        , LanguageValue Italian [ "I download sono limitati a {{numResults}} risultati di ricerca." ]
        , LanguageValue Spanish [ "Las descargas están limitadas a {{numResults}} resultados de búsqueda." ]
        , LanguageValue Portuguese [ "Os downloads estão limitados a {{numResults}} resultados de pesquisa." ]
        , LanguageValue Polish [ "Pobieranie jest ograniczone do {{numResults}} wyników wyszukiwania." ]
        ]
    , downloadsSearchUrlHelp =
        [ LanguageValue English
            [ """Includes the URL to the original search as the first entry in the CSV. This may be useful for referring back to the search that generated a list of results, but it does not follow the format of the other results so additional care is required if processing the results.""" ]
        , LanguageValue German
            [ """Enthält die URL zur ursprünglichen Suche als ersten Eintrag in der CSV-Datei.
                     Dies kann nützlich sein, um auf die Suche zurückzugreifen, die die Liste der Ergebnisse erstellt hat.
                     Allerdings entspricht sie nicht dem Format der anderen Ergebnisse, sodass bei der Verarbeitung besondere Vorsicht erforderlich ist.""" ]
        , LanguageValue French
            [ """Inclut l'URL de la recherche originale en tant que première entrée dans le fichier CSV.
                     Cela peut être utile pour revenir à la recherche qui a généré la liste des résultats,
                     mais elle ne suit pas le format des autres résultats, donc une attention particulière est requise lors du traitement.""" ]
        , LanguageValue Italian
            [ """Include l'URL della ricerca originale come primo elemento nel file CSV.
                     Questo può essere utile per fare riferimento alla ricerca che ha generato l'elenco dei risultati,
                     ma non segue il formato degli altri risultati, quindi è necessaria un'attenzione aggiuntiva durante l'elaborazione.""" ]
        , LanguageValue Spanish
            [ """Incluye la URL de la búsqueda original como la primera entrada en el archivo CSV.
                     Esto puede ser útil para volver a la búsqueda que generó la lista de resultados,
                     pero no sigue el formato de los demás resultados, por lo que se requiere cuidado adicional al procesarlos.""" ]
        , LanguageValue Portuguese
            [ """Inclui a URL da pesquisa original como a primeira entrada no arquivo CSV.
                     Isso pode ser útil para consultar a pesquisa que gerou a lista de resultados,
                     mas não segue o formato dos outros resultados, portanto, é necessário ter um cuidado extra ao processá-los.""" ]
        , LanguageValue Polish
            [ """Zawiera adres URL oryginalnego wyszukiwania jako pierwszy wpis w pliku CSV.
                     Może to być przydatne do odniesienia się do wyszukiwania, które wygenerowało listę wyników,
                     ale nie odpowiada formatowi pozostałych wyników, dlatego podczas przetwarzania należy zachować szczególną ostrożność.""" ]
        ]
    , errorLoadingProbeResults =
        [ LanguageValue English [ "Error loading results" ]
        , LanguageValue German [ "Fehler beim Laden der Ergebnisse" ]
        , LanguageValue French [ "Erreur lors du chargement des résultats" ]
        , LanguageValue Italian [ "Errore durante il caricamento dei risultati" ]
        , LanguageValue Spanish [ "Error al cargar resultados" ]
        , LanguageValue Portuguese [ "Erro ao carregar os resultados" ]
        , LanguageValue Polish [ "Błąd podczas ładowania wyników" ]
        ]
    , exemplarURI =
        [ LanguageValue English [ "Exemplar URI" ]
        , LanguageValue German [ "Exemplar URI" ]
        , LanguageValue French [ "URI de l'exemplaire" ]
        , LanguageValue Italian [ "URI dell'esemplare" ]
        , LanguageValue Spanish [ "URI del ejemplar" ]
        , LanguageValue Portuguese [ "URI do exemplar" ]
        , LanguageValue Polish [ "URI egzemplarza" ]
        ]
    , first =
        [ LanguageValue English [ "First" ]
        , LanguageValue German [ "Erste" ]
        , LanguageValue French [ "Première" ]
        , LanguageValue Italian [ "Primo" ]
        , LanguageValue Spanish [ "Primero" ]
        , LanguageValue Portuguese [ "Primeiro" ]
        , LanguageValue Polish [ "Pierwszy" ]
        ]
    , fullRecord =
        [ LanguageValue English [ "Full Record" ]
        , LanguageValue German [ "Vollanzeige" ]
        , LanguageValue French [ "Enregistrement complet" ]
        , LanguageValue Italian [ "Scheda completa" ]
        , LanguageValue Spanish [ "Registro completo" ]
        , LanguageValue Portuguese [ "Registro completo" ]
        , LanguageValue Polish [ "Globalna kolekcja" ]
        ]
    , globalCollection =
        [ LanguageValue English [ "Global collection" ]
        , LanguageValue German [ "Globale Sammlung" ]
        , LanguageValue French [ "Collecte mondiale" ]
        , LanguageValue Italian [ "Collezione globale" ]
        , LanguageValue Spanish [ "Colección mundial" ]
        , LanguageValue Portuguese [ "Coleção global" ]
        , LanguageValue Polish [ "Pełny widok rekordu" ]
        ]
    , hasDigitization =
        [ LanguageValue English [ "Digital images available" ]
        , LanguageValue German
            [ "Digitale Bilder verfügbar" ]
        , LanguageValue French
            [ "Images numériques disponibles" ]
        , LanguageValue Italian
            [ "Immagini digitali disponibili" ]
        , LanguageValue Spanish
            [ "Imágenes digitales disponibles" ]
        , LanguageValue Portuguese
            [ "Imagens digitais disponíveis" ]
        , LanguageValue Polish
            [ "Dostępne obrazy cyfrowe" ]
        ]
    , hasIIIFManifest =
        [ LanguageValue English [ "IIIF manifest available" ] ]
    , hasIncipits =
        [ LanguageValue English [ "Has incipits" ]
        , LanguageValue German
            [ "Hat Incipits" ]
        , LanguageValue French
            [ "Contient des incipits" ]
        , LanguageValue Italian
            [ "Ha incipit" ]
        , LanguageValue Spanish
            [ "Tiene incipits" ]
        , LanguageValue Portuguese
            [ "Possui incipits" ]
        , LanguageValue Polish
            [ "Zawiera incipity" ]
        ]
    , heldBy =
        [ LanguageValue English
            [ "Held by" ]
        , LanguageValue German
            [ "Gehalten von" ]
        , LanguageValue French
            [ "Détenu par" ]
        , LanguageValue Italian
            [ "Posseduto da" ]
        , LanguageValue Spanish
            [ "Poseído por" ]
        , LanguageValue Portuguese
            [ "Mantido por" ]
        , LanguageValue Polish
            [ "Przechowywane przez" ]
        ]
    , home =
        [ LanguageValue English [ "Home" ]
        , LanguageValue German [ "Startseite" ]
        , LanguageValue French [ "Accueil" ]
        , LanguageValue Italian [ "Home" ]
        , LanguageValue Spanish [ "Página principal" ]
        , LanguageValue Portuguese [ "Início" ]
        , LanguageValue Polish [ "Strona główna" ]
        ]
    , incipitSearchHelpHide =
        [ LanguageValue English [ "Hide Incipit Search Help" ]
        , LanguageValue German
            [ "Incipit-Suchhilfe ausblenden" ]
        , LanguageValue French
            [ "Masquer l'aide à la recherche d'incipit" ]
        , LanguageValue Italian
            [ "Nascondi aiuto per la ricerca dell'incipit" ]
        , LanguageValue Spanish
            [ "Ocultar ayuda de búsqueda de incipit" ]
        , LanguageValue Portuguese
            [ "Ocultar ajuda de pesquisa de incipit" ]
        , LanguageValue Polish
            [ "Ukryj pomoc wyszukiwania incipitu" ]
        ]
    , incipitSearchHelpShow =
        [ LanguageValue English
            [ "Show Incipit Search Help" ]
        , LanguageValue German
            [ "Incipit-Suchhilfe anzeigen" ]
        , LanguageValue French
            [ "Afficher l'aide à la recherche d'incipit" ]
        , LanguageValue Italian
            [ "Mostra aiuto per la ricerca dell'incipit" ]
        , LanguageValue Spanish
            [ "Mostrar ayuda de búsqueda de incipit" ]
        , LanguageValue Portuguese
            [ "Mostrar ajuda de pesquisa de incipit" ]
        , LanguageValue Polish
            [ "Pokaż pomoc wyszukiwania incipitu" ]
        ]
    , incipits =
        [ LanguageValue Spanish [ "Íncipits" ]
        , LanguageValue Portuguese [ "Incipit" ]
        , LanguageValue German [ "Incipits" ]
        , LanguageValue Italian [ "Incipit" ]
        , LanguageValue Polish [ "Incipity" ]
        , LanguageValue English [ "Incipits" ]
        , LanguageValue French [ "Incipits" ]
        ]
    , institution =
        [ LanguageValue English [ "Institution" ]
        , LanguageValue German [ "Institution" ]
        , LanguageValue French [ "Institution" ]
        , LanguageValue Italian [ "Istituzione" ]
        , LanguageValue Spanish [ "Institución" ]
        , LanguageValue Portuguese [ "Instituição" ]
        , LanguageValue Polish [ "Instytucja" ]
        ]
    , institutions =
        [ LanguageValue Spanish [ "Instituciones" ]
        , LanguageValue Portuguese [ "Instituições" ]
        , LanguageValue German [ "Körperschaften" ]
        , LanguageValue Italian [ "Istituzioni" ]
        , LanguageValue Polish [ "Instytucje" ]
        , LanguageValue English [ "Institutions" ]
        , LanguageValue French [ "Institutions" ]
        ]
    , keywordQuery =
        [ LanguageValue English [ "Keyword query" ]
        , LanguageValue Portuguese [ "Consulta por palavra-chave" ]
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
        , LanguageValue Portuguese [ "Último" ]
        , LanguageValue Polish [ "Ostatni" ]
        ]
    , liturgicalFeasts = []
    , location =
        [ LanguageValue English [ "Location" ]
        , LanguageValue German [ "Ort" ]
        , LanguageValue French [ "Lieu" ]
        , LanguageValue Italian [ "Luogo" ]
        , LanguageValue Spanish [ "Lugar" ]
        , LanguageValue Portuguese [ "Local" ]
        , LanguageValue Polish [ "Lokalizacja" ]
        ]
    , muscatEdit =
        [ LanguageValue English [ "Edit" ]
        , LanguageValue German
            [ "Bearbeiten" ]
        , LanguageValue French
            [ "Modifier" ]
        , LanguageValue Italian
            [ "Modifica" ]
        , LanguageValue Spanish
            [ "Editar" ]
        , LanguageValue Portuguese
            [ "Editar" ]
        , LanguageValue Polish
            [ "Edytuj" ]
        ]
    , muscatView =
        [ LanguageValue English [ "View" ]
        , LanguageValue German
            [ "Ansehen" ]
        , LanguageValue French
            [ "Voir" ]
        , LanguageValue Italian
            [ "Visualizza" ]
        , LanguageValue Spanish
            [ "Ver" ]
        , LanguageValue Portuguese
            [ "Visualizar" ]
        , LanguageValue Polish
            [ "Wyświetl" ]
        ]
    , nearbyInstitutions =
        [ LanguageValue English [ "Nearby institutions" ]
        , LanguageValue German [ "Nahegelegene Körperschaften" ]
        , LanguageValue French [ "Institutions proches" ]
        , LanguageValue Italian [ "Istituzioni vicine" ]
        , LanguageValue Spanish [ "Instituciones cercanas" ]
        , LanguageValue Portuguese [ "Instituições próximas" ]
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
        , LanguageValue Portuguese [ "Próximo" ]
        , LanguageValue Polish [ "Następny" ]
        ]
    , noAdditionalDetails =
        [ LanguageValue English
            [ "No additional details available." ]
        , LanguageValue German
            [ "Keine zusätzlichen Details verfügbar." ]
        , LanguageValue French
            [ "Aucun détail supplémentaire disponible." ]
        , LanguageValue Italian
            [ "Nessun dettaglio aggiuntivo disponibile." ]
        , LanguageValue Spanish
            [ "No hay detalles adicionales disponibles." ]
        , LanguageValue Portuguese
            [ "Nenhum detalhe adicional disponível." ]
        , LanguageValue Polish
            [ "Brak dodatkowych szczegółów." ]
        ]
    , noResultsBody =
        [ LanguageValue English [ "Adjust your query options, or reset all filters, to see results." ]
        , LanguageValue German [ "Passen Sie Ihre Abfrageoptionen an oder setzen Sie alle Filter zurück, um Ergebnisse zu sehen." ]
        , LanguageValue French [ "Ajustez vos options de requête, ou réinitialisez tous les filtres, pour voir les résultats." ]
        , LanguageValue Italian [ "Modifica le opzioni di ricerca o ripristina tutti i filtri per visualizzare nuovi risultati." ]
        , LanguageValue Spanish [ "Ajuste las opciones de consulta, o reinicie todos los filtros, para ver resultados." ]
        , LanguageValue Portuguese [ "Ajuste as opções de sua consulta ou redefina todos os filtros para ver os resultados." ]
        , LanguageValue Polish [ "Dostosuj opcje zapytania lub zresetuj wszystkie filtry, aby zobaczyć wyniki." ]
        ]
    , noResultsHeader =
        [ LanguageValue English [ "No results were found for your {{ recordType }} search" ]
        , LanguageValue German [ "Es wurden keine Ergebnisse für Ihre {{ recordType }}-Suche gefunden" ]
        , LanguageValue French [ "Aucun résultat n’a été trouvé pour votre recherche {{ recordType }}" ]
        , LanguageValue Italian [ "Nessun risultato trovato per la tua ricerca {{ recordType }}" ]
        , LanguageValue Spanish [ "No se encontraron resultados para tu búsqueda de {{ recordType }}" ]
        , LanguageValue Portuguese [ "Nenhum resultado foi encontrado para sua pesquisa de {{ recordType }}" ]
        , LanguageValue Polish [ "Nie znaleziono wyników dla wyszukiwania {{ recordType }}" ]
        ]
    , noResultsWouldBeFound =
        [ LanguageValue English [ "No results would be found with this search" ]
        , LanguageValue German [ "Diese Suche brachte keine Ergebnisse" ]
        , LanguageValue French [ "Aucun résultat pour cette recherche" ]
        , LanguageValue Italian [ "Nessun risultato verrebbe trovato con questa ricerca" ]
        , LanguageValue Spanish [ "No se encontrarían resultados con esta búsqueda" ]
        , LanguageValue Portuguese [ "Nenhum resultado seria encontrado com esta pesquisa" ]
        , LanguageValue Polish [ "Nie znaleziono żadnych wyników dla tego wyszukiwania" ]
        ]
    , notationQueryLength =
        [ LanguageValue English [ "Queries must be longer than three notes" ]
        , LanguageValue German
            [ "Anfragen müssen länger als drei Noten sein" ]
        , LanguageValue French
            [ "Les requêtes doivent contenir plus de trois notes" ]
        , LanguageValue Italian
            [ "Le query devono essere più lunghe di tre note" ]
        , LanguageValue Spanish
            [ "Las consultas deben tener más de tres notas" ]
        , LanguageValue Portuguese
            [ "As consultas devem ter mais de três notas" ]
        , LanguageValue Polish
            [ "Zapytania muszą zawierać więcej niż trzy nuty" ]
        ]
    , numberOfResults =
        [ LanguageValue English [ "Number of results" ]
        , LanguageValue German
            [ "Anzahl der Ergebnisse" ]
        , LanguageValue French
            [ "Nombre de résultats" ]
        , LanguageValue Italian
            [ "Numero di risultati" ]
        , LanguageValue Spanish
            [ "Número de resultados" ]
        , LanguageValue Portuguese
            [ "Número de resultados" ]
        , LanguageValue Polish
            [ "Liczba wyników" ]
        ]
    , optionsWithAnd =
        [ LanguageValue English
            [ "Options are combined with an AND operator" ]
        , LanguageValue German
            [ "Optionen werden mit einem AND-Operator kombiniert" ]
        , LanguageValue French
            [ "Les options sont combinées avec un opérateur AND" ]
        , LanguageValue Italian
            [ "Le opzioni sono combinate con un operatore AND" ]
        , LanguageValue Spanish
            [ "Las opciones se combinan con un operador AND" ]
        , LanguageValue Portuguese
            [ "As opções são combinadas com um operador AND" ]
        , LanguageValue Polish
            [ "Opcje są łączone za pomocą operatora AND" ]
        ]
    , optionsWithOr =
        [ LanguageValue English
            [ "Options are combined with an OR operator" ]
        , LanguageValue German
            [ "Optionen werden mit einem OR-Operator kombiniert" ]
        , LanguageValue French
            [ "Les options sont combinées avec un opérateur OR" ]
        , LanguageValue Italian
            [ "Le opzioni sono combinate con un operatore OR" ]
        , LanguageValue Spanish
            [ "Las opciones se combinan con un operador OR" ]
        , LanguageValue Portuguese
            [ "As opções são combinadas com um operador OR" ]
        , LanguageValue Polish
            [ "Opcje są łączone za pomocą operatora OR" ]
        ]
    , orChooseCollection =
        [ LanguageValue English [ "Or choose a national collection" ]
        , LanguageValue German
            [ "Oder wählen Sie eine nationale Sammlung" ]
        , LanguageValue French
            [ "Ou choisissez une collection nationale" ]
        , LanguageValue Italian
            [ "Oppure scegli una collezione nazionale" ]
        , LanguageValue Spanish
            [ "O elija una colección nacional" ]
        , LanguageValue Portuguese
            [ "Ou escolha uma coleção nacional" ]
        , LanguageValue Polish
            [ "Lub wybierz kolekcję narodową" ]
        ]
    , paeInput =
        [ LanguageValue English [ "Plaine and Easie Input" ] ]
    , page =
        [ LanguageValue English [ "Page" ]
        , LanguageValue German [ "Seite" ]
        , LanguageValue French [ "Page" ]
        , LanguageValue Italian [ "Pagina" ]
        , LanguageValue Spanish [ "Página" ]
        , LanguageValue Portuguese [ "Página" ]
        , LanguageValue Polish [ "Strona" ]
        ]
    , partOf =
        [ LanguageValue English [ "Part of" ] ]
    , partOfCollection =
        [ LanguageValue English
            [ "This record is part of a collection" ]
        , LanguageValue German
            [ "Diese Eintragung ist Teil einer Sammlung" ]
        , LanguageValue French
            [ "Cette notice fait partie d'une collection" ]
        , LanguageValue Italian
            [ "Questa scheda fa parte di una collezione" ]
        , LanguageValue Spanish
            [ "Esta ficha forma parte de una colección" ]
        , LanguageValue Portuguese
            [ "Esta ficha faz parte de uma coleção" ]
        , LanguageValue Polish
            [ "Ta karta katalogowa jest częścią kolekcji" ]
        ]
    , people =
        [ LanguageValue Spanish [ "Personas" ]
        , LanguageValue Portuguese [ "Pessoas" ]
        , LanguageValue German [ "Personen" ]
        , LanguageValue Italian [ "Persone" ]
        , LanguageValue Polish [ "Osoby" ]
        , LanguageValue English [ "People" ]
        , LanguageValue French [ "Personnes" ]
        ]
    , person =
        [ LanguageValue English [ "Person" ]
        , LanguageValue German [ "Person" ]
        , LanguageValue French [ "Personne" ]
        , LanguageValue Italian [ "Persona" ]
        , LanguageValue Spanish [ "Persona" ]
        , LanguageValue Portuguese [ "Pessoa" ]
        , LanguageValue Polish [ "Osoba" ]
        ]
    , place =
        [ LanguageValue English [ "Place" ] ]
    , previous =
        [ LanguageValue English [ "Previous" ]
        , LanguageValue German [ "Vorige" ]
        , LanguageValue French [ "Précédent" ]
        , LanguageValue Italian [ "Precedente" ]
        , LanguageValue Spanish [ "Anterior" ]
        , LanguageValue Portuguese [ "Anterior" ]
        , LanguageValue Polish [ "Poprzedni" ]
        ]
    , queryTerms =
        [ LanguageValue English [ "Query terms" ]
        , LanguageValue German
            [ "Suchbegriffe" ]
        , LanguageValue French
            [ "Termes de requête" ]
        , LanguageValue Italian
            [ "Termini di ricerca" ]
        , LanguageValue Spanish
            [ "Términos de consulta" ]
        , LanguageValue Portuguese
            [ "Termos de consulta" ]
        , LanguageValue Polish
            [ "Terminy zapytania" ]
        ]
    , recordPreview =
        [ LanguageValue English [ "Record preview" ]
        , LanguageValue German [ "Dokumentvorschau" ]
        , LanguageValue French [ "Aperçu de la notice" ]
        , LanguageValue Italian [ "Anteprima la scheda" ]
        , LanguageValue Spanish [ "Vista previa del registro" ]
        , LanguageValue Portuguese [ "Visualizar do registro" ]
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
        , LanguageValue Portuguese [ "Record URI (Permalink)" ]
        , LanguageValue Polish [ "URI rekordu (Odnośnik bezpośredni)" ]
        ]
    , reportAnIssue =
        [ LanguageValue English [ "Report an issue" ]
        , LanguageValue German
            [ "Ein Problem melden" ]
        , LanguageValue French
            [ "Signaler un problème" ]
        , LanguageValue Italian
            [ "Segnala un problema" ]
        , LanguageValue Spanish
            [ "Informar de un problema" ]
        , LanguageValue Portuguese
            [ "Relatar um problema" ]
        , LanguageValue Polish
            [ "Zgłoś problem" ]
        ]
    , resetAll =
        [ LanguageValue English [ "Reset all" ]
        , LanguageValue German [ "Alles zurücksetzen" ]
        , LanguageValue French [ "Effacer tout" ]
        , LanguageValue Italian [ "Resetta tutto" ]
        , LanguageValue Spanish [ "Resetear todo" ]
        , LanguageValue Portuguese [ "Reiniciar tudo" ]
        , LanguageValue Polish [ "Zresetować wszystko" ]
        ]
    , resultsOfOtherTypes =
        [ LanguageValue English [ "No results were found for your {{ recordType }} search but other result types were found" ]
        , LanguageValue German [ "Es wurden keine Ergebnisse für Ihre {{ recordType }}-Suche gefunden, aber andere Ergebnistypen wurden gefunden" ]
        , LanguageValue French [ "Aucun résultat n’a été trouvé pour votre recherche {{ recordType }}, mais d’autres types de résultats ont été trouvés" ]
        , LanguageValue Italian [ "Nessun risultato trovato per la tua ricerca {{ recordType }}, ma sono stati trovati altri tipi di risultati" ]
        , LanguageValue Spanish [ "No se encontraron resultados para tu búsqueda de {{ recordType }}, pero se encontraron otros tipos de resultados" ]
        , LanguageValue Portuguese [ "Nenhum resultado foi encontrado para sua pesquisa de {{ recordType }}, mas foram encontrados outros tipos de resultados" ]
        , LanguageValue Polish [ "Nie znaleziono wyników dla wyszukiwania {{ recordType }}, ale znaleziono inne typy wyników" ]
        ]
    , resultsWereFoundForOthers =
        [ LanguageValue English [ "Results were found for other record types" ]
        , LanguageValue German [ "Ergebnisse wurden für andere Aufzeichnungstypen gefunden" ]
        , LanguageValue French [ "Des résultats ont été trouvés pour d’autres types d’enregistrements" ]
        , LanguageValue Italian [ "Sono stati trovati risultati per altri tipi di record" ]
        , LanguageValue Spanish [ "Se encontraron resultados para otros tipos de registros" ]
        , LanguageValue Portuguese [ "Foram encontrados resultados para outros tipos de registros" ]
        , LanguageValue Polish [ "Znaleziono wyniki dla innych typów rekordów" ]
        ]
    , rowsPerPage =
        [ LanguageValue English [ "Rows per page" ]
        , LanguageValue German
            [ "Zeilen pro Seite" ]
        , LanguageValue French
            [ "Lignes par page" ]
        , LanguageValue Italian
            [ "Righe per pagina" ]
        , LanguageValue Spanish
            [ "Filas por página" ]
        , LanguageValue Portuguese
            [ "Linhas por página" ]
        , LanguageValue Polish
            [ "Wiersze na stronę" ]
        ]
    , search =
        [ LanguageValue English [ "Search" ]
        , LanguageValue German [ "Suche" ]
        , LanguageValue French [ "Chercher" ]
        , LanguageValue Italian [ "Cerca" ]
        , LanguageValue Spanish [ "Búsqueda" ]
        , LanguageValue Portuguese [ "Busca" ]
        , LanguageValue Polish [ "Wyszukiwanie" ]
        ]
    , searchNumberOfRecords =
        [ LanguageValue English [ "Search {{ numberOfRecords }} {{ recordType }}" ] ]
    , seeAll =
        [ LanguageValue English [ "See all" ]
        , LanguageValue German
            [ "Alle anzeigen" ]
        , LanguageValue French
            [ "Voir tout" ]
        , LanguageValue Italian
            [ "Vedi tutto" ]
        , LanguageValue Spanish
            [ "Ver todo" ]
        , LanguageValue Portuguese
            [ "Ver tudo" ]
        , LanguageValue Polish
            [ "Zobacz wszystko" ]
        ]
    , showNumItems =
        [ LanguageValue English [ "Show {{ numItems }} items" ]
        , LanguageValue German
            [ "Zeige {{ numItems }} Einträge" ]
        , LanguageValue French
            [ "Afficher {{ numItems }} éléments" ]
        , LanguageValue Italian
            [ "Mostra {{ numItems }} elementi" ]
        , LanguageValue Spanish
            [ "Mostrar {{ numItems }} elementos" ]
        , LanguageValue Portuguese
            [ "Mostrar {{ numItems }} itens" ]
        , LanguageValue Polish
            [ "Pokaż {{ numItems }} elementów" ]
        ]
    , showResults =
        [ LanguageValue English [ "Show search results" ]
        , LanguageValue German [ "Filter anwenden" ]
        , LanguageValue French [ "Appliquer des filtres" ]
        , LanguageValue Italian [ "Applicare filtri" ]
        , LanguageValue Spanish [ "Aplicar filtros" ]
        , LanguageValue Portuguese [ "Aplicar filtros" ]
        , LanguageValue Polish [ "Zastosuj filtry" ]
        ]
    , sortAlphabetically =
        [ LanguageValue English [ "Sort alphabetically (currently sorted by count)" ]
        , LanguageValue German
            [ "Alphabetisch sortieren (derzeit nach Anzahl sortiert)" ]
        , LanguageValue French
            [ "Trier par ordre alphabétique (actuellement trié par nombre)" ]
        , LanguageValue Italian
            [ "Ordina alfabeticamente (attualmente ordinato per conteggio)" ]
        , LanguageValue Spanish
            [ "Ordenar alfabéticamente (actualmente ordenado por cantidad)" ]
        , LanguageValue Portuguese
            [ "Ordenar alfabeticamente (atualmente ordenado por contagem)" ]
        , LanguageValue Polish
            [ "Sortuj alfabetycznie (obecnie posortowane według liczby)" ]
        ]
    , sortBy =
        [ LanguageValue English [ "Sort by" ]
        , LanguageValue German
            [ "Sortieren nach" ]
        , LanguageValue French
            [ "Trier par" ]
        , LanguageValue Italian
            [ "Ordina per" ]
        , LanguageValue Spanish
            [ "Ordenar por" ]
        , LanguageValue Portuguese
            [ "Ordenar por" ]
        , LanguageValue Polish
            [ "Sortuj według" ]
        ]
    , sortByCount =
        [ LanguageValue English [ "Sort by count (currently sorted alphabetically)" ]
        , LanguageValue German
            [ "Nach Anzahl sortieren (derzeit alphabetisch sortiert)" ]
        , LanguageValue French
            [ "Trier par nombre (actuellement trié par ordre alphabétique)" ]
        , LanguageValue Italian
            [ "Ordina per conteggio (attualmente ordinato alfabeticamente)" ]
        , LanguageValue Spanish
            [ "Ordenar por cantidad (actualmente ordenado alfabéticamente)" ]
        , LanguageValue Portuguese
            [ "Ordenar por contagem (atualmente ordenado alfabeticamente)" ]
        , LanguageValue Polish
            [ "Sortuj według liczby (obecnie posortowane alfabetycznie)" ]
        ]
    , source =
        [ LanguageValue English
            [ "Source" ]
        , LanguageValue German
            [ "Quelle" ]
        , LanguageValue French
            [ "Source" ]
        , LanguageValue Italian
            [ "Fonte" ]
        , LanguageValue Spanish
            [ "Fuente" ]
        , LanguageValue Portuguese
            [ "Fonte" ]
        , LanguageValue Polish
            [ "Źródło" ]
        ]
    , sourceContents =
        [ LanguageValue English [ "Source contents" ]
        , LanguageValue German [ "Inhalt der Quelle" ]
        , LanguageValue French [ "Contenu de la source" ]
        , LanguageValue Italian [ "Contenuto delle fonti" ]
        , LanguageValue Polish [ "Treść źródła" ]
        , LanguageValue Portuguese [ "Conteúdo da fonte" ]
        ]
    , sourceType =
        [ LanguageValue English [ "Source type" ]
        , LanguageValue German
            [ "Quellentyp" ]
        , LanguageValue French
            [ "Type de source" ]
        , LanguageValue Italian
            [ "Tipo di fonte" ]
        , LanguageValue Spanish
            [ "Tipo de fuente" ]
        , LanguageValue Portuguese
            [ "Tipo de fonte" ]
        , LanguageValue Polish
            [ "Typ źródła" ]
        ]
    , sources =
        [ LanguageValue English [ "Sources" ]
        , LanguageValue German [ "Quellen" ]
        , LanguageValue French [ "Sources" ]
        , LanguageValue Italian [ "Fonti" ]
        , LanguageValue Spanish [ "Fuentes" ]
        , LanguageValue Portuguese [ "Fontes" ]
        , LanguageValue Polish [ "Źródła" ]
        ]
    , unknownError =
        [ LanguageValue English [ "An unknown error occurred." ]
        , LanguageValue German
            [ "Ein unbekannter Fehler ist aufgetreten." ]
        , LanguageValue French
            [ "Une erreur inconnue s'est produite." ]
        , LanguageValue Italian
            [ "Si è verificato un errore sconosciuto." ]
        , LanguageValue Spanish
            [ "Se ha producido un error desconocido." ]
        , LanguageValue Portuguese
            [ "Ocorreu um erro desconhecido." ]
        , LanguageValue Polish
            [ "Wystąpił nieznany błąd." ]
        ]
    , updateResults =
        [ LanguageValue English [ "Update search results" ]
        , LanguageValue German [ "Filter anwenden" ]
        , LanguageValue French [ "Appliquer des filtres" ]
        , LanguageValue Italian [ "Applicare filtri" ]
        , LanguageValue Spanish [ "Aplicar filtros" ]
        , LanguageValue Portuguese [ "Aplicar filtros" ]
        , LanguageValue Polish [ "Zastosuj filtry" ]
        ]
    , viewImages =
        [ LanguageValue English [ "View images" ]
        , LanguageValue German
            [ "Bilder anzeigen" ]
        , LanguageValue French
            [ "Voir les images" ]
        , LanguageValue Italian
            [ "Visualizza immagini" ]
        , LanguageValue Spanish
            [ "Ver imágenes" ]
        , LanguageValue Portuguese
            [ "Ver imagens" ]
        , LanguageValue Polish
            [ "Zobacz obrazy" ]
        ]
    , wordsAnywhere =
        [ LanguageValue English [ "Words anywhere" ]
        , LanguageValue German [ "Eingabe Ihrer Anfrage" ]
        , LanguageValue French [ "Entrez votre requête" ]
        , LanguageValue Italian [ "Inserisci la tua richiesta" ]
        , LanguageValue Spanish [ "Introduzca su consulta" ]
        , LanguageValue Portuguese [ "Introduza a sua consulta" ]
        , LanguageValue Polish [ "Wprowadź swoje zapytanie" ]
        ]
    , workCatalogues =
        [ LanguageValue English [ "Work Catalogs" ] ]
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
        , LanguageValue Portuguese [ "Detalhes biográficos" ]
        , LanguageValue Polish [ "Szczegóły biograficzne" ]
        ]
    , clefKeyTime =
        [ LanguageValue English [ "Clef, key signature, time signature" ]
        , LanguageValue German [ "Schlüssel, Tonart, Taktart" ]
        , LanguageValue French [ "Clef, armure, indication de mesure" ]
        , LanguageValue Italian [ "Chiave, tonalità, indicazione metrica" ]
        , LanguageValue Spanish [ "Clave, tonalidad, compás" ]
        , LanguageValue Portuguese [ "Clave, armadura, compasso" ]
        , LanguageValue Polish [ "Klucz, tonacja, metrum" ]
        ]
    , composerComposition =
        [ LanguageValue English [ "Composer and composition" ]
        , LanguageValue German [ "Komponist und Komposition" ]
        , LanguageValue French [ "Compositeur et composition" ]
        , LanguageValue Italian [ "Compositore e composizione" ]
        , LanguageValue Spanish [ "Compositor y composición" ]
        , LanguageValue Portuguese [ "Compositor e composição" ]
        , LanguageValue Polish [ "Kompozytor i utwór" ]
        ]
    , digitizations =
        [ LanguageValue English [ "Digital facsimiles" ]
        , LanguageValue German [ "Digitale Faksimiles" ]
        , LanguageValue French [ "Fac-similés numériques" ]
        , LanguageValue Italian [ "Facsimili digitali" ]
        , LanguageValue Spanish [ "Facsímiles digitales" ]
        , LanguageValue Portuguese [ "Facsimiles digitais" ]
        , LanguageValue Polish [ "Cyfrowe faksymile" ]
        ]
    , holdingInstitutions =
        [ LanguageValue English [ "Holding institutions" ]
        , LanguageValue German [ "Besitzende Institution" ]
        , LanguageValue French [ "Institution de conservation" ]
        , LanguageValue Italian [ "Istituzioni di conservazione" ]
        , LanguageValue Spanish [ "Instituciones participantes" ]
        , LanguageValue Portuguese [ "Instituições responsáveis" ]
        , LanguageValue Polish [ "Instytucje przechowujące" ]
        ]
    , location =
        [ LanguageValue English [ "Location" ]
        , LanguageValue German [ "Ort" ]
        , LanguageValue French [ "Lieu" ]
        , LanguageValue Italian [ "Luogo" ]
        , LanguageValue Spanish [ "Lugar" ]
        , LanguageValue Portuguese [ "Local" ]
        , LanguageValue Polish [ "Lokalizacja" ]
        ]
    , publicationDetails =
        [ LanguageValue English [ "Publication details" ]
        , LanguageValue German [ "Veröffentlichungsinformationen" ]
        , LanguageValue French [ "Détails de publication" ]
        , LanguageValue Italian [ "Dettagli di pubblicazione" ]
        , LanguageValue Spanish [ "Detalles de publicación" ]
        , LanguageValue Portuguese [ "Detalhes da publicação" ]
        , LanguageValue Polish [ "Szczegóły publikacji" ]
        ]
    , results =
        [ LanguageValue English [ "Result types" ]
        , LanguageValue German [ "Ergebnisarten" ]
        , LanguageValue French [ "Types de résultat" ]
        , LanguageValue Italian [ "Tipi di risultato" ]
        , LanguageValue Spanish [ "Tipos de resultado" ]
        , LanguageValue Portuguese [ "Tipos de resultado" ]
        , LanguageValue Polish [ "Rodzaje wyników" ]
        ]
    , roleAndProfession =
        [ LanguageValue English [ "Role and profession" ]
        , LanguageValue German [ "Funktion und Beruf" ]
        , LanguageValue French [ "Rôle et profession" ]
        , LanguageValue Italian [ "Ruolo e professione" ]
        , LanguageValue Spanish [ "Función y profesión" ]
        , LanguageValue Portuguese [ "Papel e profissão" ]
        , LanguageValue Polish [ "Rola i zawód" ]
        ]
    , sourceContents =
        [ LanguageValue English [ "Source contents" ]
        , LanguageValue German [ "Inhalt der Quelle" ]
        , LanguageValue French [ "Contenu de la source" ]
        , LanguageValue Italian [ "Contenuto delle fonti" ]
        , LanguageValue Spanish [ "Contenido de la fuente" ]
        , LanguageValue Portuguese [ "Conteúdo da fonte" ]
        , LanguageValue Polish [ "Zawartość źródła" ]
        ]
    , sourceRelationships =
        [ LanguageValue English [ "Source relationships" ]
        , LanguageValue German [ "Quellen-Beziehungen" ]
        , LanguageValue French [ "Relations de source" ]
        , LanguageValue Italian [ "Relazioni tra fonti" ]
        , LanguageValue Spanish [ "Relaciones de la fuente" ]
        , LanguageValue Portuguese [ "Relações da fonte" ]
        , LanguageValue Polish [ "Relacje między źródłami" ]
        ]
    }


errorMessages :
    { badQuery : LanguageMap
    , notFound : LanguageMap
    , notImplemented : LanguageMap
    , recordDeleted : LanguageMap
    }
errorMessages =
    { badQuery =
        [ LanguageValue English [ "There was a problem with the query" ]
        , LanguageValue German [ "Es gibt ein Problem mit der Abfrage" ]
        , LanguageValue French [ "Il y a eu un problème avec la requête" ]
        , LanguageValue Italian [ "C'è stato un problema con la richiesta" ]
        , LanguageValue Spanish [ "Ha habido un problema con la búsqueda" ]
        , LanguageValue Portuguese [ "Houve um problema com a consulta" ]
        , LanguageValue Polish [ "Wystąpił problem z zapytaniem" ]
        ]
    , notFound =
        [ LanguageValue English [ "The page was not found" ]
        , LanguageValue German [ "Diese Seite wurde nicht gefunden" ]
        , LanguageValue French [ "Page non trouvée" ]
        , LanguageValue Italian [ "Pagina non trovata" ]
        , LanguageValue Spanish [ "¡Ups! No encontramos esta página" ]
        , LanguageValue Portuguese [ "A página não foi encontrada" ]
        , LanguageValue Polish [ "Strona nie została znaleziona" ]
        ]
    , notImplemented =
        [ LanguageValue English [ "This route is known, but a handler for it has not been implemented." ] ]
    , recordDeleted =
        [ LanguageValue English [ "This record used to exist, but it was removed." ] ]
    }
