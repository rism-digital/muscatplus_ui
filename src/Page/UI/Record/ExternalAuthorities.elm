module Page.UI.Record.ExternalAuthorities exposing (viewExternalAuthoritiesSection)

import Element exposing (Element, alignLeft, alignTop, column, fill, height, newTabLink, row, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Maybe.Extra as ME
import Page.RecordTypes.ExternalAuthorities exposing (ExternalAuthoritiesSectionBody, ExternalAuthorityBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (externalLinkTemplate)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewExternalAuthoritiesSection : Language -> ExternalAuthoritiesSectionBody -> Element msg
viewExternalAuthoritiesSection language extSection =
    let
        sectionTmpl =
            sectionTemplate language extSection
    in
    sectionTmpl
        [ row
            (width fill
                :: height fill
                :: alignTop
                :: sectionBorderStyles
            )
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                [ wrappedRow
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ column
                        (spacing lineSpacing :: valueFieldColumnAttributes)
                        (List.map (viewExternalAuthority language) extSection.items)
                    ]
                ]
            ]
        ]


viewExternalAuthority : Language -> ExternalAuthorityBody -> Element msg
viewExternalAuthority language authority =
    ME.unpack
        (\() ->
            row
                [ width fill
                , alignLeft
                ]
                [ text (extractLabelFromLanguageMap language authority.label) ]
        )
        (\url ->
            row
                [ width fill
                , alignLeft
                , spacing 5
                ]
                [ newTabLink
                    [ linkColour ]
                    { label = text (extractLabelFromLanguageMap language authority.label)
                    , url = url
                    }
                , externalLinkTemplate url
                ]
        )
        authority.url
