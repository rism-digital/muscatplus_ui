module Page.Front.Views.SourceSearch exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, alignLeft, alignTop, column, fill, none, paragraph, row, spacing, text, width)
import Element.Font as Font
import Element.Region as Region
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg(..))
import Page.Front.Views.FrontKeywordQuery exposing (frontKeywordQueryInput)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Search exposing (FacetData(..), Facets)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.Search.Views.Facets.QueryFacet exposing (QueryFacetConfig, viewQueryFacet)
import Page.Search.Views.Facets.RangeFacet exposing (RangeFacetConfig, viewRangeFacet)
import Page.UI.Attributes exposing (headingHero, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Utlities exposing (namedValue)


viewFrontFacet : FacetAlias -> Language -> ActiveSearch -> { a | facets : Facets } -> Element FrontMsg
viewFrontFacet alias language activeSearch body =
    case Dict.get alias body.facets of
        Just (QueryFacetData facet) ->
            let
                queryFacetConfig : QueryFacetConfig FrontMsg
                queryFacetConfig =
                    { language = language
                    , queryFacet = facet
                    , activeSearch = activeSearch
                    , userRemovedMsg = FrontMsg.UserRemovedItemFromQueryFacet
                    , userHitEnterMsg = FrontMsg.UserHitEnterInQueryFacet
                    , userEnteredTextMsg = FrontMsg.UserEnteredTextInQueryFacet
                    , userChangedBehaviourMsg = FrontMsg.UserChangedFacetBehaviour
                    , userChoseOptionMsg = FrontMsg.UserChoseOptionFromQueryFacetSuggest
                    }
            in
            viewQueryFacet queryFacetConfig

        Just (RangeFacetData facet) ->
            let
                rangeFacetConfig : RangeFacetConfig FrontMsg
                rangeFacetConfig =
                    { language = language
                    , rangeFacet = facet
                    , activeSearch = activeSearch
                    , userLostFocusMsg = FrontMsg.UserLostFocusRangeFacet
                    , userFocusedMsg = FrontMsg.UserFocusedRangeFacet
                    , userEnteredTextMsg = FrontMsg.UserEnteredTextInRangeFacet
                    }
            in
            viewRangeFacet rangeFacetConfig

        _ ->
            none


sourceSearchPanelView : Session -> FrontPageModel -> Element FrontMsg
sourceSearchPanelView session model =
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
            case model.response of
                Response (FrontData body) ->
                    let
                        sourceStats =
                            .sources body.stats

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

                _ ->
                    none
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
                [ width fill ]
                -- TODO: Translate
                [ dividerWithText "Additional filters"
                ]
            , row
                [ width fill ]
                [ column
                    [ width fill ]
                    [ viewFrontFacet "composer" language activeSearch model ]
                ]
            ]
        ]
