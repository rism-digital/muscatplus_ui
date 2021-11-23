module Page.Front.Views exposing (..)

import Element exposing (Element, alignTop, centerX, column, fill, height, maximum, minimum, none, paddingXY, paragraph, row, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg)
import Page.RecordTypes.Root exposing (RootBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Response exposing (Response(..), ServerData(..))
import Page.UI.Attributes exposing (headingMD)
import Session exposing (Session)


view : Session -> FrontPageModel -> Element FrontMsg
view session model =
    row
        [ width fill
        , height fill
        , centerX
        , paddingXY 20 100
        ]
        [ column
            [ width (fill |> minimum 800 |> maximum 1100)
            , centerX
            , alignTop
            ]
            [ row
                [ width fill ]
                [ ]
            , viewWelcomeMessageRouter session model
            ]
        ]


viewWelcomeMessageRouter : Session -> FrontPageModel -> Element msg
viewWelcomeMessageRouter session model =
    case model.response of
        Response (RootData body) ->
            viewWelcomeMessage session.language body

        _ ->
            none

viewWelcomeMessage : Language -> RootBody -> Element msg
viewWelcomeMessage language body =
    let
        stats =
            body.stats

        searchLabel =
            extractLabelFromLanguageMap language localTranslations.search

        formattedStats =
            List.map (\t -> formatStat t language) stats

        allStats =
            String.join " — " formattedStats
    in
    row
        [ width fill
        , paddingXY 0 20
        ]
        [ paragraph
            [ headingMD ]
            [ text (searchLabel ++ " " ++ allStats) ]
        ]


formatStat : LabelValue -> Language -> String
formatStat stat language =
    let
        statLabel =
            extractLabelFromLanguageMap language stat.label

        statValue =
            extractLabelFromLanguageMap language stat.value

        statValueNumber =
            Maybe.withDefault 0.0 (String.toFloat statValue)

        statValueFormatted =
            formatNumberByLanguage statValueNumber language
    in
    statValueFormatted ++ " " ++ statLabel