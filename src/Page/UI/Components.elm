module Page.UI.Components exposing (..)

import Color exposing (Color)
import Element exposing (Element, alignRight, alignTop, centerX, centerY, column, el, fill, fillPortion, height, html, htmlAttribute, padding, paddingXY, paragraph, px, row, shrink, spacing, text, textColumn, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Html as HT exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Language exposing (Language, LanguageMap, dateFormatter, extractLabelFromLanguageMap, extractTextFromLanguageMap, localTranslations, parseLocaleToLanguage)
import Page.RecordTypes.Shared exposing (LabelValue, RecordHistory)
import Page.UI.Attributes exposing (bodyRegular, bodySM, headingLG, headingMD, headingSM, headingXL, headingXS, headingXXL)
import Page.UI.Events exposing (onEnter)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Time exposing (utc)


{-|

    Implements headings with the 'paragraph' tag to ensure that they wrap if the
    lines are too long.

-}
headingHelper : List (Element.Attribute msg) -> Language -> LanguageMap -> Element msg
headingHelper attrib language heading =
    paragraph attrib [ text (extractLabelFromLanguageMap language heading) ]


h1 : Language -> LanguageMap -> Element msg
h1 language heading =
    headingHelper [ headingXXL, Region.heading 1 ] language heading


h2 : Language -> LanguageMap -> Element msg
h2 language heading =
    headingHelper [ headingXL, Region.heading 2 ] language heading


h3 : Language -> LanguageMap -> Element msg
h3 language heading =
    headingHelper [ headingLG, Region.heading 3 ] language heading


h4 : Language -> LanguageMap -> Element msg
h4 language heading =
    headingHelper [ headingMD, Region.heading 4, Font.medium ] language heading


h5 : Language -> LanguageMap -> Element msg
h5 language heading =
    headingHelper [ headingSM, Region.heading 5, Font.medium ] language heading


h6 : Language -> LanguageMap -> Element msg
h6 language heading =
    headingHelper [ headingXS, Font.semiBold, Region.heading 6 ] language heading


label : Language -> LanguageMap -> Element msg
label language langmap =
    paragraph
        [ Font.medium, bodyRegular ]
        [ text (extractLabelFromLanguageMap language langmap) ]


value : Language -> LanguageMap -> Element msg
value language langmap =
    textColumn
        [ spacing 10
        , bodyRegular
        ]
        (styledParagraphs (extractTextFromLanguageMap language langmap))


concatenatedValue : Language -> LanguageMap -> Element msg
concatenatedValue language langmap =
    textColumn
        [ spacing 10
        , bodyRegular
        ]
        [ styledList (extractTextFromLanguageMap language langmap) ]


viewLabelValueField :
    (Language -> LanguageMap -> Element msg)
    -> Language
    -> List LabelValue
    -> Element msg
viewLabelValueField fmt language field =
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            (List.map
                (\f ->
                    wrappedRow
                        [ width fill
                        , height fill
                        , paddingXY 0 10
                        , alignTop
                        ]
                        [ column
                            [ width (fillPortion 1)
                            , alignTop
                            ]
                            [ label language f.label ]
                        , column
                            [ width (fillPortion 4)
                            , alignTop
                            ]
                            [ fmt language f.value ]
                        ]
                )
                field
            )
        ]


viewSummaryField : Language -> List LabelValue -> Element msg
viewSummaryField language field =
    viewLabelValueField concatenatedValue language field


viewParagraphField : Language -> List LabelValue -> Element msg
viewParagraphField language field =
    viewLabelValueField value language field


{-|

    Wraps a list of string values in paragraph markers so that they can be properly spaced, etc.

    Useful for rendering notes fields.

-}
styledParagraphs : List String -> List (Element msg)
styledParagraphs textList =
    List.map
        (\t ->
            paragraph
                []
                [ el [] (text t) ]
        )
        textList


{-|

    Concatenate lists with a semicolon. Useful for rendering lists of smaller values,
    like instrumentation.

-}
styledList : List String -> Element msg
styledList textList =
    paragraph
        []
        [ text (String.join "; " textList) ]


dropdownSelectParentStyles : List (HT.Attribute msg)
dropdownSelectParentStyles =
    [ HA.style "border-radius" "0.25em"
    , HA.style "font-size" "inherit"
    , HA.style "width" "auto"
    , HA.style "cursor" "pointer"
    , HA.style "line-height" "1.2"
    , HA.style "border-bottom" "2px dotted #778899"
    , HA.style "position" "relative"
    ]


