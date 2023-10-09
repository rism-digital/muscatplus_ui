module Page.UI.Record.Notes exposing (viewNotesSection)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Notes exposing (NotesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (viewParagraphField)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewNotesSection : Language -> NotesSectionBody -> Element msg
viewNotesSection language notesSection =
    let
        sectionTmpl =
            sectionTemplate language notesSection
    in
    sectionTmpl
        [ row
            (width fill
                :: height fill
                :: alignTop
                :: sectionBorderStyles
            )
            [ column
                [ spacing lineSpacing
                , width fill
                , height fill
                , alignTop
                ]
                [ viewParagraphField language notesSection.notes
                ]
            ]
        ]
