module Page.UI.Components exposing
    ( DropdownSelectConfig
    , Tab(..)
    , basicCheckbox
    , contentTypeIconChooser
    , dropdownSelect
    , externalLinkTemplate
    , h1
    , h2
    , h2s
    , h3
    , h3s
    , h4
    , h5
    , h6e
    , makeFlagIcon
    , mapViewer
    , pageBodyOrEmpty
    , renderLabel
    , resourceLink
    , sourceIconChooser
    , sourceIconView
    , sourceTypeIconChooser
    , tabView
    , verticalLine
    , viewMobileSummaryField
    , viewMobileWindowTitleBar
    , viewParagraphField
    , viewSummaryField
    , viewWindowTitleBar
    )

import Element exposing (Attribute, Color, Element, above, alignBottom, alignLeft, alignTop, centerX, centerY, column, el, fill, height, html, htmlAttribute, inFront, link, maximum, minimum, moveUp, newTabLink, none, padding, paddingEach, paddingXY, paragraph, pointer, px, rgb, rgba, rotate, row, spacing, text, transparent, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Region as Region
import Html as HT exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, extractTextFromLanguageMap, formatNumberByLanguage, limitLength)
import Language.LocalTranslations exposing (localTranslations)
import Maybe.Extra as ME
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.RecordTypes.SourceShared exposing (SourceContentType(..), SourceRecordType(..), SourceType(..))
import Page.UI.Animations exposing (animatedLoader)
import Page.UI.Attributes exposing (bodyRegular, bodySM, bodySerifFont, emptyAttribute, emptyHtmlAttribute, headingHero, headingLG, headingMD, headingSM, headingXL, headingXXL, labelFieldColumnAttributes, lineSpacing, linkColour, minimalDropShadow, sectionSpacing, valueFieldColumnAttributes)
import Page.UI.Helpers exposing (isExternalLink, viewIf, viewMaybe)
import Page.UI.Images exposing (bookCopySvg, bookOpenCoverSvg, bookOpenSvg, bookSvg, closeWindowSvg, commentsSvg, ellipsesSvg, externalLinkSvg, fileMusicSvg, graduationCapSvg, penNibSvg, printingPressSvg, rectanglesMixedSvg, shapesSvg, spinnerSvg)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (tooltip, tooltipStyle)
import Utilities exposing (choose, toLinkedHtml)
import Validate


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
    , inverted : Bool
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
        , Border.color
            (if checked then
                rgb (59 / 255) (153 / 255) (252 / 255)

             else
                rgb (211 / 255) (211 / 255) (211 / 255)
            )
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
        , Background.color
            (if checked then
                rgb (59 / 255) (153 / 255) (252 / 255)

             else
                rgb 1 1 1
            )
        , Border.width
            (if checked then
                0

             else
                1
            )
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


dropdownSelect :
    DropdownSelectConfig a msg
    -> Element msg
dropdownSelect cfg =
    let
        textColour =
            if cfg.inverted then
                "White"

            else
                "DarkSlateGrey"

        label =
            viewMaybe
                (\s ->
                    column
                        []
                        [ text (extractLabelFromLanguageMap cfg.language s) ]
                )
                cfg.label

        mouseDownMsg =
            ME.unwrap emptyHtmlAttribute HE.onMouseDown cfg.mouseDownMsg

        mouseUpMsg =
            ME.unwrap emptyHtmlAttribute HE.onMouseUp cfg.mouseUpMsg
    in
    row
        [ width fill
        , spacing lineSpacing
        , bodySM
        ]
        [ label
        , column
            [ width fill
            , alignLeft
            ]
            [ html
                (HT.div
                    (List.append
                        [ HA.style "border-bottom" ("2px dotted " ++ textColour) ]
                        dropdownSelectParentStyles
                    )
                    [ HT.select
                        (List.append
                            [ HE.onInput cfg.selectedMsg
                            , HA.id cfg.selectIdent
                            , mouseDownMsg
                            , mouseUpMsg
                            , HA.style "color" textColour
                            , HA.style "background" ("transparent url('data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 448 512\"><g><path d=\"M207.029 381.476L12.686 187.132c-9.373-9.373-9.373-24.569 0-33.941l22.667-22.667c9.357-9.357 24.522-9.375 33.901-.04L224 284.505l154.745-154.021c9.379-9.335 24.544-9.317 33.901.04l22.667 22.667c9.373 9.373 9.373 24.569 0 33.941L240.971 381.476c-9.373 9.372-24.569 9.372-33.942 0z\" fill=\"" ++ textColour ++ "\"/></g></svg>') no-repeat")
                            ]
                            dropdownSelectStyles
                        )
                        (List.map (\( val, name ) -> dropdownSelectOption val name cfg.choiceFn cfg.currentChoice) cfg.choices)
                    ]
                )
            ]
        ]


