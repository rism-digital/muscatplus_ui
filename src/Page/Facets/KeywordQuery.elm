module Page.Facets.KeywordQuery exposing (..)

{-|

    Used for the main search input box.

-}

import Element exposing (Element, alignLeft, alignRight, alignTop, below, centerY, column, el, fill, fillPortion, height, htmlAttribute, paddingXY, px, row, spacing, text, width)
import Element.Border as Border
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.UI.Attributes exposing (headingLG, headingSM, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (h5)
import Page.UI.Events exposing (onEnter)
import Page.UI.Tooltip exposing (facetHelp)


keywordInputHelp =
    """
    Use this to find any words, anywhere in a record.
    """


type alias KeywordInputConfig msg =
    { language : Language
    , submitMsg : msg
    , changeMsg : String -> msg
    , queryText : String
    }


searchKeywordInput :
    KeywordInputConfig msg
    -> Element msg
searchKeywordInput { language, submitMsg, changeMsg, queryText } =
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , alignRight
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ column
                    [ alignTop ]
                    [ facetHelp below keywordInputHelp ]
                , column
                    [ width fill
                    , alignLeft
                    , alignTop
                    ]
                    [ row
                        [ spacing 10 ]
                        [ h5 language localTranslations.keywordQuery ]
                    ]
                ]
            , row
                [ width fill ]
                [ Input.text
                    [ width fill
                    , htmlAttribute (HA.autocomplete False)
                    , Border.rounded 0
                    , onEnter submitMsg
                    , headingSM
                    , paddingXY 10 12
                    ]
                    { onChange = \inp -> changeMsg inp
                    , placeholder = Just (Input.placeholder [] (text (extractLabelFromLanguageMap language localTranslations.queryEnter)))
                    , text = queryText
                    , label = Input.labelHidden (extractLabelFromLanguageMap language localTranslations.search)
                    }
                ]
            ]
        ]


viewFrontKeywordQueryInput :
    KeywordInputConfig msg
    -> Element msg
viewFrontKeywordQueryInput { language, submitMsg, changeMsg, queryText } =
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
                        , onEnter submitMsg
                        , headingLG
                        , paddingXY 10 20
                        ]
                        { onChange = \inp -> changeMsg inp
                        , placeholder = Just (Input.placeholder [ height fill ] <| el [ centerY ] (text (extractLabelFromLanguageMap language localTranslations.queryEnter)))
                        , text = queryText
                        , label = Input.labelHidden (extractLabelFromLanguageMap language localTranslations.search)
                        }
                    ]
                ]
            ]
        ]
