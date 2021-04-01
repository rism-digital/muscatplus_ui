module UI.Components exposing (..)

import Element exposing (Attr, Attribute, Element, el, fill, html, link, paragraph, spacing, text, textColumn, width)
import Element.Font as Font
import Html as HT
import Html.Attributes as HA
import Html.Events as HE
import Shared.Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, extractTextFromLanguageMap)
import UI.Style exposing (bodyRegular, darkBlue, headingLG, headingMD, headingSM, headingXL, headingXS, headingXXL)



-- HEADINGS


{-|

    Implements headings with the 'paragraph' tag to ensure that they wrap if the
    lines are too long.

-}
headingHelper : List (Attribute msg) -> Language -> LanguageMap -> Element msg
headingHelper attrib language heading =
    paragraph attrib [ text (extractLabelFromLanguageMap language heading) ]


h1 : Language -> LanguageMap -> Element msg
h1 language heading =
    headingHelper [ headingXXL ] language heading


h2 : Language -> LanguageMap -> Element msg
h2 language heading =
    headingHelper [ headingXL ] language heading


h3 : Language -> LanguageMap -> Element msg
h3 language heading =
    headingHelper [ headingLG ] language heading


h4 : Language -> LanguageMap -> Element msg
h4 language heading =
    headingHelper [ headingMD ] language heading


h5 : Language -> LanguageMap -> Element msg
h5 language heading =
    headingHelper [ headingSM ] language heading


h6 : Language -> LanguageMap -> Element msg
h6 language heading =
    headingHelper [ headingXS, Font.semiBold ] language heading


label : Language -> LanguageMap -> Element msg
label language langmap =
    el [ Font.bold, bodyRegular ] (text (extractLabelFromLanguageMap language langmap))


value : Language -> LanguageMap -> Element msg
value language langmap =
    textColumn
        [ spacing 10
        , bodyRegular
        ]
        (styledParagraphs (extractTextFromLanguageMap language langmap))


{-|

    Wraps a list of string values in paragraph markers so that they can be properly spaced, etc.

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


styledLink : String -> String -> Element msg
styledLink url labelString =
    link
        [ bodyRegular
        , Font.underline
        , Font.color darkBlue
        ]
        { url = url
        , label = text labelString
        }


{-|

    Expects a message type to return when a value has been chosen, and a list of
    values to fill out the options, e.g., [("en", "English"), ("fr", "French")]

-}
languageSelect : (String -> msg) -> List ( String, String ) -> Element msg
languageSelect msg options =
    html
        (HT.select
            [ HE.onInput msg ]
            (List.map (\( val, name ) -> HT.option [ HA.value val ] [ HT.text name ]) options)
        )
