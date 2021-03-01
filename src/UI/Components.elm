module UI.Components exposing (..)

import Element exposing (Attr, Attribute, Element, el, fill, paragraph, text, width)
import Element.Font as Font
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap)
import UI.Style exposing (bodyRegular, bodySM, headingLG, headingMD, headingSM, headingXL, headingXS, headingXXL)



-- HEADINGS


headingHelper : Attribute msg -> Language -> LanguageMap -> Element msg
headingHelper size language heading =
    el [ size ] (text (extractLabelFromLanguageMap language heading))


h1 : Language -> LanguageMap -> Element msg
h1 language heading =
    headingHelper headingXXL language heading


h2 : Language -> LanguageMap -> Element msg
h2 language heading =
    headingHelper headingXL language heading


h3 : Language -> LanguageMap -> Element msg
h3 language heading =
    headingHelper headingLG language heading


h4 : Language -> LanguageMap -> Element msg
h4 language heading =
    headingHelper headingMD language heading


h5 : Language -> LanguageMap -> Element msg
h5 language heading =
    headingHelper headingSM language heading


h6 : Language -> LanguageMap -> Element msg
h6 language heading =
    headingHelper headingXS language heading


label : Language -> LanguageMap -> Element msg
label language langmap =
    el [ Font.bold, bodyRegular ] (text (extractLabelFromLanguageMap language langmap))


value : Language -> LanguageMap -> Element msg
value language langmap =
    el [ bodyRegular ] (paragraph [ width fill ] [ text (extractLabelFromLanguageMap language langmap) ])
