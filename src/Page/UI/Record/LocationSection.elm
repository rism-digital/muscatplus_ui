module Page.UI.Record.LocationSection exposing (viewLocationAddressSection)

import Element exposing (Element, alignTop, column, fill, height, paddingXY, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.Institution exposing (InstitutionAddressBody, LocationAddressSectionBody)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
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
                    [ viewMaybe (viewAddressSection language) body.addresses
                    , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.website)
                    , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.email)
                    ]
                ]
            ]
        ]


viewAddressSection : Language -> List InstitutionAddressBody -> Element msg
viewAddressSection language body =
    row
        [ width fill ]
        [ column
            [ width fill
            , spacing sectionSpacing
            ]
            (List.map (viewSingleAddress language) body)
        ]


viewSingleAddress : Language -> InstitutionAddressBody -> Element msg
viewSingleAddress language body =
    row
        [ width fill ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.street)
            , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.city)
            , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.county)
            , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.country)
            , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.postcode)
            , viewMaybe (viewSummaryField language) (Maybe.map List.singleton body.note)
            ]
        ]
