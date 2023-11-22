module Page.About.Views.Options exposing (view)

import Element exposing (Element, clipY, column, el, fill, height, maximum, padding, paragraph, row, scrollbarY, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Font as Font
import Language exposing (Language(..), extractLabelFromLanguageMap, toLanguageMapWithLanguage)
import Page.About.Model exposing (AboutPageModel)
import Page.About.Msg exposing (AboutMsg(..))
import Page.UI.Attributes exposing (lineSpacing, sectionSpacing)
import Page.UI.Facets.Toggle as Toggle
import Page.UI.Markdown as Markdown
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


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
                    (toLanguageMapWithLanguage English "Viewing Options"
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
                    (toLanguageMapWithLanguage English "Link with Muscat"
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
                    [ toLanguageMapWithLanguage English """Activating this control will put links to the Muscat records in the footer
                                         of every record. You will still need a Muscat account and permissions to view or edit the
                                         records. """
                        |> Markdown.view session.language
                    , paragraph
                        [ width fill
                        , Font.bold
                        ]
                        [ text "Please refresh your browser after activating." ]
                    , paragraph
                        [ width fill ]
                        [ Toggle.view model.linksEnabled UserToggledEnableMuscatLinks
                            |> Toggle.setLabel "Enable Muscat Links"
                            |> Toggle.render
                            |> el []
                        ]
                    ]
                ]
            ]
        ]
