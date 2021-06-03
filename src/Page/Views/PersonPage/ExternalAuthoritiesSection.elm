module Page.Views.PersonPage.ExternalAuthoritiesSection exposing (..)

import Element exposing (Element, alignLeft, centerX, centerY, column, el, fill, link, none, paddingXY, row, spacing, text, width)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (ExternalAuthoritiesSectionBody, ExternalAuthorityBody, PersonBody)
import Page.UI.Components exposing (h6)
import Page.UI.Style exposing (colourScheme)


viewExternalAuthoritiesRouter : PersonBody -> Language -> Element Msg
viewExternalAuthoritiesRouter body language =
    case body.externalAuthorities of
        Just authoritiesSection ->
            viewExternalAuthoritiesSection authoritiesSection language

        Nothing ->
            none


viewExternalAuthoritiesSection : ExternalAuthoritiesSectionBody -> Language -> Element Msg
viewExternalAuthoritiesSection extSection language =
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
                    :: List.map (\a -> viewExternalAuthority a language) extSection.items
                )
            ]
        ]


viewExternalAuthority : ExternalAuthorityBody -> Language -> Element Msg
viewExternalAuthority authority language =
    link
        [ Font.color colourScheme.lightBlue ]
        { url = authority.url, label = text (extractLabelFromLanguageMap language authority.label) }
