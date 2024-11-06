module Page.QueryBuilder exposing (Model, init, update, view)

import ActiveSearch.Model exposing (ActiveSearch)
import Browser.Dom
import Cmd.Extra as CE
import Element exposing (Element, centerX, centerY, column, fill, height, htmlAttribute, px, row, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, LanguageMap, toLanguageMap)
import Page.Query exposing (toKeywordQuery, toMode, toNextQuery)
import Page.QueryBuilder.Model exposing (QueryBuilderModel, queryBuilderOperatorToLabel)
import Page.QueryBuilder.Msg exposing (QueryBuilderMsg(..))
import Page.QueryBuilder.View
import Page.RecordTypes.Probe exposing (ProbeStatus)
import Page.UI.Attributes exposing (minimalDropShadow)
import Page.UI.Components exposing (viewWindowTitleBar)
import Page.UI.Style exposing (colourScheme)
import Response exposing (Response(..), ServerData(..))
import Task


type alias Model =
    QueryBuilderModel


init : QueryBuilderModel
init =
    {}


update : QueryBuilderMsg -> QueryBuilderModel -> ( QueryBuilderModel, Cmd QueryBuilderMsg )
update msg model =
    case msg of
        UserClickedOnFieldName alias qt ->
            let
                newQtext =
                    if String.isEmpty qt then
                        alias ++ ":"

                    else
                        qt ++ " " ++ alias ++ ":"
            in
            ( model, CE.perform (UserEnteredTextInQueryBuilder newQtext) )

        UserEnteredTextInQueryBuilder qt ->
            -- no-op here because it's handled in the parent.
            ( model, Cmd.none )

        UserClickedOnOperator operator qt ->
            let
                newQtext =
                    if String.isEmpty qt then
                        qt

                    else
                        qt ++ " " ++ queryBuilderOperatorToLabel operator
            in
            ( model, CE.perform (UserEnteredTextInQueryBuilder newQtext) )


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
        title =
            toLanguageMap "Query Builder"

        nextQuery =
            toNextQuery (.activeSearch cfg.model)

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
                { language = cfg.language
                , probeResponse = .probeResponse cfg.model
                , qText = qText
                , queryFields = queryFields
                , currentMode = currentMode
                }
                |> Element.map cfg.userInteractedWithQueryBuilderMsg
            ]
        ]
