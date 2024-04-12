module Page.UI.Record.PartOfSection exposing (viewPartOfSection)

import Element exposing (Element, column, el, fill, height, link, minimum, padding, paddingXY, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.UI.Attributes exposing (headingLG, lineSpacing, linkColour)
import Page.UI.Style exposing (colourScheme)


viewPartOfSection : Language -> PartOfSectionBody -> Element msg
viewPartOfSection language partOf =
    row
        [ width shrink
        , Border.color colourScheme.olive
        , Border.width 1
        , width (shrink |> minimum 800)
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , Background.color colourScheme.olive
                , padding 10
                ]
                [ el
                    [ headingLG
                    , Font.semiBold
                    , Font.color colourScheme.white
                    ]
                    (text (extractLabelFromLanguageMap language localTranslations.partOfCollection))
                ]
            , row
                [ width fill
                , padding 10
                ]
                [ link
                    [ linkColour
                    , headingLG
                    ]
                    { label = text (extractLabelFromLanguageMap language (.label partOf.source))
                    , url = .id partOf.source
                    }
                ]
            ]
        ]
