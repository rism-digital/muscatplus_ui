module Page.UI.Record.PartOfSection exposing (viewHoldingPartOfSection, viewPartOfSection, viewWorkPartOfCatalogueSection)

import Dict exposing (toList)
import Dict.Extra as DE
import Element exposing (Element, column, el, fill, fillPortion, height, link, maximum, padding, paddingEach, paragraph, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.ExternalResource exposing (ExternalResourceBody)
import Page.RecordTypes.PartOf exposing (PartOf(..), PartOfSectionBody, PartOfType(..), RelatedBlock, extractUrlAndLabelFromPartOf)
import Page.RecordTypes.Publication exposing (BasicPublicationBody)
import Page.UI.Attributes exposing (headingMD, headingSM, linkColour)
import Page.UI.Components exposing (formatPublicationStatusBadge)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.ExternalResources exposing (viewExternalResource)
import Page.UI.Style exposing (colourScheme)


viewPartOfSection : Language -> PartOfSectionBody -> Element msg
viewPartOfSection language partOf =
    viewPartOfSectionImpl
        { includeSourceExternalResources = False
        , language = language
        , title = localTranslations.partOfCollection
        }
        partOf


viewHoldingPartOfSection : Language -> PartOfSectionBody -> Element msg
viewHoldingPartOfSection language partOf =
    viewPartOfSectionImpl
        { includeSourceExternalResources = True
        , language = language
        , title = localTranslations.source
        }
        partOf


viewWorkPartOfCatalogueSection : Language -> PartOfSectionBody -> Element msg
viewWorkPartOfCatalogueSection language partOf =
    viewPartOfSectionImpl
        { includeSourceExternalResources = True
        , language = language
        , title = localTranslations.workCatalogues
        }
        partOf


viewPartOfSectionImpl :
    { includeSourceExternalResources : Bool
    , language : Language
    , title : LanguageMap
    }
    -> PartOfSectionBody
    -> Element msg
viewPartOfSectionImpl { includeSourceExternalResources, language, title } partOf =
    row
        [ Border.color colourScheme.darkGrey
        , Border.width 1
        , width (fill |> maximum 800)
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , Background.color colourScheme.darkGrey
                , padding 10
                ]
                [ el
                    [ headingMD
                    , Font.semiBold
                    , Font.color colourScheme.white
                    ]
                    (text (extractLabelFromLanguageMap language title))
                ]
            , viewPartOfBoxBody
                { includeSourceExternalResources = includeSourceExternalResources
                , language = language
                }
                partOf
            ]
        ]


viewPartOfBoxBody :
    { includeSourceExternalResources : Bool
    , language : Language
    }
    -> PartOfSectionBody
    -> Element msg
viewPartOfBoxBody { includeSourceExternalResources, language } partOf =
    let
        primaryParts =
            List.filter (\p -> p.relationshipType == PrimaryPartOf) partOf.items
                |> List.map
                    (\b ->
                        case b.relatedTo of
                            SourcePart sourceBody ->
                                if includeSourceExternalResources then
                                    viewPartOfPrimarySourceWithExternalResources language sourceBody

                                else
                                    viewPartOfPrimaryTitle language sourceBody.id sourceBody.label

                            PublicationPart publicationBody ->
                                viewWorkCataloguePrimaryTitle language b publicationBody

                            _ ->
                                let
                                    ( primaryUrl, primaryLabel ) =
                                        extractUrlAndLabelFromPartOf b.relatedTo
                                in
                                viewPartOfPrimaryTitle language primaryUrl primaryLabel
                    )

        secondaryParts : List (Element msg)
        secondaryParts =
            List.filter (\p -> p.relationshipType == SecondaryPartOf) partOf.items
                |> List.map (\s -> viewOtherPartRouter includeSourceExternalResources language s)
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            ]
            (primaryParts ++ secondaryParts)
        ]


viewWorkCataloguePrimaryTitle : Language -> RelatedBlock -> BasicPublicationBody -> Element msg
viewWorkCataloguePrimaryTitle language relBlock partOf =
    let
        statusBadge =
            formatPublicationStatusBadge language partOf.status
    in
    row
        [ width fill ]
        [ column
            [ width (fillPortion 1)
            , padding 10
            , spacing 6
            ]
            [ viewMaybe text relBlock.workInfo
            , statusBadge
            ]
        , column
            [ width (fillPortion 4)
            , padding 10
            ]
            [ row
                [ width fill ]
                [ paragraph
                    [ width fill ]
                    [ link
                        [ linkColour
                        , headingMD
                        , Font.semiBold
                        ]
                        { label = text (extractLabelFromLanguageMap language partOf.label)
                        , url = partOf.id
                        }
                    ]
                ]
            ]
        ]


