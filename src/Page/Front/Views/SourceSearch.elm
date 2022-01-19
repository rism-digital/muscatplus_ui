module Page.Front.Views.SourceSearch exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, alignLeft, alignTop, centerY, column, el, fill, fillPortion, height, none, paddingXY, paragraph, px, row, shrink, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Element.Region as Region
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg(..))
import Page.Front.Views.Facets exposing (viewFrontFacet)
import Page.Front.Views.FrontKeywordQuery exposing (frontKeywordQueryInput)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.RecordTypes.Search exposing (FacetData(..), Facets)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Search.Views.Facets.QueryFacet exposing (QueryFacetConfig, viewQueryFacet)
import Page.Search.Views.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)
import Page.UI.Attributes exposing (headingHero, headingSM, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Utlities exposing (namedValue)


sourceSearchPanelRouter : Session -> FrontPageModel -> Element FrontMsg
sourceSearchPanelRouter session model =
    case model.response of
        Response (FrontData body) ->
            sourceSearchPanelView session body model

        _ ->
            none


sourceSearchPanelView : Session -> FrontBody -> FrontPageModel -> Element FrontMsg
sourceSearchPanelView session frontBody model =
    let
        qText =
            toNextQuery model.activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

        activeSearch =
            model.activeSearch

        language =
            session.language

        msgs =
            { submitMsg = FrontMsg.UserTriggeredSearchSubmit
            , changeMsg = FrontMsg.UserInputTextInKeywordQueryBox
            }

        statsHeader =
            let
                sourceStats =
                    .sources frontBody.stats

                sourceNumbers =
                    sourceStats.value

                formattedNumber =
                    formatNumberByLanguage language sourceNumbers

                translatedRecordType =
                    extractLabelFromLanguageMap language sourceStats.label

                interpolatedValue =
                    extractLabelFromLanguageMap language localTranslations.searchNumberOfRecords
                        |> namedValue "numberOfRecords" formattedNumber
                        |> namedValue "recordType" translatedRecordType
            in
            paragraph
                [ headingHero, Region.heading 1, Font.semiBold ]
                [ text interpolatedValue ]
    in
    row
        [ width fill
        , alignTop
        ]
        [ column
            [ width fill
            , alignTop
            , spacing sectionSpacing
            ]
            [ row
                [ width fill
                , alignTop
                , spacing lineSpacing
                ]
                [ column
                    [ width fill
                    , alignLeft
                    , alignTop
                    ]
                    [ row
                        [ spacing 10 ]
                        [ statsHeader ]
                    ]
                ]
            , frontKeywordQueryInput language msgs qText
            , row
                [ width fill
                , height <| px 60
                ]
                [ column
                    []
                    [ Input.button
                        [ Border.color (colourScheme.darkBlue |> convertColorToElementColor)
                        , Background.color (colourScheme.darkBlue |> convertColorToElementColor)
                        , paddingXY 10 10
                        , height (px 60)
                        , width <| px 120
                        , Font.center
                        , Font.color (colourScheme.white |> convertColorToElementColor)
                        , headingSM
                        ]
                        { onPress = Just msgs.submitMsg
                        , label = text (extractLabelFromLanguageMap language localTranslations.search)
                        }
                    ]
                ]
            , row
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "composer" language activeSearch frontBody ]
                , column
                    [ width fill ]
                    [ viewFrontFacet "people" language activeSearch frontBody ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "date-range" language activeSearch frontBody ]
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "source-type" language activeSearch frontBody
                    , viewFrontFacet "content-types" language activeSearch frontBody
                    , viewFrontFacet "material-group-types" language activeSearch frontBody
                    ]
                ]
            ]
        ]
