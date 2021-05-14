module UI.Components exposing (..)

import Element exposing (Element, html)
import Html as HT exposing (Attribute, Html)
import Html.Attributes as HA
import Html.Events as HE
import Language exposing (Language, parseLocaleToLanguage)


languageParentStyles : List (Attribute msg)
languageParentStyles =
    [ HA.style "width" "100%"
    , HA.style "min-width" "15ch"
    , HA.style "max-width" "30ch"
    , HA.style "border-radius" "0.25em"
    , HA.style "font-size" "1rem"
    , HA.style "cursor" "pointer"
    , HA.style "line-height" "1.2"
    ]


languageSelectStyles : List (Attribute msg)
languageSelectStyles =
    [ HA.style "box-sizing" "border-box"
    , HA.style "appearance" "none"
    , HA.style "background-color" "transparent"
    , HA.style "border" "none"
    , HA.style "padding" "0 1em 0 0"
    , HA.style "margin" "0"
    , HA.style "width" "100%"
    , HA.style "font-family" "inherit"
    , HA.style "font-size" "inherit"
    , HA.style "cursor" "inherit"
    , HA.style "line-height" "inherit"
    , HA.style "outline" "none"
    ]


{-|

    Expects a message type to return when a value has been chosen, and a list of
    values to fill out the options, e.g., [("en", "English"), ("fr", "French")]

-}
languageSelect : (String -> msg) -> List ( String, String ) -> Language -> Element msg
languageSelect msg options currentLanguage =
    html
        (HT.div
            (List.append [] languageParentStyles)
            [ HT.select
                (List.append [ HE.onInput msg ] languageSelectStyles)
                (List.map (\( val, name ) -> languageSelectOption val name currentLanguage) options)
            ]
        )


languageSelectOption : String -> String -> Language -> Html msg
languageSelectOption val name currentLanguage =
    let
        lang =
            parseLocaleToLanguage val

        isCurrentLanguage =
            lang == currentLanguage

        attrib =
            [ HA.value val
            , HA.selected isCurrentLanguage
            ]
    in
    HT.option
        attrib
        [ HT.text name ]
