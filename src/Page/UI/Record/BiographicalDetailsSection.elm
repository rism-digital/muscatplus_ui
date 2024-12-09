module Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)

import Element exposing (Element, alignTop, column, fill, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Person exposing (BiographicalDetailsSectionBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewBiographicalDetailsSection :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> BiographicalDetailsSectionBody
    -> Element msg
viewBiographicalDetailsSection { language, summaryFormatter } biographicalDetails =
    sectionTemplate language
        biographicalDetails
        [ row
            (width fill
                :: alignTop
                :: sectionBorderStyles
            )
            [ column
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ summaryFormatter language biographicalDetails.summary ]
            ]
        ]
