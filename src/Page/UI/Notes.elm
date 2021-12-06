module Page.UI.Notes exposing (..)

import Element exposing (Element, column, row, spacing)
import Language exposing (Language)
import Page.RecordTypes.Notes exposing (NotesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, widthFillHeightFill)
import Page.UI.Components exposing (viewParagraphField)
import Page.UI.SectionTemplate exposing (sectionTemplate)


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
