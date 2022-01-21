module Page.Front.Views.SourceSearch exposing (..)

import Element exposing (Element, alignLeft, alignTop, column, fill, none, paragraph, row, spacing, text, width)
import Element.Font as Font
import Element.Region as Region
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Language.LocalTranslations exposing (localTranslations)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg as FrontMsg exposing (FrontMsg(..))
import Page.Front.Views.Facets exposing (viewFrontFacet)
import Page.Front.Views.SearchControls exposing (viewFrontKeywordQueryInput, viewFrontSearchButtons)
import Page.Query exposing (toKeywordQuery, toNextQuery)
import Page.RecordTypes.Front exposing (FrontBody)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (headingHero, lineSpacing, sectionSpacing)
import Page.UI.Components exposing (dividerWithText)
import Response exposing (Response(..), ServerData(..))
import Session exposing (Session)
import Utlities exposing (namedValue)


sourceSearchPanelView : Session -> FrontPageModel -> FrontBody -> Element FrontMsg
sourceSearchPanelView session model frontBody =
    let
        activeSearch =
            model.activeSearch

        qText =
            toNextQuery activeSearch
                |> toKeywordQuery
                |> Maybe.withDefault ""

        language =
            session.language

        msgs =
            { submitMsg = FrontMsg.UserTriggeredSearchSubmit
            , changeMsg = FrontMsg.UserEnteredTextInKeywordQueryBox
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
                [ paragraph
                    [ headingHero, Font.semiBold ]
                    [ text "Source records" ]
                ]
            , viewFrontKeywordQueryInput language msgs qText
            , viewFrontSearchButtons language model
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
