module Page.Views.SearchPage.Previews.Incipit exposing (..)

import Element exposing (Element, column, el, fill, height, link, none, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.UI.Components exposing (h4, viewSummaryField)
import Page.UI.Style exposing (colourScheme)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Incipits exposing (viewIncipit, viewIncipitsSection)


viewIncipitPreview : IncipitBody -> Language -> Element msg
viewIncipitPreview body language =
    let
        incipitLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ Font.color colourScheme.lightBlue ]
                    { url = body.id
                    , label = text body.id
                    }
                ]
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 10
            ]
            [ row
                [ width fill ]
                [ h4 language body.label ]
            , incipitLink
            , row
                [ width fill ]
                [ column
                    [ width fill
                    ]
                    [ viewMaybe (viewIncipit language) (Just body) ]
                ]
            ]
        ]
