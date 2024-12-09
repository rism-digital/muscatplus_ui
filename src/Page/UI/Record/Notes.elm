module Page.UI.Record.Notes exposing (viewNotesSection)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Notes exposing (NotesSectionBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewNotesSection :
    { language : Language
    , paragraphFormatter : Language -> List LabelValue -> Element msg
    }
    -> NotesSectionBody
    -> Element msg
viewNotesSection { language, paragraphFormatter } notesSection =
    sectionTemplate
        language
        notesSection
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
                [ paragraphFormatter language notesSection.notes
                ]
            ]
        ]
