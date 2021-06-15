module Page.Views.ExternalAuthorities exposing (..)

import Element exposing (Element, alignLeft, column, el, fill, link, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.RecordTypes.ExternalAuthorities exposing (ExternalAuthoritiesSectionBody, ExternalAuthorityBody)
import Page.UI.Attributes exposing (linkColour)


viewExternalAuthoritiesSection : Language -> ExternalAuthoritiesSectionBody -> Element Msg
viewExternalAuthoritiesSection language extSection =
    row
        [ width fill
        , alignLeft
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            ]
            [ row
                [ spacing 20
                ]
                (el
                    [ Font.semiBold ]
                    (text (extractLabelFromLanguageMap language extSection.label))
                    :: List.map (\a -> viewExternalAuthority language a) extSection.items
                )
            ]
        ]


viewExternalAuthority : Language -> ExternalAuthorityBody -> Element Msg
viewExternalAuthority language authority =
    link
        [ linkColour ]
        { url = authority.url
        , label = text (extractLabelFromLanguageMap language authority.label)
        }
