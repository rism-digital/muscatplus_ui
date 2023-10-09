module Page.UI.Record.ExternalResources exposing (viewExternalRecords, viewExternalResources, viewExternalResourcesSection)

import Config as C
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, link, newTabLink, none, paragraph, px, row, spacing, text, width, wrappedRow)
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecord(..), ExternalRecordBody)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourceType(..), ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (fieldValueWrapper, renderParagraph)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (iiifLogo)
import Page.UI.Record.PageTemplate exposing (externalLinkTemplate, isExternalLink)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Utilities exposing (choose)


viewExternalRecord : Language -> ExternalRecordBody -> Element msg
viewExternalRecord language body =
    case body.record of
        ExternalSource sourceRecord ->
            column
                [ width fill
                , spacing 5
                ]
                [ row
                    [ width fill
                    , alignLeft
                    , spacing 5
                    ]
                    [ newTabLink
                        [ linkColour
                        , alignLeft
                        ]
                        { url = sourceRecord.id
                        , label = text ("View " ++ extractLabelFromLanguageMap language sourceRecord.label ++ " on DIAMM")
                        }
                    , externalLinkTemplate sourceRecord.id
                    ]
                ]

        ExternalPerson personRecord ->
            none

        ExternalInstitution institutionRecord ->
            none


viewExternalResource : Language -> ExternalResourceBody -> Element msg
viewExternalResource language body =
    case body.type_ of
        IIIFManifestResourceType ->
            row
                [ width fill
                , alignLeft
                , spacing 5
                ]
                [ newTabLink
                    [ linkColour
                    , alignLeft
                    ]
                    { url = C.serverUrl ++ "/viewer.html#?manifest=" ++ body.url
                    , label = text (extractLabelFromLanguageMap language localTranslations.viewImages)
                    }
                , text "|"
                , el
                    [ width (px 20)
                    , height (px 21)
                    , alignLeft
                    ]
                    iiifLogo
                , newTabLink
                    [ linkColour
                    , alignLeft
                    ]
                    { url = body.url

                    -- TODO: Translate
                    , label = text "Manifest"
                    }
                , externalLinkTemplate body.url
                ]

        _ ->
            let
                resourceLink =
                    choose (isExternalLink body.url) (always newTabLink) (always link)
            in
            row
                [ width fill
                , alignLeft
                ]
                [ paragraph
                    [ width fill
                    , alignLeft
                    ]
                    [ resourceLink
                        [ linkColour
                        ]
                        { url = body.url
                        , label = renderParagraph language body.label
                        }
                    , externalLinkTemplate body.url
                    ]
                ]


viewExternalRecords : Language -> List ExternalRecordBody -> Element msg
viewExternalRecords language itms =
    fieldValueWrapper []
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                (List.map (viewExternalRecord language) itms)
            ]
        ]


viewExternalResources : Language -> List ExternalResourceBody -> Element msg
viewExternalResources language itms =
    fieldValueWrapper []
        [ wrappedRow
            [ width fill
            , height fill
            , alignTop
            ]
            [ column
                [ width fill
                , height fill
                , alignTop
                , spacing lineSpacing
                ]
                (List.map (viewExternalResource language) itms)
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
                    [ width fill
                    , height fill
                    , alignTop
                    , spacing lineSpacing
                    ]
                    [ viewMaybe (viewExternalResources language) extSection.items
                    , viewMaybe (viewExternalRecords language) extSection.externalRecords
                    ]
                ]
            ]
    in
    sectionTemplate language extSection sectionBody
