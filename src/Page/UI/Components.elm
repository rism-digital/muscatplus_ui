module Page.UI.Components exposing
    ( DropdownSelectConfig
    , basicCheckbox
    , dividerWithText
    , dropdownSelect
    , dropdownSelectOption
    , dropdownSelectParentStyles
    , dropdownSelectStyles
    , fieldValueWrapper
    , h1
    , h2
    , h3
    , h4
    , h5
    , h6
    , makeFlagIcon
    , renderConcatenatedValue
    , renderLabel
    , renderLanguageHelper
    , renderParagraph
    , renderValue
    , styledList
    , styledParagraphs
    , viewLabelValueField
    , viewParagraphField
    , viewSummaryField
    )

import Color exposing (Color)
import Css
import Element exposing (Element, alignLeft, alignRight, alignTop, centerX, centerY, column, el, fill, height, html, htmlAttribute, inFront, moveUp, none, padding, paragraph, px, rgb, rgba, rotate, row, spacing, text, textColumn, transparent, width, wrappedRow)
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
import Page.UI.Attributes exposing (bodyRegular, bodySM, headingLG, headingMD, headingSM, headingXL, headingXS, headingXXL, labelFieldColumnAttributes, lineSpacing, valueFieldColumnAttributes)
import Page.UI.Style exposing (colours, convertColorToElementColor)
import Utlities exposing (toLinkedHtml)


type alias DropdownSelectConfig a msg =
    { selectedMsg : String -> msg
    , mouseDownMsg : Maybe msg
    , mouseUpMsg : Maybe msg
    , choices : List ( String, String )
    , choiceFn : String -> a
    , currentChoice : a
    , selectIdent : String
    , label : Maybe LanguageMap
    , language : Language
    }


{-| The blue default checked box icon.

Modified to align the checkbox to the top of the label.

-}
basicCheckbox : Bool -> Element msg
basicCheckbox checked =
    el
        [ htmlAttribute (HA.class "focusable")
        , width (px 14)
        , height (px 14)
        , Font.color (rgb 1 1 1)
        , alignTop
        , Font.size 9
        , Font.center
        , Border.rounded 3
        , Border.color <|
            if checked then
                rgb (59 / 255) (153 / 255) (252 / 255)

            else
                rgb (211 / 255) (211 / 255) (211 / 255)
        , Border.shadow
            { blur = 1
            , color =
                if checked then
                    rgba (238 / 255) (238 / 255) (238 / 255) 0

                else
                    rgb (238 / 255) (238 / 255) (238 / 255)
            , offset = ( 0, 0 )
            , size = 1
            }
        , Background.color <|
            if checked then
                rgb (59 / 255) (153 / 255) (252 / 255)

            else
                rgb 1 1 1
        , Border.width <|
            if checked then
                0

            else
                1
        , inFront
            (el
                [ Border.color (rgb 1 1 1)
                , height (px 6)
                , width (px 9)
                , rotate (degrees -45)
                , centerX
                , centerY
                , moveUp 1
                , transparent (not checked)
                , Border.widthEach
                    { bottom = 2
                    , left = 2
                    , right = 0
                    , top = 0
                    }
                ]
                none
            )
        ]
        none


dividerWithText : String -> Element msg
dividerWithText dividerText =
    let
        beforeAndAfterStyles =
            [ Css.property "content" "\"\""
            , Css.flexGrow <| Css.num 1
            , Css.height <| Css.px 1
            , Css.lineHeight <| Css.px 0
            , Css.fontSize <| Css.px 0
            , Css.margin2 (Css.px 0) (Css.px 8)
            , Css.backgroundColor <| Css.rgba red green blue 0.32
            ]

        { red, green, blue } =
            colours.slateGrey

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


dropdownSelect :
    DropdownSelectConfig a msg
    -> Element msg
dropdownSelect cfg =
    let
        label =
            case cfg.label of
                Just s ->
                    column
                        [ width fill
                        , alignRight
                        ]
                        [ text <| extractLabelFromLanguageMap cfg.language s ]

                Nothing ->
                    none

        mouseDownMsg =
            case cfg.mouseDownMsg of
                Just m ->
                    HE.onMouseDown m

                Nothing ->
                    HA.classList []

        mouseUpMsg =
            case cfg.mouseUpMsg of
                Just m ->
                    HE.onMouseUp m

                Nothing ->
                    HA.classList []
    in
    row
        [ width fill
        , spacing lineSpacing
        ]
        [ label
        , column
            [ width fill
            , alignLeft
            ]
            [ html <|
                HT.div
                    dropdownSelectParentStyles
                    [ HT.select
                        (List.append
                            [ HE.onInput cfg.selectedMsg
                            , HA.id cfg.selectIdent
                            , mouseDownMsg
                            , mouseUpMsg
                            ]
                            dropdownSelectStyles
                        )
                        (List.map (\( val, name ) -> dropdownSelectOption val name cfg.choiceFn cfg.currentChoice) cfg.choices)
                    ]
            ]
        ]


