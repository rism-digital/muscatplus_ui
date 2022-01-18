module Page.Front.Views.FrontKeywordQuery exposing (..)

import Element exposing (Element, alignLeft, alignRight, alignTop, below, centerY, column, el, fill, fillPortion, height, htmlAttribute, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.UI.Attributes exposing (headingLG, headingMD, headingSM, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (h1, h2, h5)
import Page.UI.Events exposing (onEnter)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Page.UI.Tooltip exposing (facetHelp)


frontKeywordQueryInput :
    Language
    ->
        { submitMsg : msg
        , changeMsg : String -> msg
        }
    -> String
    -> Element msg
frontKeywordQueryInput language msgs queryText =
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , alignRight
            , spacing sectionSpacing
            ]
            [ row
                [ width fill
                , spacing lineSpacing
                ]
                [ column
                    [ width <| fillPortion 6 ]
                    [ Input.text
                        [ width fill
                        , height (px 60)
                        , centerY
                        , htmlAttribute (HA.autocomplete False)
                        , Border.rounded 0
                        , onEnter msgs.submitMsg
                        , headingLG
                        , paddingXY 10 20
                        ]
                        { onChange = \inp -> msgs.changeMsg inp
                        , placeholder = Just (Input.placeholder [ height fill ] <| el [ centerY ] (text (extractLabelFromLanguageMap language localTranslations.queryEnter)))
                        , text = queryText
                        , label = Input.labelHidden (extractLabelFromLanguageMap language localTranslations.search)
                        }
                    ]
                , column
                    [ width <| fillPortion 1, height fill, Background.color (colourScheme.lightBlue |> convertColorToElementColor) ]
                    [ el [ centerY, width fill, Font.center ] (text "Search") ]
                ]
            ]
        ]
