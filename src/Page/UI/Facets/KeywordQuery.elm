module Page.UI.Facets.KeywordQuery exposing (KeywordInputConfig, searchKeywordInput, viewFrontKeywordQueryInput)

{-|

    Used for the main search input box.

-}

import Element exposing (Color, Element, alignLeft, alignRight, alignTop, below, centerX, centerY, column, el, fill, fillPortion, height, htmlAttribute, paddingXY, pointer, px, row, spacing, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.RecordTypes.Probe exposing (QueryValidation(..))
import Page.UI.Attributes exposing (bodySM, headingXXL, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (h2s)
import Page.UI.Events exposing (onEnter)
import Page.UI.Images exposing (circleSvg)
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


status : String -> QueryValidation -> Element msg
status queryText queryIsValid =
    let
        queryValidationWithEmptyCheck =
            if String.isEmpty queryText then
                EmptyQuery

            else
                queryIsValid

        ( statusColor, statusMessage ) =
            case queryValidationWithEmptyCheck of
                ValidQuery ->
                    ( colourScheme.lightGreen, "Query is valid" )

                InvalidQuery ->
                    ( colourScheme.red, "Query is not valid" )

                EmptyQuery ->
                    ( colourScheme.midGrey, "" )

                CheckingQuery ->
                    ( colourScheme.yellow, "Checking query ..." )

                NotCheckedQuery ->
                    ( colourScheme.midGrey, "" )
    in
    row
        [ width fill
        , spacing 4
        ]
        [ el
            [ alignLeft
            , width (px 10)
            , height (px 10)
            ]
            (circleSvg statusColor)
        , el
            [ alignLeft
            , bodySM
            ]
            (text statusMessage)
        ]


searchKeywordInput :
    KeywordInputConfig msg
    -> Element msg
searchKeywordInput { language, submitMsg, changeMsg, queryText, queryIsValid, userClickedOpenQueryBuilderMsg } =
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
                [ status queryText queryIsValid
                , el
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
                [ status queryText queryIsValid
                , el
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
