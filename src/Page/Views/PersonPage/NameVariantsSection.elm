module Page.Views.PersonPage.NameVariantsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, htmlAttribute, none, paddingXY, row, spacing, width)
import Html.Attributes as HTA
import Language exposing (Language)
import Msg exposing (Msg)
import Page.RecordTypes.Person exposing (NameVariantsSectionBody, PersonBody)
import Page.UI.Components exposing (h5, viewSummaryField)


viewNameVariantsSection : Language -> NameVariantsSectionBody -> Element Msg
viewNameVariantsSection language variantsSection =
    row
        [ width fill
        , height fill
        , paddingXY 0 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing 20
            , alignTop
            ]
            [ row
                [ width fill
                , htmlAttribute (HTA.id variantsSection.sectionToc)
                ]
                [ h5 language variantsSection.label ]
            , column
                [ width fill
                , spacing 20
                , alignTop
                ]
                [ viewSummaryField language variantsSection.items ]
            ]
        ]
