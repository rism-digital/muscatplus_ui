module Page.UI.Facets.KeywordQuery exposing (KeywordInputConfig, searchKeywordInput, viewFrontKeywordQueryInput)

{-|

    Used for the main search input box.

-}

import Element exposing (Element, alignLeft, alignRight, alignTop, below, centerX, centerY, column, el, fill, fillPortion, height, htmlAttribute, paddingXY, pointer, px, row, spacing, text, width)
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
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


searchKeywordInput :
    KeywordInputConfig msg
    -> Element msg
searchKeywordInput { language, submitMsg, changeMsg, queryText, queryIsValid, userClickedOpenQueryBuilderMsg } =
    let
        ( statusColor, statusMessage ) =
            case queryIsValid of
                ValidQuery ->
                    ( colourScheme.lightGreen, "Query is valid" )

                InvalidQuery ->
                    ( colourScheme.red, "Query is not valid" )

                CheckingQuery ->
                    ( colourScheme.yellow, "Checking query ..." )

                NotCheckedQuery ->
                    ( colourScheme.midGrey, "" )

        status =
            row
                [ width fill
                , spacing 4
                ]
                [ el [ alignLeft, width (px 10), height (px 10) ] (circleSvg statusColor)
                , el [ alignLeft, bodySM ] (text statusMessage)
                ]
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
                [ status
                , el
                    [ alignRight
                    , onClick userClickedOpenQueryBuilderMsg
                    , pointer
                    ]
                    (text "Query Builder")
                ]
            ]
        ]


viewFrontKeywordQueryInput :
    KeywordInputConfig msg
    -> Element msg
viewFrontKeywordQueryInput { language, submitMsg, changeMsg, queryText } =
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , alignRight
            , spacing sectionSpacing
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
            ]
        ]