dropdownSelectOption :
    String
    -> String
    -> (String -> a)
    -> a
    -> Html msg
dropdownSelectOption val name choiceFn currentChoice =
    let
        attrib =
            [ HA.value val
            , HA.selected isSelected
            ]

        isSelected =
            valToChoice == currentChoice

        valToChoice =
            choiceFn val
    in
    HT.option
        attrib
        [ HT.text name ]


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
    , HA.style "width" "auto"
    , HA.style "font-family" "inherit"
    , HA.style "font-size" "inherit"
    , HA.style "cursor" "inherit"
    , HA.style "line-height" "inherit"
    , HA.style "outline" "none"
    , HA.style "position" "relative"
    , HA.style "background" "transparent url('data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 448 512\"><g><path d=\"M207.029 381.476L12.686 187.132c-9.373-9.373-9.373-24.569 0-33.941l22.667-22.667c9.357-9.357 24.522-9.375 33.901-.04L224 284.505l154.745-154.021c9.379-9.335 24.544-9.317 33.901.04l22.667 22.667c9.373 9.373 9.373 24.569 0 33.941L240.971 381.476c-9.373 9.372-24.569 9.372-33.942 0z\" fill=\"LightSlateGray\"/></g></svg>') no-repeat"
    , HA.style "background-position" "right 5px top 50%"
    ]


fieldValueWrapper : List (Element msg) -> Element msg
fieldValueWrapper content =
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            , spacing lineSpacing
            ]
            content
        ]


h1 : Language -> LanguageMap -> Element msg
h1 language heading =
    renderLanguageHelper [ headingXXL, Region.heading 1, Font.medium ] language heading


h2 : Language -> LanguageMap -> Element msg
h2 language heading =
    renderLanguageHelper [ headingXL, Region.heading 2, Font.medium ] language heading


h3 : Language -> LanguageMap -> Element msg
h3 language heading =
    renderLanguageHelper [ headingLG, Region.heading 3, Font.medium ] language heading


h4 : Language -> LanguageMap -> Element msg
h4 language heading =
    renderLanguageHelper [ headingMD, Region.heading 4, Font.medium ] language heading


h5 : Language -> LanguageMap -> Element msg
h5 language heading =
    renderLanguageHelper [ headingSM, Region.heading 5, Font.medium ] language heading


h6 : Language -> LanguageMap -> Element msg
h6 language heading =
    renderLanguageHelper [ headingXS, Region.heading 6, Font.medium ] language heading


makeFlagIcon :
    { background : Color, foreground : Color }
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


renderConcatenatedValue : Language -> LanguageMap -> Element msg
renderConcatenatedValue language concatValue =
    textColumn
        [ bodyRegular
        ]
        [ styledList (extractTextFromLanguageMap language concatValue) ]


renderLabel : Language -> LanguageMap -> Element msg
renderLabel language langmap =
    renderLanguageHelper [ Font.medium, bodyRegular ] language langmap


{-|

    Implements headings with the 'paragraph' tag to ensure that they wrap if the
    lines are too long.

-}
renderLanguageHelper : List (Element.Attribute msg) -> Language -> LanguageMap -> Element msg
renderLanguageHelper attrib language heading =
    paragraph attrib [ text (extractLabelFromLanguageMap language heading) ]


renderParagraph : Language -> LanguageMap -> Element msg
renderParagraph language langmap =
    renderLanguageHelper [ bodyRegular, spacing lineSpacing ] language langmap


renderValue : Language -> LanguageMap -> Element msg
renderValue language value =
    textColumn
        [ bodyRegular
        , spacing lineSpacing
        ]
        (styledParagraphs (extractTextFromLanguageMap language value))


{-|

    Concatenate lists into a single line with a semicolon separator. Useful for rendering lists of smaller values,
    like instrumentation.

-}
styledList : List String -> Element msg
styledList textList =
    paragraph
        []
        [ text (String.join "; " textList) ]


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


viewParagraphField : Language -> List LabelValue -> Element msg
viewParagraphField language field =
    viewLabelValueField renderValue language field


viewSummaryField : Language -> List LabelValue -> Element msg
viewSummaryField language field =
    viewLabelValueField renderConcatenatedValue language field
