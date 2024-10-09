module Desktop.About.Help exposing (IconDescriptionData, view)

import Element exposing (Color, Element, centerY, clipY, column, el, fill, height, htmlAttribute, maximum, padding, paragraph, px, row, scrollbarY, shrink, spacing, table, text, width)
import Element.Background as Background
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (Language(..), LanguageMap, LanguageValue(..), extractLabelFromLanguageMap, toLanguageMapWithLanguage)
import Page.UI.Attributes exposing (sectionSpacing)
import Page.UI.DiammLogo exposing (diammLogo)
import Page.UI.Images exposing (bookCopySvg, bookOpenCoverSvg, bookOpenSvg, bookSvg, commentsSvg, digitizedImagesSvg, ellipsesSvg, fileMusicSvg, graduationCapSvg, iiifLogo, linkSvg, musicNotationSvg, penNibSvg, printingPressSvg, rectanglesMixedSvg, shapesSvg)
import Page.UI.Markdown as Markdown
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


type alias IconDescriptionData msg =
    { icon : Color -> Element msg
    , bgColor : Color
    , description : LanguageMap
    }


iconTranslations : LanguageMap
iconTranslations =
    [ LanguageValue English [ "Icon" ]
    , LanguageValue French [ "Icône" ]
    , LanguageValue German [ "Symbol" ]
    , LanguageValue Italian [ "Icona" ]
    ]


descriptionTranslations : LanguageMap
descriptionTranslations =
    [ LanguageValue English [ "Description" ]
    , LanguageValue French [ "Description" ]
    , LanguageValue German [ "Beschreibung" ]
    , LanguageValue Italian [ "Descrizione" ]
    ]


recordTypesEntries : List (IconDescriptionData msg)
recordTypesEntries =
    [ { icon = bookSvg
      , bgColor = colourScheme.darkBlue
      , description =
            [ LanguageValue English [ """A manuscript collection containing different manuscript content items, or the
            bibliographic record of a print. The content of the manuscript collection or the print is detailed with a
            list of child records that can be searched from the source record. (A few manuscript collections, however,
            do not yet have their contents catalogued.""" ]
            , LanguageValue French [ """Une collection de manuscrits contenant différents éléments manuscrits, ou la 
            notice bibliographique d'un imprimé. Le contenu de la collection de manuscrits ou de l'imprimé est 
            détaillé avec une liste de notices filles qui peuvent être recherchées à partir de la notice source. (Le 
            contenu de quelques collections de manuscrits n'a cependant pas encore été catalogué).""" ]
            , LanguageValue German [ """Manuskriptsammlung, die verschiedene Einzelwerke enthält oder bibliografischer
            Datensatz eines Drucks. Der Inhalt der Handschriftensammlung oder des Drucks wird als Liste von
            untergeordneten Datensätzen aufgeführt, die vom Sammeldatensatz aus durchsucht werden können. Bei einigen
            wenigen Sammlungen ist der Inhalt jedoch noch nicht katalogisiert.""" ]
            , LanguageValue Italian [ """Una raccolta contenente diverse composizioni manoscritte, oppure una scheda 
            bibliografica di una edizione musicale a stampa. Il contenuto della raccolta manoscritta o della stampa è 
            dettagliato con un elenco di schede figlie che può essere consultato all’interno della scheda di origine. 
            (Si noti che di alcune raccolte manoscritte non è ancora stato catalogato il contenuto.)""" ]
            ]
      }
    , { icon = bookOpenCoverSvg
      , bgColor = colourScheme.darkBlue
      , description =
            [ LanguageValue English [ """A single item music manuscript, or a bibliographic record of a print
            with no detailed list of child records.""" ]
            , LanguageValue French [ """Manuscrit musical indépendant, ou notice bibliographique d'un imprimé sans 
            liste détaillée de notices filles.""" ]
            , LanguageValue German [ """Individualeintrag einer Musikhandschrift oder des bibliographischen Datensatzes 
            eines Drucks ohne detaillierte Liste von Untereinträgen.""" ]
            , LanguageValue Italian [ """Un singolo manoscritto musicale, o una scheda bibliografica di una edizione 
            musicale a stampa priva di un elenco dettagliato di schede figlie.""" ]
            ]
      }
    , { icon = bookOpenSvg
      , bgColor = colourScheme.darkBlue
      , description =
            [ LanguageValue English [ """A content item within a manuscript collection or within a
            print. The record always belongs to a parent, either a manuscript collection or a bibliographic record of a
            print.""" ]
            , LanguageValue French [ """Un élément contenu dans une collection de manuscrits ou dans un imprimé. La 
            notice appartient toujours à un parent, soit une collection de manuscrits, soit une notice 
            bibliographique d'un imprimé.""" ]
            , LanguageValue German [ """Teileintrag einer Manuskriptsammlung oder eines Drucks. Der Datensatz ist stets 
            mit einem übergeordneten Sammeleintrag (Manuskript oder Druck) verknüpft.""" ]
            , LanguageValue Italian [ """Un elemento di contenuto all'interno di una raccolta manoscritta o
            all'interno di una edizione musicale a stampa. Una tale scheda appartiene sempre a una scheda madre,
            ovvero a una raccolta manoscritta o a una scheda bibliografica di una edizione musicale a stampa.""" ]
            ]
      }
    , { icon = bookCopySvg
      , bgColor = colourScheme.darkBlue
      , description =
            [ LanguageValue English [ """A composite volume describing an archival aggregate where several manuscript
            or print items, or collections, have been bound together.""" ]
            , LanguageValue French [ """Un volume composite décrivant un regroupement dans une archive de documents 
            manuscrits ou imprimés, ou de collections, reliés ensemble.""" ]
            , LanguageValue German [ """Konvolut, in dem mehrere Manuskripte, Drucke oder Sammlungen zusammengebunden 
            sind. """ ]
            , LanguageValue Italian [ """Un volume composito che descrive un aggregato archivistico in cui diverse 
            unità bibliografiche manoscritte o stampate, e/o diverse raccolte, sono state rilegate insieme.""" ]
            ]
      }
    ]


