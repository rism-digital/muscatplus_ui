module Page.UI.Record.PartOfSection exposing (viewHoldingPartOfSection, viewPartOfSection, viewWorkPartOfCatalogueSection)

import Element exposing (Element, column, el, fill, height, link, maximum, padding, paragraph, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.PartOf exposing (PartOf(..), PartOfSectionBody, extractUrlAndLabelFromPartOf)
import Page.UI.Attributes exposing (headingMD, linkColour)
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
    let
        ( url, label ) =
            extractUrlAndLabelFromPartOf partOf.partOf

        otherParts =
            Maybe.map (viewOtherParts language) partOf.other
                |> Maybe.withDefault []
    in
    row
        [ Border.color colourScheme.darkGrey
        , Border.width 1
        , width (fill |> maximum 800)
        ]
        [ column
            [ width fill
            , height fill
            ]
            (List.concat
                [ [ row
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
                  , row
                        [ width fill
                        , padding 10
                        ]
                        [ paragraph []
                            [ link
                                [ linkColour
                                , headingMD
                                , Font.semiBold
                                ]
                                { label = text (extractLabelFromLanguageMap language label)
                                , url = url
                                }
                            ]
                        ]
                  ]
                , otherParts
                ]
            )
        ]


viewOtherParts : Language -> List PartOf -> List (Element msg)
viewOtherParts language parts =
    List.map (viewOtherPart language) parts


viewOtherPart : Language -> PartOf -> Element msg
viewOtherPart language part =
    let
        ( url, label ) =
            extractUrlAndLabelFromPartOf part

        otherLabel =
            case part of
                PublicationPart p ->
                    "(" ++ extractLabelFromLanguageMap language (.label p.status) ++ ") "

                _ ->
                    ""
    in
    row
        [ width fill
        , padding 10
        ]
        [ column
            [ width fill ]
            [ row
                [ width fill ]
                [ paragraph
                    []
                    [ text otherLabel
                    , link [ linkColour ]
                        { label = text (extractLabelFromLanguageMap language label)
                        , url = url
                        }
                    ]
                ]
            ]
        ]
