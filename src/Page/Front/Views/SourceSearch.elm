module Page.Front.Views.SourceSearch exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, fill, none, paragraph, row, spacing, text, width)
import Element.Font as Font
import Element.Region as Region
import Language exposing (extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg(..))
import Page.Front.Views.FrontKeywordQuery exposing (frontKeywordQueryInput)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.UI.Attributes exposing (headingHero, headingXXL, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (h1)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Utlities exposing (namedValue)


sourceSearchPanelView : Session -> FrontPageModel -> Element FrontMsg
sourceSearchPanelView session model =
    let
        qText =
            toNextQuery model.activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

        language =
            session.language

        msgs =
            { submitMsg = FrontMsg.UserTriggeredSearchSubmit
            , changeMsg = FrontMsg.UserInputTextInKeywordQueryBox
            }

        header =
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
                    paragraph [ headingHero, Region.heading 1, Font.semiBold ] [ text interpolatedValue ]

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
                        [ header ]
                    ]
                ]
            , frontKeywordQueryInput language msgs qText
            ]
        ]
