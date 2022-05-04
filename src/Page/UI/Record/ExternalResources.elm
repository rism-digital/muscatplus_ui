module Page.UI.Record.ExternalResources exposing (..)

import Config as C
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, link, px, row, spacing, text, width, wrappedRow)
import Language exposing (Language)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourceType(..), ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (renderParagraph)
import Page.UI.Images exposing (iiifLogo)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExternalResourcesSection language extSection =
    let
        sectionBody =
            [ row
                ([ width fill
                 , height fill
                 , alignTop
                 ]
                    ++ sectionBorderStyles
                )
                [ column
                    [ spacing sectionSpacing
                    , width fill
                    , height fill
                    , alignTop
                    ]
                    (List.map (\l -> viewExternalResource language l) extSection.items)
                ]
            ]
    in
    sectionTemplate language extSection sectionBody


viewExternalResource : Language -> ExternalResourceBody -> Element msg
viewExternalResource language body =
    let
        externalResourceLink =
            case body.type_ of
                IIIFManifestResourceType ->
                    [ column
                        [ width fill
                        , spacing 5
                        ]
                        [ row
                            [ width fill
                            , alignLeft
                            , spacing 5
                            ]
                            [ link
                                [ linkColour
                                , alignLeft
                                ]
                                { url = C.serverUrl ++ "/viewer.html#?manifest=" ++ body.url
                                , label = text "View Images"
                                }
                            , text "|"
                            , el
                                [ width (px 25)
                                , height (px 26)
                                , alignLeft
                                ]
                                iiifLogo
                            , link
                                [ linkColour
                                , alignLeft
                                ]
                                { url = body.url
                                , label = text "(Manifest)"
                                }
                            ]
                        ]
                    ]

                _ ->
                    [ link
                        [ linkColour ]
                        { url = body.url
                        , label = text body.url
                        }
                    ]
    in
    wrappedRow
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill ]
                [ renderParagraph language body.label ]
            , row
                [ width fill
                ]
                externalResourceLink
            ]
        ]
