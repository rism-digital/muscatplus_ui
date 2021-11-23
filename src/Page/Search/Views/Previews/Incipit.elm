module Page.Search.Views.Previews.Incipit exposing (..)

import Element exposing (Element, column, el, fill, height, link, row, spacing, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, localTranslations)
import Page.RecordTypes.Incipit exposing (IncipitBody)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Components exposing (h4)
import Page.Views.Helpers exposing (viewMaybe)
import Page.Views.Incipits exposing (viewIncipit)


viewIncipitPreview : Language -> IncipitBody -> Element msg
viewIncipitPreview language body =
    let
        sourceUrl =
            case body.partOf of
                Just partOfBody ->
                    let
                        sourceBody =
                            partOfBody.source
                    in
                    sourceBody.id

                Nothing ->
                    ""

        incipitLink =
            row
                [ width fill ]
                [ el
                    []
                    (text (extractLabelFromLanguageMap language localTranslations.viewRecord ++ ": "))
                , link
                    [ linkColour ]
                    { url = sourceUrl
                    , label = text sourceUrl
                    }
                ]
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , spacing 10
            ]
            [ row
                [ width fill ]
                [ h4 language body.label ]
            , incipitLink
            , row
                [ width fill ]
                [ column
                    [ width fill
                    ]
                    [ viewMaybe (viewIncipit language) (Just body) ]
                ]
            ]
        ]
