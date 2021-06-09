module Page.Views.FrontPage exposing (..)

import Element exposing (Element, alignTop, centerX, column, fill, height, maximum, minimum, none, paddingXY, paragraph, row, text, width)
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage, localTranslations)
import Model exposing (Model)
import Msg exposing (Msg)
import Page.Model exposing (Response(..))
import Page.RecordTypes.Root exposing (RootBody)
import Page.RecordTypes.Shared exposing (LabelValue)
import Page.Response exposing (ServerData(..))
import Page.UI.Attributes exposing (headingMD)
import Page.UI.Components exposing (searchKeywordInput)


view : Model -> Element Msg
view model =
    let
        msgs =
            { submitMsg = Msg.SearchSubmit
            , changeMsg = Msg.SearchInput
            }

        activeSearch =
            model.activeSearch

        activeQuery =
            activeSearch.query

        qtext =
            Maybe.withDefault "" activeQuery.query
    in
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
                [ searchKeywordInput msgs qtext model.language ]
            , viewWelcomeMessageRouter model
            ]
        ]


viewWelcomeMessageRouter : Model -> Element Msg
viewWelcomeMessageRouter model =
    let
        page =
            model.page

        welcomeView =
            case page.response of
                Response (RootData body) ->
                    viewWelcomeMessage model.language body

                _ ->
                    none
    in
    welcomeView


viewWelcomeMessage : Language -> RootBody -> Element Msg
viewWelcomeMessage language body =
    let
        stats =
            body.stats

        searchLabel =
            extractLabelFromLanguageMap language localTranslations.search

        formattedStats =
            List.map (\t -> formatStat t language) stats

        allStats =
            String.join ", " formattedStats
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
