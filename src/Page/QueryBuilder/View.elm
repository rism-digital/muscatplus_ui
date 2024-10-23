module Page.QueryBuilder.View exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, alignBottom, alignLeft, alignTop, centerX, centerY, column, el, fill, height, htmlAttribute, none, padding, paddingXY, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, toLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeStatus, QueryValidation(..))
import Page.RecordTypes.Search exposing (QueryField)
import Page.UI.Attributes exposing (bodySM, headingXXL, minimalDropShadow)
import Page.UI.Components exposing (viewWindowTitleBar)
import Page.UI.Images exposing (circleSvg)
import Page.UI.Search.SearchComponents exposing (queryValidationState)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))


viewQueryBuilder :
    { language : Language
    , model :
        { a
            | probeResponse : ProbeStatus
            , activeSearch : ActiveSearch msg
        }
    , changeMsg : String -> msg
    , searchResponse : Response ServerData

    --, queryText : String
    --, queryIsValid : QueryValidation
    , closeMsg : msg
    }
    -> Element msg
viewQueryBuilder cfg =
    let
        title =
            toLanguageMap "Query Builder"

        queryValidation =
            .probeResponse cfg.model
                |> queryValidationState

        qText =
            toNextQuery (.activeSearch cfg.model)
                |> toKeywordQuery
                |> Maybe.withDefault ""

        queryFields =
            case cfg.searchResponse of
                Response (SearchData body) ->
                    body.queryFields

                _ ->
                    []

        ( statusColor, statusMessage ) =
            case queryValidation of
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
        , height fill
        , Background.color colourScheme.translucentGrey
        , htmlAttribute (HA.attribute "style" "backdrop-filter: blur(3px); -webkit-backdrop-filter: blur(3px); z-index:200;")
        ]
        [ column
            [ centerX
            , centerY
            , width (px 900)
            , height (px 600)
            , Background.color colourScheme.white
            , Border.color colourScheme.darkBlue
            , Border.width 3
            , htmlAttribute (HA.style "z-index" "10")
            , minimalDropShadow
            ]
            [ viewWindowTitleBar cfg.language title cfg.closeMsg
            , row
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
                            , onChange = \inp -> cfg.changeMsg inp
                            , placeholder =
                                Just
                                    (Input.placeholder
                                        []
                                        (text (extractLabelFromLanguageMap cfg.language localTranslations.wordsAnywhere))
                                    )
                            , text = qText
                            }
                        ]
                    , row
                        [ width fill ]
                        [ status ]
                    , viewQueryFields cfg.language queryFields
                    , row
                        [ alignBottom
                        ]
                        [ text "search"
                        ]
                    ]
                ]
            ]
        ]


viewQueryFields : Language -> List QueryField -> Element msg
viewQueryFields language qFields =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ alignTop
            , width fill
            ]
            (List.map (\qf -> viewQueryField language qf) qFields)
        ]


viewQueryField : Language -> QueryField -> Element msg
viewQueryField language qField =
    row
        [ spacing 8
        , alignTop
        ]
        [ el [] (text (extractLabelFromLanguageMap language qField.label))
        , el [] (text qField.alias)
        ]
