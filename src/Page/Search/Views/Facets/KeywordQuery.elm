module Page.Search.Views.Facets.KeywordQuery exposing (..)

{-|

    Used for the main search input box.

-}

import Element exposing (Element, alignLeft, alignRight, alignTop, below, column, fill, htmlAttribute, paddingXY, row, spacing, text, width)
import Element.Border as Border
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.UI.Attributes exposing (headingSM, lineSpacing)
import Page.UI.Components exposing (h5)
import Page.UI.Events exposing (onEnter)
import Page.UI.Tooltip exposing (facetHelp)


keywordInputHelp =
    """
    Use this to find any words, anywhere in a record.
    """


searchKeywordInput :
    Language
    ->
        { submitMsg : msg
        , changeMsg : String -> msg
        }
    -> String
    -> Element msg
searchKeywordInput language msgs queryText =
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
                    , onEnter msgs.submitMsg
                    , headingSM
                    , paddingXY 10 12
                    ]
                    { onChange = \inp -> msgs.changeMsg inp
                    , placeholder = Just (Input.placeholder [] (text (extractLabelFromLanguageMap language localTranslations.queryEnter)))
                    , text = queryText
                    , label = Input.labelHidden (extractLabelFromLanguageMap language localTranslations.search)
                    }
                ]
            ]
        ]
