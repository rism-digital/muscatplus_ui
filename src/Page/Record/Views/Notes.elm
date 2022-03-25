module Page.Record.Views.Notes exposing (..)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Notes exposing (NotesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (viewParagraphField)


viewNotesSection : Language -> NotesSectionBody -> Element msg
viewNotesSection language notesSection =
    let
        sectionBody =
            [ row
                ([ width fill
                 , height fill
                 , alignTop
                 ]
                    ++ sectionBorderStyles
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
    in
    sectionTemplate language notesSection sectionBody
