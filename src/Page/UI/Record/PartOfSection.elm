module Page.UI.Record.PartOfSection exposing (viewHoldingPartOfSection, viewPartOfSection, viewWorkPartOfCatalogueSection)

import Element exposing (Element, column, el, fill, fillPortion, height, link, maximum, padding, paragraph, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.PartOf exposing (PartOf(..), PartOfSectionBody, PartOfType(..), RelatedBlock, extractUrlAndLabelFromPartOf)
import Page.RecordTypes.Publication exposing (BasicPublicationBody, WorkCatalogueStatus(..))
import Page.UI.Attributes exposing (headingMD, headingSM, linkColour)
import Page.UI.Components exposing (formatPublicationStatusBadge)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Style exposing (colourScheme)


viewPartOfSection : Language -> PartOfSectionBody -> Element msg
viewPartOfSection language partOf =
    viewPartOfSectionImpl language localTranslations.partOfCollection partOf


viewHoldingPartOfSection : Language -> PartOfSectionBody -> Element msg
viewHoldingPartOfSection language partOf =
    viewPartOfSectionImpl language localTranslations.source partOf


viewWorkPartOfCatalogueSection : Language -> PartOfSectionBody -> Element msg
viewWorkPartOfCatalogueSection language partOf =
    viewPartOfSectionImpl language localTranslations.workCatalogues partOf


viewPartOfSectionImpl : Language -> LanguageMap -> PartOfSectionBody -> Element msg
viewPartOfSectionImpl language title partOf =
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
            , viewPartOfBoxBody language partOf
            ]
        ]


viewPartOfBoxBody : Language -> PartOfSectionBody -> Element msg
viewPartOfBoxBody language partOf =
    let
        primaryParts =
            List.filter (\p -> p.relationshipType == PrimaryPartOf) partOf.items
                |> List.map
                    (\b ->
                        case b.relatedTo of
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
                |> List.map (\s -> viewOtherPartRouter language s)
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
    row
        [ width fill ]
        [ column
            [ width (fillPortion 1)
            , padding 10
            ]
            [ viewMaybe text relBlock.workInfo ]
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
                        { url = partOf.id
                        , label = text (extractLabelFromLanguageMap language partOf.label)
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
                { url = primaryUrl
                , label = text (extractLabelFromLanguageMap language primaryLabel)
                }
            ]
        ]


viewOtherPartRouter : Language -> RelatedBlock -> Element msg
viewOtherPartRouter language relBlock =
    case relBlock.relatedTo of
        PublicationPart p ->
            viewPartOfSecondaryWorkCatalogue language relBlock p

        SourcePart s ->
            viewPartOfTitle language s

        WorkPart w ->
            viewPartOfTitle language w


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
        , Border.widthEach { top = 1, bottom = 0, left = 0, right = 0 }
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
                        { url = partOf.id
                        , label = text label
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
                { url = id
                , label = text (extractLabelFromLanguageMap language label)
                }
            ]
        ]
