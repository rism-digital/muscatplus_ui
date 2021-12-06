module Page.Record.Views.PersonPage.NameVariantsSection exposing (..)

import Element exposing (Element, column, row, spacing)
import Language exposing (Language)
import Page.RecordTypes.Person exposing (NameVariantsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, widthFillHeightFill)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.SectionTemplate exposing (sectionTemplate)


viewNameVariantsSection : Language -> NameVariantsSectionBody -> Element msg
viewNameVariantsSection language variantsSection =
    let
        sectionBody =
            [ row
                (List.concat [ widthFillHeightFill, sectionBorderStyles ])
                [ column
                    (List.append [ spacing lineSpacing ] widthFillHeightFill)
                    [ viewSummaryField language variantsSection.items ]
                ]
            ]
    in
    sectionTemplate language variantsSection sectionBody
