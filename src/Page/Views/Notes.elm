module Page.Views.Notes exposing (..)

import Element exposing (Element, alignTop, fill, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Notes exposing (NotesSectionBody)
import Page.UI.Components exposing (viewParagraphField)


viewNotesSection : Language -> NotesSectionBody -> Element msg
viewNotesSection language notesSection =
    row
        [ width fill
        , spacing 20
        , alignTop
        ]
        [ viewParagraphField language notesSection.notes ]
