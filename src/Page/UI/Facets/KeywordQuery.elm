module Page.UI.Facets.KeywordQuery exposing (KeywordInputConfig, viewKeywordQueryInput)

{-|

    Used for the main search input box.

-}

import Color exposing (toCssString)
import Element exposing (Element, alignLeft, alignRight, alignTop, centerY, column, el, fill, fillPortion, height, htmlAttribute, padding, pointer, row, spacing, text, toRgb, width)
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Probe exposing (QueryValidation(..))
import Page.UI.Attributes exposing (emptyHtmlAttribute, headingMD, lineSpacing, linkColour, minimalInsetShadow)
import Page.UI.Events exposing (onEnter)
import Page.UI.Helpers exposing (viewIf, viewMaybe)
import Page.UI.Style exposing (colourScheme)


type alias KeywordInputConfig msg =
    { language : Language
    , submitMsg : msg
    , changeMsg : String -> msg
    , queryText : String
    , queryIsValid : QueryValidation
    , userClickedOpenQueryBuilderMsg : msg
    , suppressQueryBuilderButton : Bool
    }


status : String -> QueryValidation -> ( Html.Attribute msg, Maybe LanguageMap )
status queryText queryIsValid =
    let
        queryValidationWithEmptyCheck =
            if String.isEmpty queryText then
                EmptyQuery

            else
                queryIsValid
    in
    case queryValidationWithEmptyCheck of
        ValidQuery ->
            let
                correctCssCode =
                    toRgb colourScheme.lightGreen
                        |> Color.fromRgba
                        |> toCssString

                correctIcon =
                    HA.style "background" ("transparent url('data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 448 512\"><path fill=\"" ++ correctCssCode ++ "\" d=\"M441 103c9.4 9.4 9.4 24.6 0 33.9L177 401c-9.4 9.4-24.6 9.4-33.9 0L7 265c-9.4-9.4-9.4-24.6 0-33.9s24.6-9.4 33.9 0l119 119L407 103c9.4-9.4 24.6-9.4 33.9 0z\"/></svg>') no-repeat right/30px")
            in
            ( correctIcon, Nothing )

        InvalidQuery message ->
            let
                incorrectCssCode =
                    toRgb colourScheme.red
                        |> Color.fromRgba
                        |> toCssString

                incorrectIcon =
                    HA.style "background" ("transparent url('data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 384 512\"><path fill=\"" ++ incorrectCssCode ++ "\" d=\"M378.4 71.4c8.5-10.1 7.2-25.3-2.9-33.8s-25.3-7.2-33.8 2.9L192 218.7 42.4 40.6C33.9 30.4 18.7 29.1 8.6 37.6S-2.9 61.3 5.6 71.4L160.7 256 5.6 440.6c-8.5 10.2-7.2 25.3 2.9 33.8s25.3 7.2 33.8-2.9L192 293.3 341.6 471.4c8.5 10.1 23.7 11.5 33.8 2.9s11.5-23.7 2.9-33.8L223.3 256l155-184.6z\"/></svg>') no-repeat right/20px")
            in
            ( incorrectIcon, Just message )

        EmptyQuery ->
            ( emptyHtmlAttribute, Nothing )

        CheckingQuery ->
            ( emptyHtmlAttribute, Nothing )

        NotCheckedQuery ->
            ( emptyHtmlAttribute, Nothing )


viewKeywordQueryInput :
    KeywordInputConfig msg
    -> Element msg
viewKeywordQueryInput { language, submitMsg, changeMsg, queryText, queryIsValid, userClickedOpenQueryBuilderMsg, suppressQueryBuilderButton } =
    let
        ( statusIconAttribute, statusMessage ) =
            status queryText queryIsValid
    in
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
                , spacing lineSpacing
                ]
                [ column
                    [ width (fillPortion 6) ]
                    [ Input.text
                        [ width fill
                        , centerY
                        , htmlAttribute (HA.id "ro-keyword-input")
                        , htmlAttribute (HA.autocomplete False)
                        , htmlAttribute (HA.autofocus True)
                        , htmlAttribute statusIconAttribute
                        , onEnter submitMsg
                        , headingMD
                        , Font.medium
                        , padding 12
                        , minimalInsetShadow
                        ]
                        { label = Input.labelHidden (extractLabelFromLanguageMap language localTranslations.search)
                        , onChange = \inp -> changeMsg inp
                        , placeholder =
                            Just
                                (Input.placeholder
                                    [ height fill ]
                                    (el
                                        [ centerY ]
                                        (text (extractLabelFromLanguageMap language localTranslations.wordsAnywhere))
                                    )
                                )
                        , text = queryText
                        }
                    ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewMaybe
                        (\message ->
                            el
                                [ alignLeft
                                , Font.color colourScheme.darkOrange
                                , Font.semiBold

                                --, Background.color colourScheme.red
                                , padding 8
                                , headingMD
                                ]
                                (text (extractLabelFromLanguageMap language message))
                        )
                        statusMessage
                    ]
                , column
                    [ width fill ]
                    [ viewIf
                        (el
                            [ alignRight
                            , centerY
                            , onClick userClickedOpenQueryBuilderMsg
                            , pointer
                            , padding 5
                            , linkColour
                            ]
                            (toLanguageMap "Create a query"
                                |> extractLabelFromLanguageMap language
                                |> text
                            )
                        )
                        (not suppressQueryBuilderButton)
                    ]
                ]
            ]
        ]
