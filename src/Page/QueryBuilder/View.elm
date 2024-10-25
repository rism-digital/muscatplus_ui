module Page.QueryBuilder.View exposing (..)

import Element as Event exposing (Element, alignBottom, alignLeft, alignTop, column, el, fill, height, htmlAttribute, padding, paddingXY, pointer, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.QueryBuilder.Msg exposing (QueryBuilderMsg(..))
import Page.RecordTypes.Probe exposing (ProbeStatus, QueryValidation(..))
import Page.RecordTypes.Search exposing (QueryField)
import Page.UI.Attributes exposing (bodySM, headingXXL)
import Page.UI.Images exposing (circleSvg)
import Page.UI.Search.SearchComponents exposing (queryValidationState)
import Page.UI.Style exposing (colourScheme)


view :
    { language : Language
    , probeResponse : ProbeStatus
    , qText : String
    , queryFields : List QueryField
    }
    -> Element QueryBuilderMsg
view cfg =
    let
        queryValidation =
            queryValidationState cfg.probeResponse

        queryValidationWithEmptyCheck =
            if String.isEmpty cfg.qText then
                EmptyQuery

            else
                queryValidation

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
                [ width fill ]
                [ status ]
            , viewQueryFields cfg.language cfg.queryFields
            , row
                [ alignBottom
                ]
                [ text "search"
                ]
            ]
        ]


viewQueryFields : Language -> List QueryField -> Element QueryBuilderMsg
viewQueryFields language qFields =
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ alignTop
            , width (px 300)
            , Border.color colourScheme.darkBlue
            , Border.width 1
            , spacing 4
            , padding 6
            ]
            (List.map (\qf -> viewQueryField language qf) qFields)
        ]


viewQueryField : Language -> QueryField -> Element QueryBuilderMsg
viewQueryField language qField =
    row
        [ spacing 8
        , padding 4
        , width fill
        , alignTop
        , onClick (UserClickedOnFieldName qField.alias)
        , pointer
        , Event.mouseOver [ Background.color colourScheme.lightestBlue ]
        ]
        [ el
            []
            (text (extractLabelFromLanguageMap language qField.label))
        ]
