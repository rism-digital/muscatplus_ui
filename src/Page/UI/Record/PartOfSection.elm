module Page.UI.Record.PartOfSection exposing (viewPartOfSection)

import Element exposing (Element, column, el, fill, height, link, paddingXY, row, shrink, spacing, text, width)
import Element.Border as Border
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Source exposing (PartOfSectionBody)
import Page.UI.Attributes exposing (headingLG, lineSpacing, linkColour)
import Page.UI.Style exposing (colourScheme)


viewPartOfSection : Language -> PartOfSectionBody -> Element msg
viewPartOfSection language partOf =
    row
        [ width shrink
        , Border.widthEach { bottom = 1, left = 1, right = 1, top = 5 }
        , Border.color colourScheme.darkBlue
        , paddingXY 10 20
        ]
        [ column
            [ width fill
            , height fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill ]
                [ el
                    [ headingLG ]
                    (text (extractLabelFromLanguageMap language localTranslations.partOfCollection ++ ": "))
                , link
                    [ linkColour
                    , headingLG
                    ]
                    { label = text (extractLabelFromLanguageMap language (.label partOf.source))
                    , url = .id partOf.source
                    }
                ]
            ]
        ]
