module Page.UI.Record.OrganizationDetailsSection exposing (viewOrganizationDetailsSection)

import Element exposing (Element, alignTop, column, fill, height, row, spacing, width)
import Language exposing (Language, LanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewOrganizationDetailsSection :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    ->
        { a
            | label : LanguageMap
            , sectionToc : String
            , summary : List LabelValue
        }
    -> Element msg
viewOrganizationDetailsSection { language, summaryFormatter } organizationDetails =
    sectionTemplate language
        organizationDetails
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
                [ summaryFormatter language organizationDetails.summary ]
            ]
        ]