sourceTypesEntries : List (IconDescriptionData msg)
sourceTypesEntries =
    [ { icon = penNibSvg
      , bgColor = colourScheme.turquoise
      , description =
            [ LanguageValue English [ "A handwritten manuscript source held in one single library." ]
            , LanguageValue French [ "Source manuscrite conservée dans une seule bibliothèque." ]
            , LanguageValue German [ "Handschriftliche Quelle, die in einer einzigen Bibliothek aufbewahrt wird." ]
            , LanguageValue Italian [ "Una fonte manoscritta conservata in una singola biblioteca." ]
            ]
      }
    , { icon = printingPressSvg
      , bgColor = colourScheme.turquoise
      , description =
            [ LanguageValue English [ "A printed source with holdings in one or more libraries." ]
            , LanguageValue French [ "Source imprimée conservée dans une ou plusieurs bibliothèques." ]
            , LanguageValue German [ "Gedruckte Quelle, die in einer oder mehreren Bibliotheken aufbewahrt wird." ]
            , LanguageValue Italian [ "Una fonte stampata in possesso di una o più biblioteche." ]
            ]
      }
    , { icon = rectanglesMixedSvg
      , bgColor = colourScheme.turquoise
      , description =
            [ LanguageValue English [ "A source with mixed types (e.g., a composite volume) held in one single library." ]
            , LanguageValue French [ """Une source avec des types mixtes (par exemple, un volume composite) conservée 
            dans une seule bibliothèque.""" ]
            , LanguageValue German [ """Quelle mit gemischten Materialien (z. B. ein Konvolut), die in einer einzigen 
            Bibliothek aufbewahrt wird.""" ]
            , LanguageValue Italian [ """Una fonte di tipo misto (ad esempio, un volume composito) conservata in una 
            singola biblioteca.""" ]
            ]
      }
    ]


