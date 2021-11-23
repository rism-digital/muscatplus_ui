module Page.Views.ExternalAuthorities exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, fill, fillPortion, link, paddingXY, paragraph, row, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.RecordTypes.ExternalAuthorities exposing (ExternalAuthoritiesSectionBody, ExternalAuthorityBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (label)


viewExternalAuthoritiesSection : Language -> ExternalAuthoritiesSectionBody -> Element msg
viewExternalAuthoritiesSection language extSection =
    row
        [ width fill
        , alignLeft
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , alignTop
            ]
            [ wrappedRow
                [ width fill
                ]
                [ column
                    [ width (fillPortion 1)
                    , alignTop
                    ]
                    [ label language extSection.label ]
                , column
                    [ width (fillPortion 4)
                    , alignTop
                    , spacing 10
                    ]
                    (List.map (viewExternalAuthority language) extSection.items)
                ]
            ]
        ]


viewExternalAuthority : Language -> ExternalAuthorityBody -> Element msg
viewExternalAuthority language authority =
    paragraph
        []
        [ link
            [ linkColour ]
            { url = authority.url
            , label = text (extractLabelFromLanguageMap language authority.label)
            }
        ]
