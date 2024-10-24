module Page.UI.Record.ExternalResources exposing (gatherAllDigitizationLinksForCallout, viewDigitizedCopiesCalloutSection, viewExternalRecords, viewExternalResources, viewExternalResourcesSection)

import Config as C
import Dict exposing (Dict)
import Dict.Extra as DE
import Element exposing (Element, alignLeft, alignRight, alignTop, column, el, fill, height, newTabLink, padding, paddingXY, paragraph, pointer, px, row, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalRecord exposing (ExternalProject, ExternalRecord(..), ExternalRecordBody, externalProjectToString)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody, ExternalResourceType(..), ExternalResourcesSectionBody)
import Page.RecordTypes.Source exposing (FullSourceBody)
import Page.UI.Attributes exposing (headingLG, headingMD, lineSpacing, linkColour, sectionBorderStyles)
import Page.UI.Components exposing (externalLinkTemplate, resourceLink)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Images exposing (iiifLogo)
import Page.UI.Record.SectionTemplate exposing (sectionTemplate)
import Page.UI.Style exposing (colourScheme)


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
                , label = text ("View " ++ extractLabelFromLanguageMap language body.label ++ " on " ++ projectLabel)
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
            , label = paragraph [] [ text (extractLabelFromLanguageMap language body.label) ]
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
        |> List.filterMap identity
        |> List.foldr (++) []
        |> DE.fromListCombining (++)


gatherAllDigitizationLinksForCallout : Language -> FullSourceBody -> Dict String (List ExternalResourceBody)
gatherAllDigitizationLinksForCallout language body =
    let
        gatherExternalResources =
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
    DE.unionWith (\_ v1 v2 -> v1 ++ v2) gatherExternalResources gatherExternalResourcesFromExemplars
        |> DE.unionWith (\_ v3 v4 -> v3 ++ v4) gatherExternalResourcesFromMaterialGroups


viewDigitizedCopiesCalloutSection :
    { expandMsg : msg
    , expanded : Bool
    , language : Language
    }
    -> Dict String (List ExternalResourceBody)
    -> Element msg
viewDigitizedCopiesCalloutSection { expandMsg, expanded, language } externalResourceLinks =
    row
        [ Border.color colourScheme.puce
        , Border.width
            (if expanded then
                1

             else
                0
            )
        , width fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , spacing 10
                , Background.color colourScheme.puce
                , padding 10
                , Events.onClick expandMsg
                , pointer
                ]
                [ el
                    []
                    (text "")
                , el
                    [ headingLG
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
