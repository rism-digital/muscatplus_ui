module Page.Views.SearchPage.Previews.Institution exposing (..)

import Element exposing (Element, column, el, fill, height, link, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Components exposing (h4)
import Page.UI.Style exposing (colourScheme)


viewInstitutionPreview : InstitutionBody -> Language -> Element msg
viewInstitutionPreview body language =
    let
        institutionLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ Font.color colourScheme.lightBlue ]
                    { url = body.id, label = text body.id }
                ]
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 5
            ]
            [ row
                [ width fill ]
                [ h4 language body.label ]
            , institutionLink
            ]
        ]
