module Desktop.About.Views.Options exposing (view)

import Element exposing (Element, clipY, column, el, fill, height, maximum, padding, paragraph, row, scrollbarY, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Font as Font
import Language exposing (Language(..), LanguageMap, LanguageValue(..), extractLabelFromLanguageMap)
import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg(..))
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Facets.Toggle as Toggle
import Page.UI.Markdown as Markdown
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


viewingOptionsLabel : LanguageMap
viewingOptionsLabel =
    [ LanguageValue English [ "Viewing Options" ]
    , LanguageValue German [ "Ansichtsoptionen" ]
    , LanguageValue Italian [ "Opzioni di visualizzazione" ]
    , LanguageValue French [ "Options de visualisation" ]
    ]


linkWithMuscatLabel : LanguageMap
linkWithMuscatLabel =
    [ LanguageValue English [ "Link with Muscat" ]
    , LanguageValue German [ "Verlinkung mit Muscat" ]
    , LanguageValue Italian [ "Collegamento a Muscat" ]
    , LanguageValue French [ "Liens vers Muscat" ]
    ]


muscatViewDescription : LanguageMap
muscatViewDescription =
    [ LanguageValue English [ """For RISM contributors, activating this control will put links to the Muscat records in the footer
    of every record. You will still need a Muscat account and permissions to view or edit the
    records.""" ]
    , LanguageValue French [ """En activant ce bouton, des liens vers les notices Muscat seront placés dans le pied de
    page de chaque notice. Vous aurez toujours besoin d'un compte Muscat et de permissions pour voir ou éditer
    les enregistrements.""" ]
    , LanguageValue German [ """Für RISM-Mitarbeiter werden durch die Aktivierung dieses Steuerelements Links zu den
    Muscat-Datensätzen in der Fußzeile jedes Datensatzes angezeigt. Sie benötigen einen Muscat-Account und die
    Berechtigung, Datensätze anzuzeigen oder zu bearbeiten.""" ]
    , LanguageValue Italian [ """Attivando questo comando, verranno inseriti in basso alla pagina di ciascuna scheda 
    i collegamenti alle schede corrispondenti in Muscat. Sarà in ogni caso necessario un account Muscat e le relative 
    autorizzazioni per visualizzare o modificare le schede.""" ]
    ]


pleaseRefresh : LanguageMap
pleaseRefresh =
    [ LanguageValue English [ "Please refresh your browser after activating." ]
    , LanguageValue German [ "Bitte aktualisieren Sie Ihren Browser nach der Aktivierung." ]
    , LanguageValue French [ "Veuillez rafraîchir votre navigateur après l'activation." ]
    , LanguageValue Italian [ "Aggiorna il tuo browser dopo l'attivazione." ]
    ]


toggleLabel : LanguageMap
toggleLabel =
    [ LanguageValue English [ "Enable Muscat Links" ]
    , LanguageValue German [ "Muscat Links aktivieren" ]
    , LanguageValue French [ "Activer les liens vers Muscat" ]
    , LanguageValue Italian [ "Attiva i collegamenti Muscat" ]
    ]


view : Session -> AboutPageModel -> Element AboutMsg
view session model =
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
            , scrollbarY
            ]
            [ row
                [ width fill ]
                [ el
                    [ Font.medium
                    , Font.size 36
                    ]
                    (viewingOptionsLabel
                        |> extractLabelFromLanguageMap session.language
                        |> text
                    )
                ]
            , row
                [ width fill ]
                [ el
                    [ Font.medium
                    , Font.size 24
                    ]
                    (linkWithMuscatLabel
                        |> extractLabelFromLanguageMap session.language
                        |> text
                    )
                ]
            , row
                [ width (fill |> maximum 900) ]
                [ textColumn
                    [ width fill
                    , spacing lineSpacing
                    ]
                    [ muscatViewDescription
                        |> Markdown.view session.language
                    , paragraph
                        [ width fill
                        , Font.bold
                        ]
                        [ pleaseRefresh
                            |> extractLabelFromLanguageMap session.language
                            |> text
                        ]
                    , paragraph
                        [ width fill ]
                        [ Toggle.view model.linksEnabled UserToggledEnableMuscatLinks
                            |> Toggle.setLabel (extractLabelFromLanguageMap session.language toggleLabel)
                            |> Toggle.render
                            |> el []
                        ]
                    ]
                ]
            ]
        ]
