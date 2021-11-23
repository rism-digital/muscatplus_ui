module Page.Record.Views.PersonPage.TableOfContents exposing (..)

import Element exposing (Element, alignRight, column, el, fill, moveDown, moveLeft, none, padding, px, row, spacing, width)
import Element.Border as Border
import Language exposing (Language, LanguageMap, localTranslations)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Views.TablesOfContents exposing (createSectionLink, createTocLink)
import Page.RecordTypes.Person exposing (PersonBody)
import Page.Views.Helpers exposing (viewMaybe)


createPersonRecordToc : Language -> PersonBody -> Element RecordMsg
createPersonRecordToc language body =
    let
        topEntry =
            createTocLink language localTranslations.recordTop (UserClickedToCItem body.sectionToc)

        nameVariantsSection =
            viewMaybe (createSectionLink language) body.nameVariants

        relationshipsSection =
            viewMaybe (createSectionLink language) body.relationships

        notesSection =
            viewMaybe (createSectionLink language) body.notes

        externalResourcesSection =
            viewMaybe (createSectionLink language) body.externalResources
    in
    el
        [ Border.width 1
        , alignRight
        , moveDown 100
        , moveLeft 100
        ]
        (row
            [ width (px 300)
            , padding 10
            ]
            [ column
                [ width fill
                , spacing 5
                ]
                [ topEntry
                , nameVariantsSection
                , relationshipsSection
                , notesSection
                , externalResourcesSection
                ]
            ]
        )
