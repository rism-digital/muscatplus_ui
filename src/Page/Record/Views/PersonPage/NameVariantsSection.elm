module Page.Record.Views.PersonPage.NameVariantsSection exposing (..)

import Element exposing (Element)
import Language exposing (Language)
import Page.RecordTypes.Person exposing (NameVariantsSectionBody)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.SectionTemplate exposing (sectionTemplate)


viewNameVariantsSection : Language -> NameVariantsSectionBody -> Element msg
viewNameVariantsSection language variantsSection =
    sectionTemplate language variantsSection [ viewSummaryField language variantsSection.items ]
