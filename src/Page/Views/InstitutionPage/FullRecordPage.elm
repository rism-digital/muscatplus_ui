module Page.Views.InstitutionPage.FullRecordPage exposing (..)

import Element exposing (Element, column, el, fill, height, link, none, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg)
import Page.RecordTypes.Institution exposing (InstitutionBody)
import Page.UI.Components exposing (h4)
import Page.UI.Style exposing (colourScheme)
import Page.Views.ExternalAuthorities exposing (viewExternalAuthoritiesSection)
import Page.Views.Helpers exposing (viewMaybe)


viewFullInstitutionPage : Language -> InstitutionBody -> Element Msg
viewFullInstitutionPage language body =
    let
        recordUri =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.recordURI ++ ": "))
                , link
                    [ Font.color colourScheme.lightBlue ]
                    { url = body.id
                    , label = text body.id
                    }
                ]

        extAuthorities =
            viewMaybe (viewExternalAuthoritiesSection language) body.externalAuthorities
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
            , recordUri
            , extAuthorities
            ]
        ]