viewPartOfPrimaryTitle : Language -> String -> LanguageMap -> Element msg
viewPartOfPrimaryTitle language primaryUrl primaryLabel =
    row
        [ width fill
        , padding 10
        ]
        [ paragraph
            [ width fill ]
            [ link
                [ linkColour
                , headingMD
                , Font.semiBold
                ]
                { label = text (extractLabelFromLanguageMap language primaryLabel)
                , url = primaryUrl
                }
            ]
        ]


viewOtherPartRouter : Bool -> Language -> RelatedBlock -> Element msg
viewOtherPartRouter includeSourceExternalResources language relBlock =
    case relBlock.relatedTo of
        SourcePart s ->
            if includeSourceExternalResources then
                viewPartOfSourceWithExternalResources language s

            else
                viewPartOfTitle language s

        PublicationPart p ->
            viewPartOfSecondaryWorkCatalogue language relBlock p

        WorkPart w ->
            viewPartOfTitle language w


viewPartOfSourceWithExternalResources :
    Language
    ->
        { a
            | id : String
            , label : LanguageMap
            , externalResources : Maybe (List ExternalResourceBody)
        }
    -> Element msg
viewPartOfSourceWithExternalResources language sourcePart =
    column
        [ width fill ]
        [ viewPartOfTitle language sourcePart
        , viewGroupedExternalResources
            { language = language
            , recordId = sourcePart.id
            }
            (groupExternalResourcesByLabel language sourcePart.externalResources)
        ]


viewPartOfPrimarySourceWithExternalResources :
    Language
    ->
        { a
            | id : String
            , label : LanguageMap
            , externalResources : Maybe (List ExternalResourceBody)
        }
    -> Element msg
viewPartOfPrimarySourceWithExternalResources language sourcePart =
    column
        [ width fill ]
        [ viewPartOfPrimaryTitle language sourcePart.id sourcePart.label
        , viewGroupedExternalResources
            { language = language
            , recordId = sourcePart.id
            }
            (groupExternalResourcesByLabel language sourcePart.externalResources)
        ]


viewGroupedExternalResources :
    { language : Language
    , recordId : String
    }
    -> List ( String, List ExternalResourceBody )
    -> Element msg
viewGroupedExternalResources cfg groupedExternalResources =
    groupedExternalResources
        |> List.map
            (\( resourceLabel, resources ) ->
                column
                    [ width fill
                    , paddingEach { bottom = 10, left = 25, right = 10, top = 0 }
                    , spacing 8
                    ]
                    [ el
                        [ Font.bold ]
                        (text resourceLabel)
                    , column
                        [ width fill ]
                        (resources
                            |> List.map
                                (\resource ->
                                    row
                                        [ width fill
                                        , spacing 8
                                        ]
                                        [ text "-"
                                        , viewExternalResource
                                            { body = resource
                                            , language = cfg.language
                                            , recordId = cfg.recordId
                                            }
                                        ]
                                )
                        )
                    ]
            )
        |> column [ width fill ]


groupExternalResourcesByLabel :
    Language
    -> Maybe (List ExternalResourceBody)
    -> List ( String, List ExternalResourceBody )
groupExternalResourcesByLabel language maybeResources =
    maybeResources
        |> Maybe.withDefault []
        |> List.map (\resource -> ( extractLabelFromLanguageMap language resource.label, [ resource ] ))
        |> DE.fromListCombining (++)
        |> toList


viewPartOfSecondaryWorkCatalogue : Language -> RelatedBlock -> BasicPublicationBody -> Element msg
viewPartOfSecondaryWorkCatalogue language relBlock partOf =
    let
        label =
            extractLabelFromLanguageMap language partOf.label

        statusBadge =
            formatPublicationStatusBadge language partOf.status
    in
    row
        [ width fill
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , Border.color colourScheme.midGrey
        ]
        [ column
            [ width (fillPortion 1)
            , padding 10
            , spacing 6
            ]
            [ viewMaybe text relBlock.workInfo
            , statusBadge
            ]
        , column
            [ width (fillPortion 4)
            , padding 10
            ]
            [ row
                [ width fill ]
                [ paragraph
                    [ width fill ]
                    [ link
                        [ linkColour
                        , headingSM
                        ]
                        { label = text label
                        , url = partOf.id
                        }
                    ]
                ]
            ]
        ]


viewPartOfTitle : Language -> { a | id : String, label : LanguageMap } -> Element msg
viewPartOfTitle language { id, label } =
    row
        [ width fill
        , padding 10
        ]
        [ paragraph
            [ width fill ]
            [ link
                [ linkColour
                ]
                { label = text (extractLabelFromLanguageMap language label)
                , url = id
                }
            ]
        ]
