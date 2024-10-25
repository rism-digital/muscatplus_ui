module Page.QueryBuilder exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Element exposing (Element, centerX, centerY, column, fill, height, htmlAttribute, px, row, width)
import Element.Background as Background
import Element.Border as Border
import Html.Attributes as HA
import Language exposing (Language, toLanguageMap)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.QueryBuilder.Model exposing (QueryBuilderModel)
import Page.QueryBuilder.Msg exposing (QueryBuilderMsg)
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
    ( model, Cmd.none )


view :
    { language : Language
    , model :
        { a
            | activeSearch : ActiveSearch msg
            , probeResponse : ProbeStatus
        }
    , searchResponse : Response ServerData
    , closeMsg : msg
    , userInteractedWithQueryBuilderMsg : QueryBuilderMsg -> msg
    }
    -> Element msg
view cfg =
    let
        title =
            toLanguageMap "Query Builder"

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
                , qText = qText
                , probeResponse = .probeResponse cfg.model
                , queryFields = queryFields
                }
                |> Element.map cfg.userInteractedWithQueryBuilderMsg
            ]
        ]
