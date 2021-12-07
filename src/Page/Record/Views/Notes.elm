module Page.Record.Views.Notes exposing (..)

import Element exposing (Element, column, row, spacing)
import Language exposing (Language)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Notes exposing (NotesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, widthFillHeightFill)
import Page.UI.Components exposing (viewParagraphField)


viewNotesSection : Language -> NotesSectionBody -> Element msg
viewNotesSection language notesSection =
    let
        sectionBody =
            [ row
                (List.append widthFillHeightFill sectionBorderStyles)
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ viewParagraphField language notesSection.notes
                    ]
                ]
            ]
    in
    sectionTemplate language notesSection sectionBody