dropdownSelectOption :
    String
    -> String
    -> (String -> a)
    -> a
    -> Html msg
dropdownSelectOption val name choiceFn currentChoice =
    HT.option
        [ HA.value val
        , HA.selected (choiceFn val == currentChoice)
        ]
        [ HT.text name ]


dropdownSelectParentStyles : List (HT.Attribute msg)
dropdownSelectParentStyles =
    [ HA.style "border-radius" "0.25em"
    , HA.style "font-size" "inherit"
    , HA.style "width" "auto"
    , HA.style "cursor" "pointer"
    , HA.style "line-height" "1.2"
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
    , HA.style "background-position" "right 5px top 50%"
    ]


h1 : Language -> LanguageMap -> Element msg
h1 language heading =
    paragraph
        [ headingHero
        , Region.heading 1
        , Font.medium
        , bodySerifFont
        , htmlAttribute (HA.style "font-size" "calc(24px + 0.2vw)")
        , htmlAttribute (HA.style "line-height" "2rem")
        ]
        [ limitLength 140 heading
            |> extractLabelFromLanguageMap language
            |> text
        ]


h2 : Language -> LanguageMap -> Element msg
h2 language heading =
    paragraph [ headingXXL, Region.heading 2, Font.medium ] [ extractLabelFromLanguageMap language heading |> text ]


h2s : Language -> LanguageMap -> Element msg
h2s language heading =
    paragraph [ headingXXL, Region.heading 2, Font.medium, bodySerifFont ] [ extractLabelFromLanguageMap language heading |> text ]


h3 : Language -> LanguageMap -> Element msg
h3 language heading =
    paragraph [ headingXL, Region.heading 3, Font.medium ] [ extractLabelFromLanguageMap language heading |> text ]


h3s : Language -> LanguageMap -> Element msg
h3s language heading =
    paragraph [ headingXL, Region.heading 3, Font.medium, bodySerifFont ] [ extractLabelFromLanguageMap language heading |> text ]


h4 : Language -> LanguageMap -> Element msg
h4 language heading =
    paragraph [ headingLG, Region.heading 4, Font.medium ] [ extractLabelFromLanguageMap language heading |> text ]


h5 : Language -> LanguageMap -> Element msg
h5 language heading =
    paragraph [ headingMD, Region.heading 5, Font.medium ] [ extractLabelFromLanguageMap language heading |> text ]


h6e : Language -> LanguageMap -> Element msg
h6e language heading =
    el [ headingSM, Region.heading 6, Font.medium ] (text (extractLabelFromLanguageMap language heading))


makeFlagIcon :
    { background : Color
    }
    -> Element msg
    -> String
    -> Element msg
makeFlagIcon colours iconImage iconLabel =
    column
        [ width (px 25)
        , height (px 25)
        , padding 2
        , Background.color colours.background
        , el tooltipStyle (text iconLabel)
            |> tooltip above
        ]
        [ el
            [ width (px 16)
            , height (px 16)
            , centerY
            , centerX
            ]
            iconImage
        ]


textColumn : List (Attribute msg) -> List (Element msg) -> Element msg
textColumn attrs children =
    column
        (width (fill |> minimum 320 |> maximum 700)
            :: attrs
        )
        children


renderLabel : Language -> LanguageMap -> Element msg
renderLabel language langmap =
    paragraph
        [ Font.semiBold, bodyRegular ]
        [ text (extractLabelFromLanguageMap language langmap) ]


resourceLink : String -> (List (Attribute msg) -> { label : Element msg, url : String } -> Element msg)
resourceLink url =
    choose (isExternalLink url) (always newTabLink) (always link)


containsHtml : String -> Bool
containsHtml txt =
    -- If there is no open bracket, there is no HTML.
    -- If there is an open bracket, there might be HTML
    -- If there is a link inline, also render as HTML
    String.contains "<" txt || String.contains "http" txt


isHttpUrl : String -> Bool
isHttpUrl txt =
    String.startsWith "http" txt


isMailtoUrl : String -> Bool
isMailtoUrl txt =
    if String.contains "@" txt then
        Validate.isValidEmail txt

    else
        False


