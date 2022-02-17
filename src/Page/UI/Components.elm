module Page.UI.Components exposing (..)

import Color exposing (Color)
import Css
import Element exposing (Element, alignTop, column, el, fill, height, html, htmlAttribute, none, padding, paragraph, px, row, spacing, spacingXY, text, textColumn, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html as HT exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Html.Styled as HS exposing (toUnstyled)
import Html.Styled.Attributes as HSA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, extractTextFromLanguageMap)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.UI.Attributes exposing (bodyRegular, bodySM, headingLG, headingMD, headingSM, headingXL, headingXS, headingXXL, labelFieldColumnAttributes, lineSpacing, sectionSpacing, valueFieldColumnAttributes, widthFillHeightFill)
import Page.UI.Style exposing (colourScheme, colours, convertColorToElementColor)
import Utlities exposing (toLinkedHtml)


{-|

    Implements headings with the 'paragraph' tag to ensure that they wrap if the
    lines are too long.

-}
headingHelper : List (Element.Attribute msg) -> Language -> LanguageMap -> Element msg
headingHelper attrib language heading =
    paragraph attrib [ text (extractLabelFromLanguageMap language heading) ]


h1 : Language -> LanguageMap -> Element msg
h1 language heading =
    headingHelper [ headingXXL, Region.heading 1, Font.medium ] language heading


h2 : Language -> LanguageMap -> Element msg
h2 language heading =
    headingHelper [ headingXL, Region.heading 2, Font.medium ] language heading


h3 : Language -> LanguageMap -> Element msg
h3 language heading =
    headingHelper [ headingLG, Region.heading 3, Font.medium ] language heading


h4 : Language -> LanguageMap -> Element msg
h4 language heading =
    headingHelper [ headingMD, Region.heading 4, Font.medium ] language heading


h5 : Language -> LanguageMap -> Element msg
h5 language heading =
    headingHelper [ headingSM, Region.heading 5, Font.medium ] language heading


h6 : Language -> LanguageMap -> Element msg
h6 language heading =
    headingHelper [ headingXS, Region.heading 6, Font.medium ] language heading


renderLabel : Language -> LanguageMap -> Element msg
renderLabel language langmap =
    paragraph
        [ Font.medium, bodyRegular ]
        [ text (extractLabelFromLanguageMap language langmap) ]


renderValue : Language -> LanguageMap -> Element msg
renderValue language value =
    textColumn
        [ bodyRegular
        , spacing lineSpacing
        ]
        (styledParagraphs (extractTextFromLanguageMap language value))


renderConcatenatedValue : Language -> LanguageMap -> Element msg
renderConcatenatedValue language concatValue =
    textColumn
        [ bodyRegular
        ]
        [ styledList (extractTextFromLanguageMap language concatValue) ]


fieldValueWrapper : List (Element msg) -> Element msg
fieldValueWrapper content =
    wrappedRow
        widthFillHeightFill
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            content
        ]


viewLabelValueField :
    (Language -> LanguageMap -> Element msg)
    -> Language
    -> List LabelValue
    -> Element msg
viewLabelValueField fmt language field =
    fieldValueWrapper <|
        List.map
            (\f ->
                wrappedRow
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ column
                        labelFieldColumnAttributes
                        [ renderLabel language f.label ]
                    , column
                        valueFieldColumnAttributes
                        [ fmt language f.value ]
                    ]
            )
            field


viewSummaryField : Language -> List LabelValue -> Element msg
viewSummaryField language field =
    viewLabelValueField renderConcatenatedValue language field


viewParagraphField : Language -> List LabelValue -> Element msg
viewParagraphField language field =
    viewLabelValueField renderValue language field


{-|

    Wraps a list of string values in paragraph markers so that they can be properly spaced, etc.

    Useful for rendering notes fields.

-}
styledParagraphs : List String -> List (Element msg)
styledParagraphs textList =
    let
        parsedHtml t =
            case toLinkedHtml t of
                Ok elements ->
                    elements

                Err errMsg ->
                    [ text errMsg ]
    in
    List.map
        (\t ->
            parsedHtml t
                |> paragraph
                    [ spacing lineSpacing ]
        )
        textList


{-|

    Concatenate lists into a single line with a semicolon separator. Useful for rendering lists of smaller values,
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


{-| The blue default checked box icon.

Modified to align the checkbox to the top of the label.

-}
basicCheckbox : Bool -> Element msg
basicCheckbox checked =
    Element.el
        [ htmlAttribute (HA.class "focusable")
        , Element.width
            (Element.px 14)
        , Element.height (Element.px 14)
        , Font.color (Element.rgb 1 1 1)
        , Element.alignTop
        , Font.size 9
        , Font.center
        , Border.rounded 3
        , Border.color <|
            if checked then
                Element.rgb (59 / 255) (153 / 255) (252 / 255)

            else
                Element.rgb (211 / 255) (211 / 255) (211 / 255)
        , Border.shadow
            { offset = ( 0, 0 )
            , blur = 1
            , size = 1
            , color =
                if checked then
                    Element.rgba (238 / 255) (238 / 255) (238 / 255) 0

                else
                    Element.rgb (238 / 255) (238 / 255) (238 / 255)
            }
        , Background.color <|
            if checked then
                Element.rgb (59 / 255) (153 / 255) (252 / 255)

            else
                Element.rgb 1 1 1
        , Border.width <|
            if checked then
                0

            else
                1
        , Element.inFront
            (Element.el
                [ Border.color (Element.rgb 1 1 1)
                , Element.height (Element.px 6)
                , Element.width (Element.px 9)
                , Element.rotate (degrees -45)
                , Element.centerX
                , Element.centerY
                , Element.moveUp 1
                , Element.transparent (not checked)
                , Border.widthEach
                    { top = 0
                    , left = 2
                    , bottom = 2
                    , right = 0
                    }
                ]
                Element.none
            )
        ]
        Element.none


dividerWithText : String -> Element msg
dividerWithText dividerText =
    let
        { red, green, blue, alpha } =
            colours.slateGrey

        beforeAndAfterStyles =
            [ Css.property "content" "\"\""
            , Css.flexGrow <| Css.num 1
            , Css.height <| Css.px 1
            , Css.lineHeight <| Css.px 0
            , Css.fontSize <| Css.px 0
            , Css.margin2 (Css.px 0) (Css.px 8)
            , Css.backgroundColor <| Css.rgba red green blue 0.32
            ]

        finalEl =
            HS.div
                [ HSA.css
                    [ Css.before beforeAndAfterStyles
                    , Css.after beforeAndAfterStyles
                    , Css.displayFlex
                    , Css.flexBasis <| Css.pct 100
                    , Css.alignItems Css.center
                    , Css.color <| Css.rgba red green blue 1
                    , Css.margin2 (Css.px 8) (Css.px 0)
                    , Css.textTransform Css.uppercase
                    ]
                ]
                [ HS.text dividerText ]
    in
    toUnstyled finalEl
        |> html
