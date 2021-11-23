module Page.Record.Views.SourcePage.TableOfContents exposing (..)

import Element exposing (Element, alignRight, column, el, fill, htmlAttribute, moveDown, moveLeft, none, padding, px, row, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HTA
import Language exposing (Language, localTranslations)
import Page.Record.Msg exposing (RecordMsg(..))
import Page.Record.Views.TablesOfContents exposing (createSectionLink, createTocLink)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.Views.Helpers exposing (viewMaybe)


createSourceRecordToc : Language -> FullSourceBody -> Element RecordMsg
createSourceRecordToc language body =
    let
        topEntry =
            createTocLink language localTranslations.recordTop (UserClickedToCItem body.sectionToc)

        contentsSection =
            viewMaybe (createSectionLink language) body.contents

        exemplarsSection =
            viewMaybe (createSectionLink language) body.exemplars

        incipitsSection =
            viewMaybe (createSectionLink language) body.incipits

        materialGroupsSection =
            viewMaybe (createSectionLink language) body.materialGroups

        relationshipsSection =
            viewMaybe (createSectionLink language) body.relationships

        referencesNotesSection =
            viewMaybe (createSectionLink language) body.referencesNotes

        itemsSection =
            viewMaybe (createSectionLink language) body.items
    in
    el
        [ Border.width 1
        , alignRight
        , moveDown 100
        , moveLeft 100
        , Background.color (colourScheme.white |> convertColorToElementColor)
        , htmlAttribute (HTA.style "z-index" "10")
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
                , contentsSection
                , exemplarsSection
                , incipitsSection
                , materialGroupsSection
                , relationshipsSection
                , referencesNotesSection
                , itemsSection
                ]
            ]
        )
