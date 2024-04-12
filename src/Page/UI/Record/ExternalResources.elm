module Page.UI.Record.ExternalResources exposing (viewDigitizedCopiesCalloutSection, viewExternalRecords, viewExternalResources, viewExternalResourcesSection)

import Config as C
import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignRight, alignTop, column, el, fill, height, minimum, newTabLink, padding, paddingXY, pointer, px, row, shrink, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalRecord(..), ExternalRecordBody)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourceType(..), ExternalResourcesSectionBody)
import Page.UI.Attributes exposing (headingLG, headingMD, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (externalLinkTemplate, renderParagraph, resourceLink)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (iiifLogo)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)


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


viewExternalResourceIiifManifest : Language -> ExternalResourceBody -> Element msg
viewExternalResourceIiifManifest language body =
    row
        [ width fill
        , alignLeft
        , spacing 5
        ]
        [ el
            [ width (px 18)
            , height (px 19)
            , alignLeft
            ]
            iiifLogo
        , newTabLink
            [ linkColour
            , alignLeft
            ]
            { url = C.serverUrl ++ "/viewer.html#?manifest=" ++ body.url
            , label = text (extractLabelFromLanguageMap language localTranslations.viewImages)
            }
        , text "|"
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


viewExternalResourcePlainLink : Language -> ExternalResourceBody -> Element msg
viewExternalResourcePlainLink language body =
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


viewExternalResource :
    { body : ExternalResourceBody
    , language : Language
    }
    -> Element msg
viewExternalResource { body, language } =
    case body.type_ of
        IIIFManifestResourceType ->
            viewExternalResourceIiifManifest language body

        _ ->
            viewExternalResourcePlainLink language body


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
            (List.map
                (\it ->
                    viewExternalResource
                        { body = it
                        , language = language
                        }
                )
                itms
            )
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


viewDigitizedCopiesCalloutSection :
    { expandMsg : msg
    , expanded : Bool
    , language : Language
    }
    -> Dict String (List ExternalResourceBody)
    -> Element msg
viewDigitizedCopiesCalloutSection { expandMsg, expanded, language } externalResourceLinks =
    row
        [ Border.color colourScheme.darkOrange
        , Border.width 1
        , width (shrink |> minimum 800)
        ]
        [ column
            [ width fill
            , height fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , spacing 10
                , Background.color colourScheme.darkOrange
                , padding 10
                ]
                [ el
                    [ headingLG
                    , Font.semiBold
                    , Font.color colourScheme.white
                    ]
                    (text (extractLabelFromLanguageMap language localTranslations.hasDigitization))
                , el
                    [ Events.onClick expandMsg
                    , alignRight
                    , Font.color colourScheme.white
                    , pointer
                    ]
                    (if expanded then
                        text "Hide"

                     else
                        text "Show"
                    )
                ]
            , viewIf (viewCalloutBody language externalResourceLinks) expanded
            ]
        ]


viewCalloutBody : Language -> Dict String (List ExternalResourceBody) -> Element msg
viewCalloutBody language externalResourceLinks =
    row
        [ width fill
        , padding 10
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            (Dict.toList externalResourceLinks
                |> List.map
                    (\( instName, links ) ->
                        row
                            [ width fill ]
                            [ column
                                [ width fill
                                , spacing lineSpacing
                                ]
                                [ row
                                    [ width fill ]
                                    [ el [ Font.semiBold, headingMD ] (text instName) ]
                                , el [ paddingXY 20 0 ] (viewExternalResources language links)
                                ]
                            ]
                    )
            )
        ]