dropdownSelectStyles : List (HT.Attribute msg)
dropdownSelectStyles =
    [ HA.style "box-sizing" "border-box"
    , HA.style "appearance" "none"
    , HA.style "-webkit-appearance" "none"
    , HA.style "border" "none"
    , HA.style "padding" "0 1.8em 0 0"
    , HA.style "margin" "0"
    , HA.style "width" "100%"
    , HA.style "font-family" "inherit"
    , HA.style "font-size" "inherit"
    , HA.style "cursor" "inherit"
    , HA.style "line-height" "inherit"
    , HA.style "outline" "none"
    , HA.style "position" "relative"
    , HA.style "background" "transparent url('data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 448 512\"><g><path d=\"M207.029 381.476L12.686 187.132c-9.373-9.373-9.373-24.569 0-33.941l22.667-22.667c9.357-9.357 24.522-9.375 33.901-.04L224 284.505l154.745-154.021c9.379-9.335 24.544-9.317 33.901.04l22.667 22.667c9.373 9.373 9.373 24.569 0 33.941L240.971 381.476c-9.373 9.372-24.569 9.372-33.942 0z\" fill=\"LightSlateGray\"/></g></svg>') no-repeat"
    , HA.style "background-position" "right 5px top 50%"
    ]


{-|

    a) Function that converts the selected value to a message value
    b) A list of values and labels for the values
    c) Function that converts the value to a type
    d) The selected value as a type

-}
dropdownSelect :
    (String -> msg)
    -> List ( String, String )
    -> (String -> a)
    -> a
    -> Element msg
dropdownSelect msg options choiceFn currentChoice =
    html
        (HT.div
            (List.append [] dropdownSelectParentStyles)
            [ HT.select
                (List.append [ HE.onInput msg ] dropdownSelectStyles)
                (List.map (\( val, name ) -> dropdownSelectOption val name choiceFn currentChoice) options)
            ]
        )


dropdownSelectOption :
    String
    -> String
    -> (String -> a)
    -> a
    -> Html msg
dropdownSelectOption val name choiceFn currentChoice =
    let
        valToChoice =
            choiceFn val

        isSelected =
            valToChoice == currentChoice

        attrib =
            [ HA.value val
            , HA.selected isSelected
            ]
    in
    HT.option
        attrib
        [ HT.text name ]


{-|

    Used for the main search input box.

-}
searchKeywordInput :
    { submitMsg : msg
    , changeMsg : String -> msg
    }
    -> String
    -> Language
    -> Element msg
searchKeywordInput msgs queryText currentLanguage =
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
                , height (px 50)
                , Border.widthEach { bottom = 2, top = 2, left = 2, right = 0 }
                , Border.roundEach { topLeft = 5, bottomLeft = 5, topRight = 0, bottomRight = 0 }
                , htmlAttribute (HA.autocomplete False)
                , Border.color (colourScheme.darkBlue |> convertColorToElementColor)
                , onEnter msgs.submitMsg
                , headingSM
                , paddingXY 10 12
                ]
                { onChange = \inp -> msgs.changeMsg inp
                , placeholder = Just (Input.placeholder [] (text (extractLabelFromLanguageMap currentLanguage localTranslations.queryEnter)))
                , text = queryText
                , label = Input.labelHidden (extractLabelFromLanguageMap currentLanguage localTranslations.search)
                }
            ]
        , column
            [ width (fillPortion 1) ]
            [ Input.button
                [ Border.widthEach { bottom = 1, top = 1, left = 0, right = 1 }
                , Border.roundEach { topLeft = 0, bottomLeft = 0, topRight = 5, bottomRight = 5 }
                , Border.color (colourScheme.darkBlue |> convertColorToElementColor)
                , Background.color (colourScheme.darkBlue |> convertColorToElementColor)
                , paddingXY 10 10
                , height (px 50)
                , width fill
                , Font.center
                , Font.color (colourScheme.white |> convertColorToElementColor)
                , headingSM
                ]
                { onPress = Just msgs.submitMsg
                , label = text (extractLabelFromLanguageMap currentLanguage localTranslations.search)
                }
            ]
        ]


viewRecordHistory : RecordHistory -> Language -> Element msg
viewRecordHistory history language =
    let
        createdDateFormatted =
            dateFormatter utc history.created

        updatedDateFormatted =
            dateFormatter utc history.updated

        created =
            extractLabelFromLanguageMap language history.createdLabel ++ ": " ++ createdDateFormatted

        updated =
            extractLabelFromLanguageMap language history.updatedLabel ++ ": " ++ updatedDateFormatted
    in
    row
        [ width fill
        ]
        [ column
            [ width fill
            , spacing 10
            ]
            [ el
                [ alignRight
                , bodySM
                ]
                (text created)
            , el
                [ alignRight
                , bodySM
                ]
                (text updated)
            ]
        ]


makeFlagIcon :
    { foreground : Color, background : Color }
    -> Element msg
    -> String
    -> Element msg
makeFlagIcon colours iconImage iconLabel =
    column
        [ bodySM
        , padding 4
        , Border.width 1
        , Border.color (colours.foreground |> convertColorToElementColor)
        , Border.rounded 4
        , Background.color (colours.background |> convertColorToElementColor)
        ]
        [ row
            [ spacing 5
            , Font.color (colours.foreground |> convertColorToElementColor)
            ]
            [ el
                [ width (px 15)
                , height (px 15)
                ]
                iconImage
            , text iconLabel
            ]
        ]
