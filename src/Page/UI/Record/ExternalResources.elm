module Page.UI.Record.ExternalResources exposing (viewExternalResource, viewExternalResourcesSection)

import Config as C
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, link, px, row, spacing, text, width, wrappedRow)
import Language exposing (Language)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourceType(..), ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles, sectionSpacing)
import Page.UI.Components exposing (renderParagraph)
import Page.UI.Images exposing (iiifLogo)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


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
                                { label = text "View Images"
                                , url = C.serverUrl ++ "/viewer.html#?manifest=" ++ body.url
                                }
                            , text "|"
                            , el
                                [ width (px 20)
                                , height (px 21)
                                , alignLeft
                                ]
                                iiifLogo
                            , link
                                [ linkColour
                                , alignLeft
                                ]
                                { label = text "Manifest"
                                , url = body.url
                                }
                            ]
                        ]
                    ]

                _ ->
                    [ link
                        [ linkColour ]
                        { label = text body.url
                        , url = body.url
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


viewExternalResourcesSection : Language -> ExternalResourcesSectionBody -> Element msg
viewExternalResourcesSection language extSection =
    let
        sectionBody =
            [ row
                (width fill
                    :: height fill
                    :: alignTop
                    :: sectionBorderStyles
                )
                [ column
                    [ spacing sectionSpacing
                    , width fill
                    , height fill
                    , alignTop
                    ]
                    (List.map (viewExternalResource language) extSection.items)
                ]
            ]
    in
    sectionTemplate language extSection sectionBody
