module Page.TablesOfContents exposing (..)

import Element exposing (Element, column, el, fill, htmlAttribute, none, padding, pointer, px, row, spacing, text, width)
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HTA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, localTranslations)
import Msg exposing (Msg(..))
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Style exposing (colourScheme)


createTocLink : ( String, LanguageMap ) -> Language -> Element Msg
createTocLink ( url, label ) language =
    -- TODO: Scrolling probably needs to be implemented with
    -- https://package.elm-lang.org/packages/elm/browser/latest/Browser.Dom
    row
        [ width fill
        ]
        [ el
            [ Font.color colourScheme.lightBlue
            , onClick (ToCElementSelected url)
            , pointer
            ]
            (text (extractLabelFromLanguageMap language label))
        ]


createSourceRecordToc : FullSourceBody -> Language -> Element Msg
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

        incipitsEntry =
            case body.incipits of
                Just section ->
                    createTocLink ( section.sectionToc, section.label ) language

                Nothing ->
                    none

        materialGroupsEntry =
            case body.materialGroups of
                Just section ->
                    createTocLink ( section.sectionToc, section.label ) language

                Nothing ->
                    none

        referencesNotesEntry =
            case body.referencesNotes of
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
            , incipitsEntry
            , materialGroupsEntry
            , referencesNotesEntry
            , sourceItemsEntry
            ]
        ]
