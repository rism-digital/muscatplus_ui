module Page.UI.Record.ExternalResources exposing (viewExternalRecords, viewExternalResources, viewExternalResourcesSection)

import Config as C
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, newTabLink, px, row, spacing, text, width, wrappedRow)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecord(..), ExternalRecordBody)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourceType(..), ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (externalLinkTemplate, renderParagraph, resourceLink)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Images exposing (iiifLogo)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)


viewExternalRecord : Language -> ExternalRecordBody -> Element msg
viewExternalRecord language body =
    case body.record of
        ExternalSource sourceRecord ->
            viewExternalRecordOnDIAMMLink language sourceRecord

        ExternalPerson personRecord ->
            viewExternalRecordOnDIAMMLink language personRecord

        ExternalInstitution institutionRecord ->
            viewExternalRecordOnDIAMMLink language institutionRecord


viewExternalRecordOnDIAMMLink :
    Language
    -> { a | id : String, label : LanguageMap }
    -> Element msg
viewExternalRecordOnDIAMMLink language body =
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
                { url = body.id
                , label = text ("View " ++ extractLabelFromLanguageMap language body.label ++ " on DIAMM")
                }
            , externalLinkTemplate body.id
            ]
        ]


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
            row
                [ width fill
                , alignLeft
                , spacing 5
                ]
                [ resourceLink body.url
                    [ linkColour
                    ]
                    { url = body.url
                    , label = renderParagraph language body.label
                    }
                , externalLinkTemplate body.url
                ]


viewExternalRecords : Language -> List ExternalRecordBody -> Element msg
viewExternalRecords language itms =
    wrappedRow
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


viewExternalResources : Language -> List ExternalResourceBody -> Element msg
viewExternalResources language itms =
    wrappedRow
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
