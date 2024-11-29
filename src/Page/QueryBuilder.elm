module Page.QueryBuilder exposing (Model, init, update, view)

import ActiveSearch.Model exposing (ActiveSearch)
import Cmd.Extra as CE
import Element exposing (Element, centerX, centerY, column, fill, height, htmlAttribute, px, row, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, toLanguageMap)
import Page.Query exposing (toKeywordQuery, toMode, toNextQuery)
import Page.QueryBuilder.Model exposing (QueryBuilderModel, queryBuilderOperatorToLabel)
import Page.QueryBuilder.Msg exposing (QueryBuilderMsg(..))
import Page.QueryBuilder.View
import Page.RecordTypes.Probe exposing (ProbeStatus)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Components exposing (viewWindowTitleBar)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))


type alias Model =
    QueryBuilderModel


init : QueryBuilderModel
init =
    {}


update : QueryBuilderMsg -> QueryBuilderModel -> ( QueryBuilderModel, Cmd QueryBuilderMsg )
update msg model =
    case msg of
        UserEnteredTextInQueryBuilder _ ->
            -- no-op here because it's handled in the parent.
            ( model, Cmd.none )

        UserClickedOnFieldName alias qt ->
            let
                newQtext =
                    if String.isEmpty qt then
                        alias ++ ":"

                    else
                        qt ++ " " ++ alias ++ ":"
            in
            ( model, CE.perform (UserEnteredTextInQueryBuilder newQtext) )

        UserClickedOnOperator operator qt ->
            let
                newQtext =
                    if String.isEmpty qt then
                        qt

                    else
                        qt ++ " " ++ queryBuilderOperatorToLabel operator
            in
            ( model, CE.perform (UserEnteredTextInQueryBuilder newQtext) )

        UserClickedSearchButton ->
            -- no-op here because it's handled in the parent.
            ( model, Cmd.none )


view :
    { closeMsg : msg
    , language : Language
    , model :
        { a
            | activeSearch : ActiveSearch msg
            , probeResponse : ProbeStatus
        }
    , searchResponse : Response ServerData
    , userInteractedWithQueryBuilderMsg : QueryBuilderMsg -> msg
    }
    -> Element msg
view cfg =
    let
        nextQuery =
            toNextQuery (.activeSearch cfg.model)

        title =
            toLanguageMap "Query Builder"

        qText =
            toKeywordQuery nextQuery
                |> Maybe.withDefault ""

        currentMode =
            toMode nextQuery

        queryFields =
            case cfg.searchResponse of
                Response (SearchData body) ->
                    body.queryFields

                _ ->
                    []
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
            , Page.QueryBuilder.View.view
                { currentMode = currentMode
                , language = cfg.language
                , probeResponse = .probeResponse cfg.model
                , qText = qText
                , queryFields = queryFields
                }
                |> Element.map cfg.userInteractedWithQueryBuilderMsg
            ]
        ]
