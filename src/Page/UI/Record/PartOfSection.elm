module Page.UI.Record.PartOfSection exposing (viewHoldingPartOfSection, viewPartOfSection)

import Element exposing (Element, column, el, fill, height, link, padding, row, shrink, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.UI.Attributes exposing (headingMD, linkColour)
import Page.UI.Style exposing (colourScheme)


viewPartOfSection : Language -> PartOfSectionBody -> Element msg
viewPartOfSection language partOf =
    viewPartOfSectionImpl language localTranslations.partOfCollection partOf


viewHoldingPartOfSection : Language -> PartOfSectionBody -> Element msg
viewHoldingPartOfSection language partOf =
    viewPartOfSectionImpl language localTranslations.source partOf


viewPartOfSectionImpl : Language -> LanguageMap -> PartOfSectionBody -> Element msg
viewPartOfSectionImpl language title partOf =
    row
        [ width shrink
        , Border.color colourScheme.darkGrey
        , Border.width 1
        , width fill
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
            , row
                [ width fill
                , padding 10
                ]
                [ link
                    [ linkColour
                    , headingMD
                    ]
                    { label = text (extractLabelFromLanguageMap language (.label partOf.source))
                    , url = .id partOf.source
                    }
                ]
            ]
        ]
