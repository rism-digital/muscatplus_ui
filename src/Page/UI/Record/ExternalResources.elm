module Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalRecords, viewExternalResource, viewExternalResources, viewExternalResourcesSection)

import Config as C
import Dict exposing (Dict)
import Dict.Extra as DE
import Element exposing (Element, alignLeft, alignRight, alignTop, column, el, fill, height, maximum, newTabLink, padding, paddingXY, paragraph, pointer, px, row, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalProject, ExternalRecord(..), ExternalRecordBody, externalProjectToString)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourceType(..), ExternalResourcesSectionBody)
import Page.RecordTypes.PartOf exposing (PartOf(..))
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (headingMD, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (externalLinkTemplate, resourceLink)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (iiifLogo)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)
import Url.Builder as QB


viewExternalRecord : Language -> ExternalRecordBody -> Element msg
viewExternalRecord language body =
    case body.record of
        ExternalSource sourceRecord ->
            viewExternalRecordOnSiteLink language body.project sourceRecord

        ExternalPerson personRecord ->
            viewExternalRecordOnSiteLink language body.project personRecord

        ExternalInstitution institutionRecord ->
            viewExternalRecordOnSiteLink language body.project institutionRecord


viewExternalRecordOnSiteLink :
    Language
    -> ExternalProject
    -> { a | id : String, label : LanguageMap }
    -> Element msg
viewExternalRecordOnSiteLink language project body =
    let
        projectLabel =
            externalProjectToString project
    in
    column
        [ width fill
        , spacing 5
        ]
        [ paragraph
            [ width fill
            , alignLeft
            , spacing 5
            ]
            [ newTabLink
                [ linkColour
                , alignLeft
                ]
                { label = text ("View " ++ extractLabelFromLanguageMap language body.label ++ " on " ++ projectLabel)
                , url = body.id
                }
            , externalLinkTemplate body.id
            ]
        ]


iiifViewerUrl : String -> String -> String
iiifViewerUrl manifestUrl recordId =
    C.serverUrl
        ++ "/viewer.html#"
        ++ QB.toQuery
            [ QB.string "manifest" manifestUrl
            , QB.string "record" recordId
            ]


viewExternalResourceIiifManifest :
    { language : Language
    , recordId : String
    }
    -> ExternalResourceBody
    -> Element msg
viewExternalResourceIiifManifest { language, recordId } body =
    row
        [ width fill
        , alignLeft
        ]
        [ paragraph
            [ alignLeft
            , width fill
            ]
            [ el [] (text (extractLabelFromLanguageMap language body.label ++ ":"))
            , text " "
            , el [ width (px 18) ] iiifLogo
            , text " "
            , el []
                (newTabLink
                    [ linkColour
                    ]
                    { label = text (extractLabelFromLanguageMap language localTranslations.viewImages)
                    , url = iiifViewerUrl body.url recordId
                    }
                )
            , text " "
            , el [] (text "|")
            , text " "
            , el []
                (newTabLink
                    [ linkColour
                    ]
                    { label = text "Manifest"

                    -- TODO: Translate
                    , url = body.url
                    }
                )
            , text " "
            , externalLinkTemplate body.url
            ]
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
            { label =
                paragraph
                    []
                    [ text (extractLabelFromLanguageMap language body.label) ]
            , url = body.url
            }
        , externalLinkTemplate body.url
        ]


viewExternalResource :
    { body : ExternalResourceBody
    , language : Language
    , recordId : String
    }
    -> Element msg
viewExternalResource { body, language, recordId } =
    case body.type_ of
        IIIFManifestResourceType ->
            viewExternalResourceIiifManifest
                { language = language
                , recordId = recordId
                }
                body

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


viewExternalResources :
    { language : Language
    , recordId : String
    }
    -> List ExternalResourceBody
    -> Element msg
viewExternalResources { language, recordId } itms =
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
                        , recordId = recordId
                        }
                )
                itms
            )
        ]


viewExternalResourcesSection :
    { language : Language
    , recordId : String
    }
    -> ExternalResourcesSectionBody
    -> Element msg
viewExternalResourcesSection { language, recordId } extSection =
    sectionTemplate language
        extSection
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
                [ viewMaybe
                    (viewExternalResources
                        { language = language
                        , recordId = recordId
                        }
                    )
                    extSection.items
                , viewMaybe (viewExternalRecords language) extSection.externalRecords
                ]
            ]
        ]


filtTypes : ExternalResourceType -> Bool
filtTypes rtype =
    case rtype of
        IIIFManifestResourceType ->
            True

        DigitizationResourceType ->
            True

        _ ->
            False


