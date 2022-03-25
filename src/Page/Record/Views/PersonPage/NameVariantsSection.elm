module Page.Record.Views.PersonPage.NameVariantsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.Record.Views.SectionTemplate exposing (sectionTemplate)
import Page.RecordTypes.Person exposing (NameVariantsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)


viewNameVariantsSection : Language -> NameVariantsSectionBody -> Element msg
viewNameVariantsSection language variantsSection =
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
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewSummaryField language variantsSection.items ]
                ]
            ]
    in
    sectionTemplate language variantsSection sectionBody
