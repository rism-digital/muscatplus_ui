module Page.QueryBuilder.View exposing (view)

import Config as C
import Element as Event exposing (Element, alignBottom, alignLeft, alignRight, alignTop, clipY, column, el, fill, height, htmlAttribute, link, newTabLink, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, joinLanguageMaps, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.QueryBuilder.Model exposing (QueryBuilderOperator(..), queryBuilderOperatorToLabel)
import Page.QueryBuilder.Msg exposing (QueryBuilderMsg(..))
import Page.RecordTypes.Probe exposing (ProbeStatus, QueryValidation(..))
import Page.RecordTypes.ResultMode exposing (ResultMode, resultModeHeader)
import Page.RecordTypes.Search exposing (QueryField)
import Page.UI.Attributes exposing (bodySM, headingMD, headingXXL, linkColour, minimalDropShadow, minimalInsetShadow)
import Page.UI.Components exposing (h3s, h4)
import Page.UI.Images exposing (circleSvg)
import Page.UI.Search.SearchComponents exposing (queryValidationState, viewProbeResponseNumbers)
import Page.UI.Style exposing (colourScheme)


view :
    { language : Language
    , probeResponse : ProbeStatus
    , qText : String
    , queryFields : List QueryField
    , currentMode : ResultMode
    }
    -> Element QueryBuilderMsg
view cfg =
    let
        header =
            resultModeHeader cfg.currentMode

        queryValidationWithEmptyCheck =
            if String.isEmpty cfg.qText then
                EmptyQuery

            else
                queryValidationState cfg.probeResponse

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

        status =
            row
                [ width fill
                , spacing 4
                ]
                [ el [ alignLeft, width (px 10), height (px 10) ] (circleSvg statusColor)
                , el [ alignLeft, bodySM ] (text statusMessage)
                ]

        probeResponse =
            viewProbeResponseNumbers cfg.language cfg.probeResponse
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , padding 10
            , spacing 6
            ]
            [ row
                [ width fill
                , alignLeft
                ]
                [ joinLanguageMaps ": " localTranslations.keywordQuery header
                    |> h3s cfg.language
                ]
            , row
                [ width fill ]
                [ Input.text
                    [ width fill
                    , htmlAttribute (HA.autocomplete False)
                    , Border.rounded 0

                    --, onEnter cfg.submitMsg
                    , headingXXL
                    , Font.medium
                    , paddingXY 10 12
                    ]
                    { label = Input.labelHidden (extractLabelFromLanguageMap cfg.language localTranslations.search)
                    , onChange = UserEnteredTextInQueryBuilder

                    --, onChange = \inp -> cfg.changeMsg inp
                    , placeholder =
                        Just
                            (Input.placeholder
                                []
                                (text (extractLabelFromLanguageMap cfg.language localTranslations.wordsAnywhere))
                            )
                    , text = cfg.qText
                    }
                ]
            , row
                [ width fill
                , height (px 25)
                ]
                [ column
                    [ alignLeft ]
                    [ status ]
                , column
                    [ alignRight
                    , bodySM
                    ]
                    [ probeResponse ]
                ]
            , row
                [ width fill
                , height fill
                , padding 8
                , spacing 8
                ]
                [ column
                    [ height fill
                    , spacing 8
                    ]
                    [ row
                        [ width fill
                        ]
                        [ h4 cfg.language (toLanguageMap "Available fields") ]
                    , row
                        [ width fill
                        , height fill
                        , alignTop
                        ]
                        [ viewQueryFields cfg.language cfg.qText cfg.queryFields ]
                    , row
                        [ width fill ]
                        [ h4 cfg.language (toLanguageMap "Available operators")
                        ]
                    , row
                        [ width fill
                        , alignTop
                        , spacing 8
                        ]
                        [ viewOperator AndOperator cfg.qText
                        , viewOperator OrOperator cfg.qText
                        , viewOperator NotOperator cfg.qText
                        , viewOperator PlusOperator cfg.qText
                        , viewOperator MinusOperator cfg.qText
                        , viewOperator FuzzyOperator cfg.qText
                        ]
                    ]
                , column
                    [ width fill
                    , height fill
                    , alignTop
                    ]
                    [ row
                        [ width fill
                        , alignTop
                        ]
                        [ h4 cfg.language (toLanguageMap "How to search")
                        ]
                    , row
                        [ width fill
                        , height fill
                        , alignTop
                        ]
                        [ textColumn
                            [ width fill
                            , alignTop
                            ]
                            [ paragraph
                                [ alignTop ]
                                [ text "Use the query builder to create specific queries on the available search fields."
                                ]
                            , paragraph
                                [ alignTop ]
                                [ text """The search fields available for each record type (Sources, People, Institutions, Incipits) are 
                                shown in the available fields list. This allows for searching on specific record fields.""" ]
                            , paragraph
                                [ alignTop ]
                                [ text """Several query operators are also available to help broaden or restrict your searches further.""" ]
                            , paragraph
                                [ alignTop ]
                                [ text """More information and examples may be found """
                                , newTabLink [ linkColour ]
                                    { url = C.serverUrl ++ "/docs/query-builder/introduction/"
                                    , label = text "in the documentation."
                                    }
                                ]
                            ]
                        ]
                    ]
                ]
            , row
                [ alignBottom
                , alignRight
                ]
                [ text "search"
                ]
            ]
        ]


viewOperator : QueryBuilderOperator -> String -> Element QueryBuilderMsg
viewOperator operator qText =
    el
        [ Border.rounded 5
        , Border.width 1
        , Border.color colourScheme.darkBlue
        , Background.color colourScheme.lightBlue
        , padding 4
        , Font.color colourScheme.white
        , alignTop
        , alignLeft
        , pointer
        , onClick (UserClickedOnOperator operator qText)
        ]
        (queryBuilderOperatorToLabel operator
            |> text
        )


viewQueryFields : Language -> String -> List QueryField -> Element QueryBuilderMsg
viewQueryFields language qText qFields =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ alignTop
            , width (px 300)
            , height fill
            , Border.color colourScheme.darkBlue
            , Border.width 1
            , spacing 4
            , padding 6
            , minimalInsetShadow
            ]
            [ row
                [ width fill
                , height fill
                , scrollbarY
                , htmlAttribute (HA.style "min-height" "unset")
                ]
                [ column
                    [ width fill
                    , alignTop
                    ]
                    (List.map (viewQueryField language qText) qFields)
                ]
            ]
        ]


viewQueryField : Language -> String -> QueryField -> Element QueryBuilderMsg
viewQueryField language qText qField =
    row
        [ padding 4
        , alignTop
        , width fill
        , onClick (UserClickedOnFieldName qField.alias qText)
        , pointer
        , Event.mouseOver [ Background.color colourScheme.lightestBlue ]
        ]
        [ el
            [ alignTop ]
            (text (extractLabelFromLanguageMap language qField.label))
        ]
