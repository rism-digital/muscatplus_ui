module Page.TablesOfContents exposing (..)

import Element exposing (Element, column, fill, html, link, none, padding, paragraph, px, row, spacing, text, width, wrappedRow)
import Element.Font as Font
import Html as HT
import Html.Attributes as HTA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, localTranslations)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Style exposing (colourScheme)


createTocLink : ( String, LanguageMap ) -> Language -> Element msg
createTocLink ( url, label ) language =
    row
        [ width fill
        , Font.color colourScheme.lightBlue
        ]
        [ html
            (HT.a
                [ HTA.href ("#" ++ url) ]
                [ HT.text (extractLabelFromLanguageMap language label) ]
            )
        ]


createSourceRecordToc : FullSourceBody -> Language -> Element msg
createSourceRecordToc body language =
    let
        topEntry =
            createTocLink ( body.sectionToc, localTranslations.recordTop ) language

        contentsEntry =
            case body.contents of
                Just section ->
                    createTocLink ( section.sectionToc, section.label ) language

                Nothing ->
                    none

        exemplarsEntry =
            case body.exemplars of
                Just section ->
                    createTocLink ( section.sectionToc, section.label ) language

                Nothing ->
                    none

        sourceItemsEntry =
            case body.items of
                Just section ->
                    createTocLink ( section.sectionToc, section.label ) language

                Nothing ->
                    none
    in
    row
        [ width (px 300)
        , padding 10
        ]
        [ column
            [ width fill
            , spacing 5
            ]
            [ topEntry
            , contentsEntry
            , exemplarsEntry
            , sourceItemsEntry
            ]
        ]
