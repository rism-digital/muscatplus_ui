module Page.UI.Record.LocationSection exposing (viewLocationAddressSection, viewLocationMapSection)

import Element exposing (Element, alignTop, column, el, fill, height, paddingXY, paragraph, px, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Institution exposing (CoordinatesSection, InstitutionAddressBody, LocationAddressSectionBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (lineSpacing, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (h2, mapViewer)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (circleSvg, mapMarkerSvg)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Url.Builder as QB exposing (absolute)


viewLocationAddressSection :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> LocationAddressSectionBody
    -> Element msg
viewLocationAddressSection { language, summaryFormatter } body =
    row
        [ width fill
        , height fill
        , alignTop
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
                    [ viewMaybe
                        (viewAddressSection
                            { language = language
                            , summaryFormatter = summaryFormatter
                            }
                        )
                        body.addresses
                    , viewMaybe (summaryFormatter language) (Maybe.map List.singleton body.website)
                    , viewMaybe (summaryFormatter language) (Maybe.map List.singleton body.email)
                    ]
                ]
            ]
        ]


viewAddressSection :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> List InstitutionAddressBody
    -> Element msg
viewAddressSection { language, summaryFormatter } body =
    row
        [ width fill ]
        [ column
            [ width fill
            , spacing sectionSpacing
            ]
            (List.map
                (viewSingleAddress
                    { language = language
                    , summaryFormatter = summaryFormatter
                    }
                )
                body
            )
        ]


viewSingleAddress :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> InstitutionAddressBody
    -> Element msg
viewSingleAddress { language, summaryFormatter } body =
    row
        [ width fill ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ viewMaybe (summaryFormatter language) (Maybe.map List.singleton body.street)
            , viewMaybe (summaryFormatter language) (Maybe.map List.singleton body.city)
            , viewMaybe (summaryFormatter language) (Maybe.map List.singleton body.county)
            , viewMaybe (summaryFormatter language) (Maybe.map List.singleton body.country)
            , viewMaybe (summaryFormatter language) (Maybe.map List.singleton body.postcode)
            , viewMaybe (summaryFormatter language) (Maybe.map List.singleton body.note)
            ]
        ]


mapSection :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ( Int, Int )
    -> CoordinatesSection
    -> Element msg
mapSection { language, summaryFormatter } ( windowWidth, windowHeight ) coords =
    let
        strCoords =
            List.map String.fromFloat coords.coordinates

        coordsValue =
            List.reverse strCoords
                |> String.join ", "

        coordsQ =
            List.map2 (\dim val -> QB.string dim val) [ "lon", "lat" ] strCoords

        geoJsonQ =
            QB.string "geo" coords.id

        mapsUrl =
            (geoJsonQ :: coordsQ)
                |> absolute [ "maps.html" ]
    in
    sectionTemplate language
        coords
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
                [ summaryFormatter language [ { label = coords.coordinatesLabel, value = toLanguageMap coordsValue } ]
                , row
                    [ width fill ]
                    [ mapViewer ( min windowWidth 900, min windowHeight 400 ) mapsUrl ]
                , row
                    [ width fill ]
                    [ column
                        [ width fill
                        , spacing lineSpacing
                        ]
                        [ paragraph
                            [ width fill
                            , spacing 5
                            ]
                            [ el [ width (px 15), height (px 15) ] (mapMarkerSvg colourScheme.lightBlue)
                            , el [ paddingXY 5 0 ] (text (extractLabelFromLanguageMap language localTranslations.location))
                            ]
                        , paragraph
                            [ width fill
                            , spacing 5
                            ]
                            [ el [ width (px 15), height (px 15) ] (circleSvg colourScheme.darkOrange)
                            , el [ paddingXY 5 0 ] (text (extractLabelFromLanguageMap language localTranslations.nearbyInstitutions))
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewLocationMapSection :
    { language : Language
    , summaryFormatter : Language -> List LabelValue -> Element msg
    }
    -> ( Int, Int )
    -> LocationAddressSectionBody
    -> Element msg
viewLocationMapSection { language, summaryFormatter } ( windowWidth, windowHeight ) location =
    viewMaybe
        (mapSection
            { language = language
            , summaryFormatter = summaryFormatter
            }
            ( windowWidth, windowHeight )
        )
        location.coordinates