contentTypesEntries : List (IconDescriptionData msg)
contentTypesEntries =
    [ { icon = fileMusicSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is music notation (e.g., staff notation, tablature notation)." ]
            , LanguageValue French [ """Le contenu est de la notation musicale (par exemple, de la notation en portées, 
            de la notation en tablature).""" ]
            , LanguageValue German [ "Der Inhalt besteht aus Musiknoten, z. B. übliches Notensystem, Tabulatur etc." ]
            , LanguageValue Italian [ "La fonte contiene notazione musicale (ad esempio, notazione su pentagramma o intavolatura)." ]
            ]
      }
    , { icon = commentsSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is a libretto of music work, such as an opera" ]
            , LanguageValue French [ "Le contenu est un livret d’une œuvre musicale, tel qu'un opéra" ]
            , LanguageValue German [ "Der Inhalt besteht aus dem Libretto zu einem musikdramatischen Werk, z. B. zu einer Oper." ]
            , LanguageValue Italian [ "La fonte contiene il libretto di una composizione musicale, ad esempio un melodramma." ]
            ]
      }
    , { icon = graduationCapSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is a treatise that is a theoretical text, with or without music notation examples." ]
            , LanguageValue French [ "Le contenu est un traité qui est un texte théorique, avec ou sans exemples en notation musicale." ]
            , LanguageValue German [ "Der Inhalt besteht aus einer musiktheoretischen Abhandlung, mit oder ohne Notationsbeispiele." ]
            , LanguageValue Italian [ "La fonte contiene il testo di un trattato di teoria, con o senza esempi di notazione musicale." ]
            ]
      }
    , { icon = shapesSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is mixed and cannot be identified with one category above." ]
            , LanguageValue French [ "Le contenu est mixte et ne peut être identifié à l'une des catégories ci-dessus." ]
            , LanguageValue German [ "Der Inhalt ist gemischt und kann nicht einer der oben genannten Kategorien zugeordnet werden." ]
            , LanguageValue Italian [ "Il contenuto è misto e non può essere identificato con una delle categorie sopra elencate." ]
            ]
      }
    , { icon = ellipsesSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is of another type (e.g., a map or a drawing)." ]
            , LanguageValue French [ "Le contenu est d'un autre type (par exemple, une carte ou un dessin)." ]
            , LanguageValue German [ "Der Inhalt ist von anderer Art (z. B. eine Karte oder eine Zeichnung)." ]
            , LanguageValue Italian [ "Il contenuto è di altro tipo (ad esempio, una mappa o un disegno)." ]
            ]
      }
    ]


additionalIconsEntries : List (IconDescriptionData msg)
additionalIconsEntries =
    [ { icon = musicNotationSvg
      , bgColor = colourScheme.red
      , description =
            [ LanguageValue English [ "The record includes one or more musical incipits." ]
            , LanguageValue French [ "La notice comprend un ou plusieurs incipits musicaux." ]
            , LanguageValue German [ "Der Datensatz enthält ein oder mehrere Musikincipits." ]
            , LanguageValue Italian [ "La scheda comprende uno o più incipit musicali." ]
            ]
      }
    , { icon = digitizedImagesSvg
      , bgColor = colourScheme.puce
      , description =
            [ LanguageValue English [ """The record includes a link to a digital reproduction of the source. For prints, 
            the link is attached to a specific exemplar, and more than one link can be available.""" ]
            , LanguageValue French [ """La notice comprend un lien vers une reproduction numérique de la source. Pour 
            les imprimés, le lien est attaché à un examplaire spécifique, et plus d'un lien peut être disponible.""" ]
            , LanguageValue German [ """Der Datensatz enthält einen Link zu einer digitalen Reproduktion der Quelle. 
            Bei Drucken ist der Link an ein spezifisches Exemplar angehängt. Entsprechend können mehrere Links zu 
            Digitalisaten vorhanden sein.""" ]
            , LanguageValue Italian [ """La scheda comprende un collegamento a una riproduzione digitale della fonte. 
            Per le edizioni musicali a stampa, il collegamento si riferisce a un singolo esemplare, e possono essere 
            disponibili più collegamenti a riproduzioni di differenti esemplari della medesima edizione.""" ]
            ]
      }
    , { icon = \_ -> iiifLogo
      , bgColor = colourScheme.lightGrey
      , description =
            [ LanguageValue English [ """The record includes a IIIF manifest. The images will be displayed directly in 
            RISM Online.""" ]
            , LanguageValue French [ """La notice comprend un manifeste IIIF. Les images seront affichées directement 
            dans RISM Online.""" ]
            , LanguageValue German [ """Der Datensatz enthält einen IIIF-Link. Die Bilder werden direkt in RISM Online angezeigt.""" ]
            , LanguageValue Italian [ """La scheda comprende un manifesto IIIF. Le immagini verranno visualizzate direttamente in RISM Online.""" ]
            ]
      }
    , { icon = linkSvg
      , bgColor = colourScheme.olive
      , description =
            [ LanguageValue English [ """The record includes a link to a corresponding record in another
            database also included in RISM Online (e.g., DIAMM).""" ]
            , LanguageValue French [ """La notice comprend un lien vers une version correspondante de la notice dans 
            une autre base de données également incluse dans RISM Online (par exemple, DIAMM).""" ]
            , LanguageValue German [ """Der Datensatz enthält einen Link zu einer weiteren Version des Datensatzes in 
            einer anderen Datenbank, die ebenfalls in RISM Online enthalten ist (z. B. DIAMM).""" ]
            , LanguageValue Italian [ """Der Datensatz enthält einen Link zu einer abgebildeten Version des Datensatzes
             in einer anderen Datenbank, die ebenfalls in RISM Online enthalten ist (z. B. DIAMM).""" ]
            ]
      }
    ]


