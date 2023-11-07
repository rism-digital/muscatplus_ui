module Page.UI.Record.BiographicalDetailsSection exposing (viewBiographicalDetailsSection)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Person exposing (BiographicalDetailsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewBiographicalDetailsSection : Language -> BiographicalDetailsSectionBody -> Element msg
viewBiographicalDetailsSection language biographicalDetails =
    let
        sectionTmpl =
            sectionTemplate language biographicalDetails
    in
    sectionTmpl
        [ row
            (width fill
                :: height fill
                :: alignTop
                :: sectionBorderStyles
            )
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                [ viewSummaryField language biographicalDetails.summary ]
            ]
        ]