parsedHtml : String -> List (Element msg)
parsedHtml txt =
    -- Don't run the HTML Parser and escaping stuff
    -- if there is no chance that the text contains HTML.
    if isHttpUrl txt then
        [ resourceLink txt
            [ linkColour ]
            { label = text txt
            , url = txt
            }
        , externalLinkTemplate txt
        ]

    else if isMailtoUrl txt then
        [ newTabLink
            [ linkColour ]
            { label = text txt
            , url = "mailto:" ++ txt
            }
        , externalLinkTemplate txt
        ]

    else if not (containsHtml txt) then
        [ paragraph
            []
            [ text txt ]
        ]

    else
        -- fall back to processing the text as HTML by default.
        toLinkedHtml txt


listRenderer : String -> Element msg
listRenderer txt =
    wrappedRow
        [ spacing 4
        ]
        (parsedHtml txt)


{-|

    Wraps a list of string values in paragraph markers so that they can be properly spaced, etc.

    Useful for rendering notes fields.

-}
styledParagraphs : List String -> List (Element msg)
styledParagraphs textList =
    List.map listRenderer textList


viewLabelValueField :
    List (Attribute msg)
    -> Language
    -> List LabelValue
    -> Element msg
viewLabelValueField wrapperStyles language field =
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            (List.append
                [ width fill
                , height fill
                , alignTop
                ]
                wrapperStyles
            )
            (List.map
                (\{ label, value } ->
                    wrappedRow
                        [ width fill
                        , height fill
                        , alignTop
                        ]
                        [ column labelFieldColumnAttributes
                            [ renderLabel language label ]
                        , column valueFieldColumnAttributes
                            (extractTextFromLanguageMap language value
                                |> styledParagraphs
                            )
                        ]
                )
                field
            )
        ]


viewMobileLabelValueField :
    List (Attribute msg)
    -> Language
    -> List LabelValue
    -> Element msg
viewMobileLabelValueField wrapperStyles language field =
    wrappedRow
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            (List.append
                [ width fill
                , height fill
                , alignTop
                ]
                wrapperStyles
            )
            (List.concatMap
                (\{ label, value } ->
                    [ row
                        [ width fill, paddingEach { bottom = 4, left = 0, right = 0, top = 0 } ]
                        [ renderLabel language label ]
                    , row
                        [ width fill, paddingEach { bottom = 8, left = 10, right = 0, top = 0 } ]
                        [ paragraph []
                            (extractTextFromLanguageMap language value
                                |> styledParagraphs
                            )
                        ]
                    ]
                )
                field
            )
        ]


viewParagraphField : Language -> List LabelValue -> Element msg
viewParagraphField language fieldValues =
    viewLabelValueField
        [ spacing sectionSpacing ]
        language
        fieldValues


viewSummaryField : Language -> List LabelValue -> Element msg
viewSummaryField language fieldValues =
    viewLabelValueField
        [ spacing lineSpacing ]
        language
        fieldValues


viewMobileSummaryField : Language -> List LabelValue -> Element msg
viewMobileSummaryField language fieldValues =
    viewMobileLabelValueField
        [ spacing 4 ]
        language
        fieldValues


mapViewer : ( Int, Int ) -> String -> Element msg
mapViewer ( width, height ) iframeUrl =
    HT.iframe
        [ HA.src iframeUrl
        , HA.width width
        , HA.height height
        , HA.style "border" "1px solid #AAA"
        ]
        []
        |> html


sourceIconView : SourceRecordType -> Element msg
sourceIconView recordType =
    let
        sourceIcon =
            sourceIconChooser recordType
    in
    el
        [ width (px 25)
        , height (px 25)
        , centerX
        , alignTop
        ]
        (sourceIcon colourScheme.darkBlue)


sourceIconChooser : SourceRecordType -> (Color -> Element msg)
sourceIconChooser recordType =
    case recordType of
        SourceItemRecord ->
            bookOpenSvg

        SourceSingleItemRecord ->
            bookOpenCoverSvg

        SourceCollectionRecord ->
            bookSvg

        SourceCompositeRecord ->
            bookCopySvg


sourceTypeIconChooser : SourceType -> (Color -> Element msg)
sourceTypeIconChooser sourceType =
    case sourceType of
        PrintedSource ->
            printingPressSvg

        ManuscriptSource ->
            penNibSvg

        CompositeSource ->
            rectanglesMixedSvg

        UnspecifiedSource ->
            \_ -> none


contentTypeIconChooser : SourceContentType -> (Color -> Element msg)
contentTypeIconChooser contentType =
    case contentType of
        LibrettoContent ->
            commentsSvg

        TreatiseContent ->
            graduationCapSvg

        MusicalContent ->
            fileMusicSvg

        MixedContent ->
            shapesSvg

        OtherContent ->
            ellipsesSvg


