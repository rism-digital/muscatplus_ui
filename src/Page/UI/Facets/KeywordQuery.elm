module Page.UI.Facets.KeywordQuery exposing (KeywordInputConfig, searchKeywordInput, viewFrontKeywordQueryInput)

{-|

    Used for the main search input box.

-}

import Color exposing (toCssString)
import Element exposing (Element, alignLeft, alignRight, alignTop, below, centerX, centerY, column, el, fill, fillPortion, height, htmlAttribute, paddingXY, pointer, row, spacing, text, toRgb, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Probe exposing (QueryValidation(..))
import Page.UI.Attributes exposing (emptyHtmlAttribute, headingXXL, lineSpacing)
import Page.UI.Components exposing (h2s)
import Page.UI.Events exposing (onEnter)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (facetHelp)


type alias KeywordInputConfig msg =
    { language : Language
    , submitMsg : msg
    , changeMsg : String -> msg
    , queryText : String
    , queryIsValid : QueryValidation
    , userClickedOpenQueryBuilderMsg : msg
    }


keywordInputHelp : String
keywordInputHelp =
    """
    Use this to find any words, anywhere in a record.
    """


status : String -> QueryValidation -> Html.Attribute msg
status queryText queryIsValid =
    let
        queryValidationWithEmptyCheck =
            if String.isEmpty queryText then
                EmptyQuery

            else
                queryIsValid

        ( statusIcon, _ ) =
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
                    ( correctIcon, "Query is valid" )

                InvalidQuery ->
                    let
                        incorrectCssCode =
                            toRgb colourScheme.red
                                |> Color.fromRgba
                                |> toCssString

                        incorrectIcon =
                            HA.style "background" ("transparent url('data:image/svg+xml;utf8,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 384 512\"><path fill=\"" ++ incorrectCssCode ++ "\" d=\"M378.4 71.4c8.5-10.1 7.2-25.3-2.9-33.8s-25.3-7.2-33.8 2.9L192 218.7 42.4 40.6C33.9 30.4 18.7 29.1 8.6 37.6S-2.9 61.3 5.6 71.4L160.7 256 5.6 440.6c-8.5 10.2-7.2 25.3 2.9 33.8s25.3 7.2 33.8-2.9L192 293.3 341.6 471.4c8.5 10.1 23.7 11.5 33.8 2.9s11.5-23.7 2.9-33.8L223.3 256l155-184.6z\"/></svg>') no-repeat right/30px")
                    in
                    ( incorrectIcon, "Query is not valid" )

                EmptyQuery ->
                    ( emptyHtmlAttribute, "" )

                CheckingQuery ->
                    ( emptyHtmlAttribute, "Checking query ..." )

                NotCheckedQuery ->
                    ( emptyHtmlAttribute, "" )
    in
    statusIcon


searchKeywordInput :
    KeywordInputConfig msg
    -> Element msg
searchKeywordInput { language, submitMsg, changeMsg, queryText, queryIsValid, userClickedOpenQueryBuilderMsg } =
    let
        statusIconAttribute =
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
                , alignTop
                , spacing lineSpacing
                ]
                [ column
                    [ centerX
                    , centerY
                    ]
                    [ facetHelp below keywordInputHelp ]
                , column
                    [ width fill
                    , alignLeft
                    , alignTop
                    ]
                    [ row
                        [ spacing 10 ]
                        [ h2s language localTranslations.keywordQuery ]
                    ]
                ]
            , row
                [ width fill ]
                [ Input.text
                    [ width fill
                    , htmlAttribute (HA.autocomplete False)
                    , Border.rounded 0
                    , onEnter submitMsg
                    , headingXXL
                    , Font.medium
                    , paddingXY 10 12
                    , htmlAttribute statusIconAttribute
                    , htmlAttribute (HA.style "background-size" "10px")
                    ]
                    { label = Input.labelHidden (extractLabelFromLanguageMap language localTranslations.search)
                    , onChange = \inp -> changeMsg inp
                    , placeholder =
                        Just
                            (Input.placeholder
                                []
                                (text (extractLabelFromLanguageMap language localTranslations.wordsAnywhere))
                            )
                    , text = queryText
                    }
                ]
            , row
                [ width fill ]
                [ el
                    [ alignRight
                    , onClick userClickedOpenQueryBuilderMsg
                    , pointer
                    ]
                    (toLanguageMap "Create a query"
                        |> extractLabelFromLanguageMap language
                        |> text
                    )
                ]
            ]
        ]


viewFrontKeywordQueryInput :
    KeywordInputConfig msg
    -> Element msg
viewFrontKeywordQueryInput { language, submitMsg, changeMsg, queryText, queryIsValid, userClickedOpenQueryBuilderMsg } =
    let
        statusIconAttribute =
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
                        , Border.rounded 0
                        , onEnter submitMsg
                        , headingXXL
                        , Font.medium
                        , paddingXY 10 20
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
                [ el
                    [ alignRight
                    , onClick userClickedOpenQueryBuilderMsg
                    , pointer
                    ]
                    (toLanguageMap "Create a query"
                        |> extractLabelFromLanguageMap language
                        |> text
                    )
                ]
            ]
        ]
