module Page.About.Views.Help exposing (..)

import Element exposing (Color, Element, centerY, clipY, column, el, fill, height, maximum, padding, paragraph, px, row, scrollbarY, shrink, spacing, table, text, width)
import Element.Background as Background
import Element.Font as Font
import Language exposing (Language(..), LanguageMap, LanguageValue(..), extractLabelFromLanguageMap)
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
    ]


descriptionTranslations : LanguageMap
descriptionTranslations =
    [ LanguageValue English [ "Description" ]
    , LanguageValue French [ "Description" ]
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
            ]
      }
    , { icon = bookOpenCoverSvg
      , bgColor = colourScheme.darkBlue
      , description =
            [ LanguageValue English [ """A single item music manuscript, or a bibliographic record of a print
            with no detailed list of child records.""" ]
            , LanguageValue French [ """Manuscrit musical indépendant, ou notice bibliographique d'un imprimé sans 
            liste détaillée de notices filles.""" ]
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
            ]
      }
    , { icon = bookCopySvg
      , bgColor = colourScheme.darkBlue
      , description =
            [ LanguageValue English [ """A composite volume describing an archival aggregate where several manuscript
            or print items, or collections, have been bound together.""" ]
            , LanguageValue French [ """Un volume composite décrivant un regroupement dans une archive de documents 
            manuscrits ou imprimés, ou de collections, reliés ensemble.""" ]
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
            ]
      }
    , { icon = printingPressSvg
      , bgColor = colourScheme.turquoise
      , description =
            [ LanguageValue English [ "A printed source with holdings in one or more libraries." ]
            , LanguageValue French [ "Source imprimée conservée dans une ou plusieurs bibliothèques." ]
            ]
      }
    , { icon = rectanglesMixedSvg
      , bgColor = colourScheme.turquoise
      , description =
            [ LanguageValue English [ "A source with mixed types (e.g., a composite volume) held in one single library." ]
            , LanguageValue French [ """Une source avec des types mixtes (par exemple, un volume composite) conservée 
            dans une seule bibliothèque.""" ]
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
            ]
      }
    , { icon = commentsSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is a libretto of music work, such as an opera" ]
            , LanguageValue French [ "Le contenu est un livret d’une œuvre musicale, tel qu'un opéra" ]
            ]
      }
    , { icon = graduationCapSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is a treatise that is a theoretical text, with or without music notation examples." ]
            , LanguageValue French [ "Le contenu est un traité qui est un texte théorique, avec ou sans exemples en notation musicale." ]
            ]
      }
    , { icon = shapesSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is mixed and cannot be identified with one category above." ]
            , LanguageValue French [ "Le contenu est mixte et ne peut être identifié à l'une des catégories ci-dessus." ]
            ]
      }
    , { icon = ellipsesSvg
      , bgColor = colourScheme.yellow
      , description =
            [ LanguageValue English [ "The content is of another type (e.g., a map or a drawing)." ]
            , LanguageValue French [ "Le contenu est d'un autre type (par exemple, une carte ou un dessin)." ]
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
            ]
      }
    , { icon = digitizedImagesSvg
      , bgColor = colourScheme.puce
      , description =
            [ LanguageValue English [ """The record includes a link to a digital reproduction of the source. For prints, 
            the link is attached to a specific exemplar, and more than one link can be available.""" ]
            , LanguageValue French [ """La notice comprend un lien vers une reproduction numérique de la source. Pour 
            les imprimés, le lien est attaché à un examplaire spécifique, et plus d'un lien peut être disponible.""" ]
            ]
      }
    , { icon = \_ -> iiifLogo
      , bgColor = colourScheme.lightGrey
      , description =
            [ LanguageValue English [ """The record includes a IIIF manifest. The images will be displayed directly in 
            RISM Online.""" ]
            , LanguageValue French [ """La notice comprend un manifeste IIIF. Les images seront affichées directement 
            dans RISM Online.""" ]
            ]
      }
    , { icon = linkSvg
      , bgColor = colourScheme.olive
      , description =
            [ LanguageValue English [ """The record includes an link to mapped version of the record in another 
            database also included in RISM Online (e.g., DIAMM).""" ]
            , LanguageValue French [ """La notice comprend un lien vers une version correspondante de la notice dans 
            une autre base de données également incluse dans RISM Online (par exemple, DIAMM).""" ]
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


helpTextSourceTypesEnglish : String
helpTextSourceTypesEnglish =
    """## Source types

Source types describe the material characteristics of a source."""


helpTextSourceTypesFrench : String
helpTextSourceTypesFrench =
    """## Types de source
       
Les types de sources décrivent les caractéristiques matérielles d'une source."""


helpTextContentTypesEnglish : String
helpTextContentTypesEnglish =
    """## Content types

The Content type describes the form of the material within a source. A source may have multiple content types."""


helpTextContentTypesFrench : String
helpTextContentTypesFrench =
    """## Types de contenu

Le type de contenu décrit la forme du matériel contenu dans une source. Une source peut avoir plusieurs types de contenu."""


helpTextAdditionalIconsEnglish : String
helpTextAdditionalIconsEnglish =
    """## Additional icons

Some additional icons are used in RISM Online to indicate that records have some specific features."""


helpTextAdditionalIconsFrench : String
helpTextAdditionalIconsFrench =
    """## Icônes supplémentaires
       
Certaines icônes supplémentaires sont utilisées dans RISM Online pour indiquer que les notices ont des caractéristiques spécifiques."""


helpTextSourceDatabasesEnglish : String
helpTextSourceDatabasesEnglish =
    """For the databases also included in RISM Online, the records that have no corresponding RISM record will display
an icon indicting the source of the record."""


helpTextSourceDatabasesFrench : String
helpTextSourceDatabasesFrench =
    """Pour les bases de données également incluses dans RISM Online, les notices qui n'ont pas de notice RISM 
correspondante afficheront une icône indiquant la source de la notice. """


helpTextRecordTypes : LanguageMap
helpTextRecordTypes =
    [ LanguageValue English [ helpTextRecordTypesEnglish ]
    , LanguageValue French [ helpTextRecordTypesFrench ]
    ]


helpTextSourceTypes : LanguageMap
helpTextSourceTypes =
    [ LanguageValue English [ helpTextSourceTypesEnglish ]
    , LanguageValue French [ helpTextSourceTypesFrench ]
    ]


helpTextContentTypes : LanguageMap
helpTextContentTypes =
    [ LanguageValue English [ helpTextContentTypesEnglish ]
    , LanguageValue French [ helpTextContentTypesFrench ]
    ]


helpTextAdditionalIcons : LanguageMap
helpTextAdditionalIcons =
    [ LanguageValue English [ helpTextAdditionalIconsEnglish ]
    , LanguageValue French [ helpTextAdditionalIconsFrench ]
    ]


helpTextSourceDatabases : LanguageMap
helpTextSourceDatabases =
    [ LanguageValue English [ helpTextSourceDatabasesEnglish ]
    , LanguageValue French [ helpTextSourceDatabasesFrench ]
    ]


view : Session -> Element msg
view session =
    row
        [ width fill
        , height fill
        , clipY
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , Background.color colourScheme.white
            , spacing sectionSpacing
            , width (fill |> maximum 900)
            , Font.size 16
            , scrollbarY
            ]
            [ row
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
                                [ LanguageValue English [ "DIAMM (Digital Image Archive of Medieval Music)" ]
                                , LanguageValue French [ "DIAMM (Digital Image Archive of Medieval Music)" ]
                                ]
                          , icon = diammLogo
                          }
                        ]
                    }
                ]
            ]
        ]