iconDescriptionTable :
    { data : List (IconDescriptionData msg)
    , language : Language
    }
    -> Element msg
iconDescriptionTable cfg =
    table
        [ width fill
        , spacing 10
        ]
        { columns =
            [ { header =
                    el
                        [ Font.medium
                        , Background.color colourScheme.lightGrey
                        , padding 10
                        ]
                        (text (extractLabelFromLanguageMap cfg.language iconTranslations))
              , width = shrink
              , view =
                    \i ->
                        el
                            [ width (px 35)
                            , height (px 35)
                            , padding 5
                            , width shrink
                            , Background.color i.bgColor
                            , centerY
                            ]
                            (i.icon colourScheme.white)
              }
            , { header =
                    el
                        [ Font.medium
                        , Background.color colourScheme.lightGrey
                        , padding 10
                        ]
                        (text (extractLabelFromLanguageMap cfg.language descriptionTranslations))
              , width = fill
              , view = \i -> paragraph [ padding 10 ] [ text (extractLabelFromLanguageMap cfg.language i.description) ]
              }
            ]
        , data = cfg.data
        }


helpTextRecordTypesEnglish : String
helpTextRecordTypesEnglish =
    """## Record types

The RISM database has different record types to indicate whether a record is a description of a collection (i.e., with
child records), a single item, the content of a collection, or a composite volume. RISM Online shows different icons
to differentiate these record types in the search result list."""


helpTextRecordTypesFrench : String
helpTextRecordTypesFrench =
    """## Types de notice
              
La base de données du RISM comporte différents types de notices pour indiquer s'il s'agit d'une description
d'une collection (c'est-à-dire avec des notices filles), d'un manuscrit indépendant, d'un élément d'une
collection ou d'un volume composite. RISM Online affiche différentes icônes pour différencier ces types de
notices dans la liste des résultats de la recherche."""


helpTextRecordTypesGerman : String
helpTextRecordTypesGerman =
    """## Datensatztypen

In der RISM-Datenbank gibt es verschiedene Datensatztypen, die je nach vorhandener Quelle angeben, ob es sich bei
einem Datensatz um die Beschreibung einer Sammlung (d. h. mit untergeordneten Datensätzen), einen einzelnen Eintrag,
den Inhalt einer Sammlung oder ein Konvolut handelt. RISM Online zeigt verschiedene Symbole zur Unterscheidung dieser
Eintragstypen in der Ergebnisliste an.
"""


helpTextRecordTypesItalian : String
helpTextRecordTypesItalian =
    """## Tipi di schede

Il database RISM ha diversi tipi di schede per indicare se si tratta della descrizione di una raccolta (ovvero,
con schede figlie), di un singolo elemento, del contenuto di una raccolta o di un volume composito. RISM Online
mostra icone diverse per differenziare questi tipi di schede nell'elenco dei risultati di una ricerca.
"""


