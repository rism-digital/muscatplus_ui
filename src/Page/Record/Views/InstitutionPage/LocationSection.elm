module Page.Record.Views.InstitutionPage.LocationSection exposing (viewLocationAddressSection)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Institution exposing (LocationAddressSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles)
import Page.UI.Components exposing (h2, viewSummaryField)
import Page.UI.Helpers exposing (viewMaybe)


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
                    , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.website)
                    , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.email)
                    ]
                ]
            ]
        ]
