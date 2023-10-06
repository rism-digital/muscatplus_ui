module Page.UI.Record.OrganizationDetailsSection exposing (..)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Institution exposing (OrganizationDetailsSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (viewSummaryField)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewOrganizationDetailsSection : Language -> OrganizationDetailsSectionBody -> Element msg
viewOrganizationDetailsSection language organizationDetails =
    let
        sectionBody =
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
    in
    sectionTemplate language organizationDetails sectionBody