helpTextSourceTypesEnglish : String
helpTextSourceTypesEnglish =
    """## Source types

Source types describe the material characteristics of a source."""


helpTextSourceTypesFrench : String
helpTextSourceTypesFrench =
    """## Types de source
       
Les types de sources décrivent les caractéristiques matérielles d'une source."""


helpTextSourceTypesGerman : String
helpTextSourceTypesGerman =
    """## Quellentypen

Quellentypen beschreiben die materiellen Eigenschaften einer Quelle."""


helpTextSourceTypesItalian : String
helpTextSourceTypesItalian =
    """## Tipi di fonte

I tipi di fonte descrivono le caratteristiche materiali di una fonte."""


helpTextContentTypesEnglish : String
helpTextContentTypesEnglish =
    """## Content types

The Content type describes the form of the material within a source. A source may have multiple content types."""


helpTextContentTypesFrench : String
helpTextContentTypesFrench =
    """## Types de contenu

Le type de contenu décrit la forme du matériel contenu dans une source. Une source peut avoir plusieurs types de contenu."""


helpTextContentTypesGerman : String
helpTextContentTypesGerman =
    """## Inhaltstypen

Der Inhaltstyp beschreibt die Form des Materials innerhalb einer Quelle. Eine Quelle kann mehrere Inhaltstypen aufweisen."""


helpTextContentTypesItalian : String
helpTextContentTypesItalian =
    """## Tipi di contenuto

Il tipo di contenuto descrive la forma del materiale all'interno di una fonte. Una fonte può riunire diversi tipi di contenuto."""


helpTextAdditionalIconsEnglish : String
helpTextAdditionalIconsEnglish =
    """## Additional icons

Some additional icons are used in RISM Online to indicate that records have some specific features."""


helpTextAdditionalIconsFrench : String
helpTextAdditionalIconsFrench =
    """## Icônes supplémentaires
       
Certaines icônes supplémentaires sont utilisées dans RISM Online pour indiquer que les notices ont des caractéristiques spécifiques."""


helpTextAdditionalIconsGerman : String
helpTextAdditionalIconsGerman =
    """## Zusätzliche Symbole

In RISM Online werden einige zusätzliche Symbole verwendet, um spezifische Merkmale innerhalb der Datensätze anzuzeigen."""


helpTextAdditionalIconsItalian : String
helpTextAdditionalIconsItalian =
    """## Icone supplementari

RISM Online utilizza delle icone per indicare alcune caratteristiche specifiche delle singole schede."""


helpTextSourceDatabasesEnglish : String
helpTextSourceDatabasesEnglish =
    """For the databases also included in RISM Online, the records that have no corresponding RISM record will display
an icon indicting the source of the record."""


helpTextSourceDatabasesFrench : String
helpTextSourceDatabasesFrench =
    """Pour les bases de données également incluses dans RISM Online, les notices qui n'ont pas de notice RISM 
correspondante afficheront une icône indiquant la source de la notice. """


helpTextSourceDatabasesGerman : String
helpTextSourceDatabasesGerman =
    """Bei den ebenfalls in RISM Online enthaltenen Datenbanken wird für die Datensätze, die keinen entsprechenden
RISM-Eintrag haben, ein Symbol angezeigt, das den Quelldatensatz angibt."""


helpTextSourceDatabasesItalian : String
helpTextSourceDatabasesItalian =
    """Le schede delle banche dati esterne incluse in RISM Online che non hanno una scheda RISM corrispondente
riportano un'icona che ne indica l’origine."""


helpTextRecordTypes : LanguageMap
helpTextRecordTypes =
    [ LanguageValue English [ helpTextRecordTypesEnglish ]
    , LanguageValue French [ helpTextRecordTypesFrench ]
    , LanguageValue German [ helpTextRecordTypesGerman ]
    , LanguageValue Italian [ helpTextRecordTypesItalian ]
    ]


