module Page.QueryBuilder.View exposing (view)

import Config as C
import Element as Event exposing (Element, alignBottom, alignLeft, alignRight, alignTop, centerY, clipY, column, el, fill, height, htmlAttribute, link, newTabLink, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, shrink, spacing, text, textColumn, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language(..), LanguageMap, LanguageValue(..), extractLabelFromLanguageMap, joinLanguageMaps, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.QueryBuilder.Model exposing (QueryBuilderOperator(..), queryBuilderOperatorToLabel)
import Page.QueryBuilder.Msg exposing (QueryBuilderMsg(..))
import Page.RecordTypes.Probe exposing (ProbeStatus, QueryValidation(..))
import Page.RecordTypes.ResultMode exposing (ResultMode, resultModeHeader)
import Page.RecordTypes.Search exposing (QueryField)
import Page.UI.Attributes exposing (bodySM, headingMD, headingXXL, linkColour, minimalDropShadow, minimalInsetShadow)
import Page.UI.Components exposing (h3s, h4)
import Page.UI.Images exposing (circleSvg)
import Page.UI.Markdown as Markdown
import Page.UI.Search.SearchComponents exposing (hasActionableProbeResponse, hasActionableQueryValidation, queryValidationState, viewProbeResponseNumbers)
import Page.UI.Style exposing (colourScheme)


qbDescriptionEnglish : String
qbDescriptionEnglish =
    """Use the query builder to create specific queries on the available search fields.

The search fields available for each record type (Sources, People, Institutions, Incipits) are shown in the
available fields list. This allows for searching on specific record fields.

Several query operators are also available to help broaden or restrict your searches further.

More information and examples may be found [in the documentation](/docs/query-builder/introduction/).
"""


qbDescriptionGerman : String
qbDescriptionGerman =
    """Use the query builder to create specific queries on the available search fields.

The search fields available for each record type (Sources, People, Institutions, Incipits) are shown in the
available fields list. This allows for searching on specific record fields.

Several query operators are also available to help broaden or restrict your searches further.

More information and examples may be found [in the documentation](/docs/query-builder/introduction/).
"""


qbDescriptionItalian : String
qbDescriptionItalian =
    """Use the query builder to create specific queries on the available search fields.

The search fields available for each record type (Sources, People, Institutions, Incipits) are shown in the
available fields list. This allows for searching on specific record fields.

Several query operators are also available to help broaden or restrict your searches further.

More information and examples may be found [in the documentation](/docs/query-builder/introduction/).
"""


qbDescriptionFrench : String
qbDescriptionFrench =
    """Use the query builder to create specific queries on the available search fields.

The search fields available for each record type (Sources, People, Institutions, Incipits) are shown in the
available fields list. This allows for searching on specific record fields.

Several query operators are also available to help broaden or restrict your searches further.

More information and examples may be found [in the documentation](/docs/query-builder/introduction/).
"""


queryBuilderDescription : LanguageMap
queryBuilderDescription =
    [ LanguageValue English [ qbDescriptionEnglish ]
    , LanguageValue German [ qbDescriptionGerman ]
    , LanguageValue Italian [ qbDescriptionItalian ]
    , LanguageValue French [ qbDescriptionFrench ]
    ]


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
                    , spacing 8
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
                            [ Markdown.view cfg.language queryBuilderDescription
                            ]
                        ]
                    ]
                ]
            , row
                [ alignBottom
                , alignRight
                ]
                [ viewSearchButton { language = cfg.language, probeResponse = cfg.probeResponse, submitMsg = UserClickedSearchButton } ]
            ]
        ]


viewSearchButton :
    { language : Language
    , probeResponse : ProbeStatus
    , submitMsg : QueryBuilderMsg
    }
    -> Element QueryBuilderMsg
viewSearchButton cfg =
    let
        actionableProbeResponse =
            hasActionableProbeResponse cfg.probeResponse

        actionableQueryValidation =
            hasActionableQueryValidation cfg.probeResponse

        validProbeAndQueryResponse =
            actionableProbeResponse && actionableQueryValidation

        ( submitButtonColours, submitButtonMsg, submitPointerStyle ) =
            if validProbeAndQueryResponse then
                ( colourScheme.lightBlue
                , Just cfg.submitMsg
                , pointer
                )

            else
                ( colourScheme.midGrey
                , Nothing
                , htmlAttribute (HA.style "cursor" "not-allowed")
                )
    in
    Input.button
        [ Border.color submitButtonColours
        , Background.color submitButtonColours
        , height (px 35)
        , width shrink
        , Font.center
        , Font.color colourScheme.white
        , headingMD
        , submitPointerStyle
        , centerY
        , paddingXY 10 0
        ]
        { label = text (extractLabelFromLanguageMap cfg.language localTranslations.showResults)
        , onPress = submitButtonMsg
        }


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