gatherExternalResourcesFromSection :
    Language
    ->
        List
            { a
                | label : LanguageMap
                , externalResources : Maybe ExternalResourcesSectionBody
            }
    -> Dict String (List ExternalResourceBody)
gatherExternalResourcesFromSection language extResources =
    let
        filtResources =
            List.map (\{ label, externalResources } -> ( externalResources, label )) extResources
                |> List.filterMap
                    (\( f, l ) ->
                        Maybe.map
                            (\v ->
                                Maybe.map
                                    (\exR ->
                                        List.filter (\r -> filtTypes r.type_) exR
                                            |> List.map (\exRb -> ( extractLabelFromLanguageMap language l, [ exRb ] ))
                                    )
                                    v.items
                            )
                            f
                    )
    in
    List.filterMap identity filtResources
        |> List.concat
        |> DE.fromListCombining (++)


gatherAllDigitizationLinksForCallout : Language -> FullSourceBody -> Dict String (List ExternalResourceBody)
gatherAllDigitizationLinksForCallout language body =
    case body.partOf of
        Just partOf ->
            partOf.items
                |> List.filterMap
                    (\{ relatedTo } ->
                        case relatedTo of
                            SourcePart sourcePart ->
                                sourcePart.externalResources
                                    |> Maybe.map
                                        (\resources ->
                                            resources
                                                |> List.filter (\r -> filtTypes r.type_)
                                                |> List.map
                                                    (\resource ->
                                                        ( extractLabelFromLanguageMap language sourcePart.label
                                                        , [ resource ]
                                                        )
                                                    )
                                        )

                            _ ->
                                Nothing
                    )
                |> List.concat
                |> DE.fromListCombining (++)

        Nothing ->
            let
                gatherExternalResourcesFromTopLevel =
                    Maybe.map (\{ items } -> Maybe.withDefault [] items) body.externalResources
                        |> Maybe.withDefault []
                        |> List.filter (\r -> filtTypes r.type_)
                        |> List.map (\v -> ( extractLabelFromLanguageMap language body.label, [ v ] ))
                        |> DE.fromListCombining (++)

                gatherExternalResourcesFromExemplars =
                    Maybe.map .items body.exemplars
                        |> Maybe.withDefault []
                        |> gatherExternalResourcesFromSection language

                gatherExternalResourcesFromMaterialGroups =
                    Maybe.map .items body.materialGroups
                        |> Maybe.withDefault []
                        |> gatherExternalResourcesFromSection language
            in
            DE.unionWith (\_ v1 v2 -> v1 ++ v2) gatherExternalResourcesFromTopLevel gatherExternalResourcesFromExemplars
                |> DE.unionWith (\_ v3 v4 -> v3 ++ v4) gatherExternalResourcesFromMaterialGroups


viewDigitizedCopiesCalloutSection :
    { expandMsg : msg
    , expanded : Bool
    , language : Language
    , recordId : String
    }
    -> Dict String (List ExternalResourceBody)
    -> Element msg
viewDigitizedCopiesCalloutSection { expandMsg, expanded, language, recordId } externalResourceLinks =
    row
        [ Border.color colourScheme.puce
        , width (fill |> maximum 800)
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , spacing 8
                , Background.color colourScheme.puce
                , padding 8
                , Events.onClick expandMsg
                , pointer
                ]
                [ el
                    []
                    (text "")
                , el
                    [ headingMD
                    , Font.semiBold
                    , Font.color colourScheme.white
                    , alignTop
                    ]
                    (text (extractLabelFromLanguageMap language localTranslations.hasDigitization))
                , el
                    [ alignRight
                    , Font.color colourScheme.white
                    ]
                    (if expanded then
                        text "Hide"

                     else
                        text "Show"
                    )
                ]
            , viewIf (viewCalloutBody { language = language, recordId = recordId } externalResourceLinks) expanded
            ]
        ]


viewCalloutBody :
    { language : Language
    , recordId : String
    }
    -> Dict String (List ExternalResourceBody)
    -> Element msg
viewCalloutBody { language, recordId } externalResourceLinks =
    row
        [ width fill
        , padding 8
        , Border.width 1
        , Border.color colourScheme.puce
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
                                    [ paragraph [ Font.semiBold, headingMD ] [ text instName ] ]
                                , el
                                    [ paddingXY 20 0 ]
                                    (viewExternalResources
                                        { language = language
                                        , recordId = recordId
                                        }
                                        links
                                    )
                                ]
                            ]
                    )
            )
        ]
