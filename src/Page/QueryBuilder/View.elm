module Page.QueryBuilder.View exposing (view)

import Element as Event exposing (Element, alignBottom, alignLeft, alignRight, alignTop, below, centerX, centerY, column, el, fill, height, htmlAttribute, padding, paddingXY, paragraph, pointer, px, row, scrollbarY, shrink, spacing, text, textColumn, width)
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
import Page.RecordTypes.Probe exposing (ProbeStatus, QueryValidation)
import Page.RecordTypes.ResultMode exposing (ResultMode, resultModeHeader)
import Page.RecordTypes.Search exposing (QueryField)
import Page.UI.Attributes exposing (headingMD, lineSpacing, minimalInsetShadow)
import Page.UI.Components exposing (h1, h4)
import Page.UI.Facets.KeywordQuery exposing (viewKeywordQueryInput)
import Page.UI.Markdown as Markdown
import Page.UI.Search.SearchComponents exposing (hasActionableProbeResponse, hasActionableQueryValidation, viewProbeResponseNumbers)
import Page.UI.Style exposing (colourScheme)
import Page.UI.Tooltip exposing (facetHelp)


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
    { changeMsg : String -> QueryBuilderMsg
    , currentMode : ResultMode
    , language : Language
    , probeResponse : ProbeStatus
    , qText : String
    , queryFields : List QueryField
    , queryIsValid : QueryValidation
    , submitMsg : QueryBuilderMsg
    }
    -> Element QueryBuilderMsg
view cfg =
    let
        heading =
            resultModeHeader cfg.currentMode
                |> joinLanguageMaps ": " localTranslations.keywordQuery

        numberOfResults =
            viewProbeResponseNumbers cfg.language cfg.probeResponse
    in
    row
        [ width fill
        , height fill
        ]
        [ column
            [ width fill
            , height fill
            , padding 20
            , spacing 6
            ]
            [ row
                [ width fill
                , alignTop
                , spacing lineSpacing
                , height (px 40)
                ]
                [ column
                    [ centerX
                    , centerY
                    ]
                    [ facetHelp below "Use this to find any words, anywhere in a record." ]
                , column
                    [ width fill
                    , alignLeft
                    , centerY
                    ]
                    [ paragraph
                        [ spacing 10 ]
                        [ h1 cfg.language heading ]
                    ]
                ]
            , viewKeywordQueryInput
                { language = cfg.language
                , submitMsg = cfg.submitMsg
                , changeMsg = cfg.changeMsg
                , queryText = cfg.qText
                , queryIsValid = cfg.queryIsValid
                , userClickedOpenQueryBuilderMsg = NothingHappenedWithTheQueryBuilder
                , suppressQueryBuilderButton = True
                }
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
                        , viewOperator BoostOperator cfg.qText
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
                , spacing 20
                ]
                [ column
                    [ alignLeft
                    , Font.semiBold
                    ]
                    [ numberOfResults ]
                , column
                    []
                    [ viewSearchButton
                        { language = cfg.language
                        , probeResponse = cfg.probeResponse
                        , submitMsg = UserClickedSearchButton
                        }
                    ]
                ]
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