externalLinkTemplate : String -> Element msg
externalLinkTemplate url =
    let
        externalImg =
            el
                [ width (px 12)
                , height (px 12)
                , tooltip above
                    -- TODO: Translate
                    (el tooltipStyle (text "External link"))
                ]
                (externalLinkSvg colourScheme.midGrey)
    in
    isExternalLink url
        |> viewIf externalImg


pageBodyOrEmpty : Language -> Bool -> List (Element msg) -> List (Element msg)
pageBodyOrEmpty language isEmpty nonEmptyBody =
    if isEmpty then
        [ el
            [ Font.italic
            , headingXL
            ]
            (extractLabelFromLanguageMap language localTranslations.noAdditionalDetails
                |> text
            )
        ]

    else
        nonEmptyBody


type Tab
    = CountTab LanguageMap (Maybe Int)
    | BareTab LanguageMap


tabView :
    { clickMsg : msg
    , icon : Element msg
    , isSelected : Bool
    , language : Language
    , tab : Tab
    }
    -> Element msg
tabView cfg =
    let
        ( backgroundColour, fontColour ) =
            if cfg.isSelected then
                ( Background.color colourScheme.darkBlue
                , Font.color colourScheme.white
                )

            else
                ( Background.color colourScheme.white
                , Font.color colourScheme.black
                )

        tabLabel =
            case cfg.tab of
                CountTab label count ->
                    let
                        tabIcon =
                            el
                                []
                                cfg.icon
                    in
                    case count of
                        Just num ->
                            let
                                searchCount =
                                    toFloat num
                                        |> formatNumberByLanguage cfg.language
                            in
                            row
                                [ width fill
                                , Font.center
                                , alignLeft
                                , centerY
                                ]
                                [ tabIcon
                                , el [] (text (extractLabelFromLanguageMap cfg.language label))
                                , el [] (text (" (" ++ searchCount ++ ")"))
                                ]

                        Nothing ->
                            row
                                [ width fill
                                , Font.center
                                , alignLeft
                                , centerY
                                ]
                                [ tabIcon
                                , el [] (text (extractLabelFromLanguageMap cfg.language label))
                                , el []
                                    (animatedLoader
                                        [ width (px 15)
                                        , height (px 15)
                                        ]
                                        (spinnerSvg colourScheme.midGrey)
                                    )
                                ]

                BareTab label ->
                    row
                        [ width fill
                        , Font.center
                        , alignLeft
                        , centerY
                        ]
                        [ el [] (text (extractLabelFromLanguageMap cfg.language label)) ]
    in
    column
        [ alignLeft
        , alignBottom
        , Font.center
        , if cfg.isSelected then
            Font.semiBold

          else
            Font.medium
        , height fill
        , paddingXY 20 2
        , Border.widthEach { bottom = 0, left = 1, right = 1, top = 1 }
        , Border.color colourScheme.darkGrey
        , minimalDropShadow
        , htmlAttribute (HA.style "clip-path" "inset(-5px -5px 0px -5px)")
        , onClick cfg.clickMsg
        , backgroundColour
        , fontColour
        , pointer
        ]
        [ tabLabel
        ]


verticalLine : Element msg
verticalLine =
    el
        [ height fill
        , Border.widthEach { bottom = 0, left = 0, right = 1, top = 0 }
        , Border.color colourScheme.midGrey
        ]
        none


viewWindowTitleBar : Language -> LanguageMap -> msg -> Element msg
viewWindowTitleBar language title closeMsg =
    row
        [ width fill
        , height (px 30)
        , spacing 10
        , paddingXY 10 0
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color colourScheme.darkBlue
        , Background.color colourScheme.darkBlue
        ]
        [ el
            [ alignLeft
            , centerY
            , onClick closeMsg
            , width (px 18)
            , height (px 18)
            , pointer
            ]
            (closeWindowSvg colourScheme.white)
        , el
            [ alignLeft
            , centerY
            , Font.color colourScheme.white
            , width fill
            ]
            (h4 language title)
        ]


viewMobileWindowTitleBar : Language -> msg -> Element msg
viewMobileWindowTitleBar language closeMsg =
    row
        [ width fill
        , height (px 60)
        , spacing 10
        , paddingXY 10 0
        , Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
        , Border.color colourScheme.darkBlue
        , Background.color colourScheme.darkBlue
        ]
        [ el
            [ alignLeft
            , centerY
            , onClick closeMsg
            , width (px 32)
            , height (px 32)
            , pointer
            ]
            (closeWindowSvg colourScheme.white)
        , el
            [ alignLeft
            , centerY
            , Font.color colourScheme.white
            , width fill
            ]
            (h4 language localTranslations.recordPreview)
        ]