helpTextSourceTypes : LanguageMap
helpTextSourceTypes =
    [ LanguageValue English [ helpTextSourceTypesEnglish ]
    , LanguageValue French [ helpTextSourceTypesFrench ]
    , LanguageValue German [ helpTextSourceTypesGerman ]
    , LanguageValue Italian [ helpTextSourceTypesItalian ]
    ]


helpTextContentTypes : LanguageMap
helpTextContentTypes =
    [ LanguageValue English [ helpTextContentTypesEnglish ]
    , LanguageValue French [ helpTextContentTypesFrench ]
    , LanguageValue German [ helpTextContentTypesGerman ]
    , LanguageValue Italian [ helpTextContentTypesItalian ]
    ]


helpTextAdditionalIcons : LanguageMap
helpTextAdditionalIcons =
    [ LanguageValue English [ helpTextAdditionalIconsEnglish ]
    , LanguageValue French [ helpTextAdditionalIconsFrench ]
    , LanguageValue German [ helpTextAdditionalIconsGerman ]
    , LanguageValue Italian [ helpTextAdditionalIconsItalian ]
    ]


helpTextSourceDatabases : LanguageMap
helpTextSourceDatabases =
    [ LanguageValue English [ helpTextSourceDatabasesEnglish ]
    , LanguageValue French [ helpTextSourceDatabasesFrench ]
    , LanguageValue German [ helpTextSourceDatabasesGerman ]
    , LanguageValue Italian [ helpTextSourceDatabasesItalian ]
    ]


view : Session -> Element msg
view session =
    row
        [ width fill
        , height fill
        , clipY
        ]
        [ column
            [ width (fill |> maximum 900)
            , height fill
            , padding 20
            , Background.color colourScheme.white
            , spacing sectionSpacing
            , Font.size 16
            , scrollbarY
            , htmlAttribute (HA.style "min-height" "unset")
            ]
            [ row
                [ width fill
                , Font.size 36
                , Font.medium
                ]
                [ toLanguageMapWithLanguage English "RISM Online Help"
                    |> extractLabelFromLanguageMap session.language
                    |> text
                ]
            , row
                [ width fill ]
                [ Markdown.view session.language helpTextRecordTypes
                ]
            , row
                [ width fill ]
                [ iconDescriptionTable
                    { data = recordTypesEntries
                    , language = session.language
                    }
                ]
            , row
                [ width fill ]
                [ Markdown.view session.language helpTextSourceTypes ]
            , row
                [ width fill ]
                [ iconDescriptionTable
                    { data = sourceTypesEntries
                    , language = session.language
                    }
                ]
            , row
                [ width fill ]
                [ Markdown.view session.language helpTextContentTypes ]
            , row
                [ width fill ]
                [ iconDescriptionTable
                    { data = contentTypesEntries
                    , language = session.language
                    }
                ]
            , row
                [ width fill ]
                [ Markdown.view session.language helpTextAdditionalIcons ]
            , row
                [ width fill ]
                [ iconDescriptionTable
                    { data = additionalIconsEntries
                    , language = session.language
                    }
                ]
            , row
                [ width fill ]
                [ Markdown.view session.language helpTextSourceDatabases ]
            , row
                [ width fill ]
                [ table
                    [ width fill
                    , spacing 10
                    ]
                    { columns =
                        [ { header =
                                el
                                    [ Font.medium
                                    , Background.color colourScheme.lightGrey
                                    , padding 10
                                    ]
                                    (text (extractLabelFromLanguageMap session.language iconTranslations))
                          , width = fill
                          , view =
                                \i ->
                                    el
                                        [ height (px 60)
                                        , centerY
                                        ]
                                        i.icon
                          }
                        , { header =
                                el
                                    [ Font.medium
                                    , Background.color colourScheme.lightGrey
                                    , padding 10
                                    ]
                                    (text (extractLabelFromLanguageMap session.language descriptionTranslations))
                          , width = shrink
                          , view = \i -> paragraph [ padding 10 ] [ text (extractLabelFromLanguageMap session.language i.description) ]
                          }
                        ]
                    , data =
                        [ { description =
                                [ LanguageValue None [ "DIAMM (Digital Image Archive of Medieval Music)" ]
                                ]
                          , icon = diammLogo
                          }
                        ]
                    }
                ]
            ]
        ]
