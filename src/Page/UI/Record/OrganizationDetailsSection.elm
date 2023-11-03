module Page.UI.Record.OrganizationDetailsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Institution exposing (OrganizationDetailsSectionBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewOrganizationDetailsSection :
    Language
    ->
        { a
            | summary : List LabelValue
            , label : LanguageMap
            , sectionToc : String
        }
    -> Element msg
viewOrganizationDetailsSection language organizationDetails =
    let
        sectionTmpl =
            sectionTemplate language organizationDetails
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
                [ viewSummaryField language organizationDetails.summary ]
            ]
        ]
