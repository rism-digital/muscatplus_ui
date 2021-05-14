module Search.SearchInput exposing (..)

import Element exposing (Element, alignRight, centerX, centerY, column, fill, fillPortion, height, htmlAttribute, paddingXY, px, row, shrink, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Helpers.Events exposing (onEnter)
import Html.Attributes
import Language exposing (extractLabelFromLanguageMap, localTranslations)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Search exposing (Message(..))
import UI.Attributes exposing (headingSM)
import UI.Style exposing (colourScheme)


searchKeywordInput : Model -> Element Msg
searchKeywordInput model =
    let
        activeSearch =
            model.search

        queryObj =
            activeSearch.query

        qText =
            Maybe.withDefault "" queryObj.query

        currentLanguage =
            model.language
    in
    row
        [ centerX
        , centerY
        , width fill
        ]
        [ column
            [ width (fillPortion 11)
            , height shrink
            , alignRight
            ]
            [ Input.text
                [ width fill
                , height (px 60)
                , Border.widthEach { bottom = 1, top = 1, left = 1, right = 0 }
                , Border.roundEach { topLeft = 5, bottomLeft = 5, topRight = 0, bottomRight = 0 }
                , htmlAttribute (Html.Attributes.autocomplete False)
                , Border.color colourScheme.darkBlue
                , onEnter (SearchInterface Search.Submit)
                , headingSM
                , paddingXY 10 18
                ]
                { onChange = \inp -> SearchInterface (Input inp)
                , placeholder = Just (Input.placeholder [] (text (extractLabelFromLanguageMap currentLanguage localTranslations.queryEnter)))
                , text = qText
                , label = Input.labelHidden (extractLabelFromLanguageMap currentLanguage localTranslations.search)
                }
            ]
        , column
            [ width (fillPortion 1) ]
            [ Input.button
                [ Border.widthEach { bottom = 1, top = 1, left = 0, right = 1 }
                , Border.roundEach { topLeft = 0, bottomLeft = 0, topRight = 5, bottomRight = 5 }
                , Border.color colourScheme.darkBlue
                , Background.color colourScheme.darkBlue
                , paddingXY 10 10
                , height (px 60)
                , width fill
                , Font.center
                , Font.color colourScheme.white
                , headingSM
                ]
                { onPress = Just (SearchInterface Submit)
                , label = text (extractLabelFromLanguageMap currentLanguage localTranslations.search)
                }
            ]
        ]
