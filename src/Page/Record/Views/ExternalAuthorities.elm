module Page.Record.Views.ExternalAuthorities exposing (..)

import Element exposing (Element, column, link, row, spacing, text, textColumn, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.RecordTypes.ExternalAuthorities exposing (ExternalAuthoritiesSectionBody, ExternalAuthorityBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes, widthFillHeightFill)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel)


viewExternalAuthoritiesSection : Language -> ExternalAuthoritiesSectionBody -> Element msg
viewExternalAuthoritiesSection language extSection =
    row
        (List.concat [ widthFillHeightFill, sectionBorderStyles ])
        [ column
            (List.append [ spacing lineSpacing ] widthFillHeightFill)
            [ fieldValueWrapper
                [ wrappedRow
                    widthFillHeightFill
                    [ column
                        labelFieldColumnAttributes
                        [ renderLabel language extSection.label ]
                    , column
                        valueFieldColumnAttributes
                        [ textColumn
                            [ spacing lineSpacing ]
                            (List.map (viewExternalAuthority language) extSection.items)
                        ]
                    ]
                ]
            ]
        ]


viewExternalAuthority : Language -> ExternalAuthorityBody -> Element msg
viewExternalAuthority language authority =
    link
        [ linkColour ]
        { url = authority.url
        , label = text (extractLabelFromLanguageMap language authority.label)
        }
