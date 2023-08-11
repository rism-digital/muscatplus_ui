module Page.Record.Views.InstitutionPage.LocationSection exposing (viewLocationAddressSection)

import Element exposing (Element, alignTop, column, fill, height, link, paddingXY, row, spacing, text, width, wrappedRow)
import Language exposing (Language)
import Page.RecordTypes.Institution exposing (LocationAddressSectionBody)
import Page.RecordTypes.Shared exposing (LabelStringValue)
import Page.UI.Attributes exposing (labelFieldColumnAttributes, lineSpacing, linkColour, sectionBorderStyles, valueFieldColumnAttributes)
import Page.UI.Components exposing (fieldValueWrapper, h2, renderLabel, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


viewEmailAddress : Language -> LabelStringValue -> Element msg
viewEmailAddress language emailAddress =
    fieldValueWrapper []
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language emailAddress.label ]
            , column
                valueFieldColumnAttributes
                [ link
                    [ linkColour ]
                    { label = text emailAddress.value
                    , url = "mailto:" ++ emailAddress.value
                    }
                ]
            ]
        ]


viewLocationAddressSection : Language -> LocationAddressSectionBody -> Element msg
viewLocationAddressSection language body =
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
                [ width fill ]
                [ h2 language body.label ]
            , row
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
                    [ viewMaybe (viewSummaryField language) body.mailingAddress
                    , viewMaybe (viewWebsiteAddress language) body.website
                    , viewMaybe (viewEmailAddress language) body.email
                    ]
                ]
            ]
        ]


viewWebsiteAddress : Language -> LabelStringValue -> Element msg
viewWebsiteAddress language websiteAddress =
    fieldValueWrapper []
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                labelFieldColumnAttributes
                [ renderLabel language websiteAddress.label ]
            , column
                valueFieldColumnAttributes
                [ link
                    [ linkColour ]
                    { label = text websiteAddress.value
                    , url = websiteAddress.value
                    }
                ]
            ]
        ]
