module Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)

import Element exposing (Element, alignTop, column, el, fill, height, link, row, spacing, text, textColumn, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.ExternalAuthorities exposing (ExternalAuthoritiesSectionBody, ExternalAuthorityBody)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, renderLabel)


viewExternalAuthoritiesSection : Language -> ExternalAuthoritiesSectionBody -> Element msg
viewExternalAuthoritiesSection language extSection =
    row
        (List.concat
            [ [ width fill
              , height fill
              , alignTop
              ]
            , sectionBorderStyles
            ]
        )
        [ column
            [ spacing lineSpacing
            , width fill
            , height fill
            , alignTop
            ]
            [ fieldValueWrapper []
                [ wrappedRow
                    [ width fill
                    , height fill
                    , alignTop
                    ]
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
    ME.unpack
        (\() ->
            el
                []
                (text (extractLabelFromLanguageMap language authority.label))
        )
        (\url ->
            link
                [ linkColour ]
                { label = text (extractLabelFromLanguageMap language authority.label)
                , url = url
                }
        )
        authority.url
