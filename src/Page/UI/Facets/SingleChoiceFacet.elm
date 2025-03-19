module Page.UI.Facets.SingleChoiceFacet exposing (..)

import ActiveSearch.Model exposing (ActiveSearch)
import Dict
import Element exposing (Element, Option, alignLeft, alignRight, alignTop, column, el, fill, none, pointer, row, spacing, text, width)
import Element.Events exposing (onClick)
import Element.Input as Input exposing (option)
import Language exposing (Language, LanguageMap, extractLabelFromLanguageMap, formatNumberByLanguage, toLanguageMap)
import Page.RecordTypes.Search exposing (FacetItem(..), SingleChoiceFacet, labelForValue)
import Page.RecordTypes.Shared exposing (FacetAlias)
import Page.UI.Attributes exposing (linkColour)
import Page.UI.Facets.Shared exposing (facetTitleBar)
import Url exposing (percentDecode)


type alias SingleChoiceFacetConfig msg =
    { language : Language
    , activeSearch : ActiveSearch msg
    , singleChoiceFacet : SingleChoiceFacet
    , userSelectedSingleChoiceMsg : FacetAlias -> String -> LanguageMap -> msg
    , userResetSingleChoiceMsg : FacetAlias -> msg
    }


viewSingleChoiceFacet : SingleChoiceFacetConfig msg -> Element msg
viewSingleChoiceFacet cfg =
    let
        clearOptionsLink =
            el
                [ linkColour
                , alignRight
                , pointer
                , onClick (cfg.userResetSingleChoiceMsg (.alias cfg.singleChoiceFacet))
                ]
                (text "Reset selection")

        titleBar =
            facetTitleBar
                { extraControls =
                    [ clearOptionsLink ]
                , language = cfg.language
                , title = .label cfg.singleChoiceFacet
                , tooltip = toLanguageMap "No tooltip yet."
                }

        nextQuery =
            .nextQuery cfg.activeSearch

        chosenOption =
            Dict.get (.alias cfg.singleChoiceFacet) nextQuery.filters
                |> Maybe.withDefault []
                |> List.map (\( val, _ ) -> percentDecode val |> Maybe.withDefault val)
                |> List.head

        changeMsg opt =
            let
                label =
                    labelForValue opt (.items cfg.singleChoiceFacet)
            in
            cfg.userSelectedSingleChoiceMsg (.alias cfg.singleChoiceFacet) opt label
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , alignTop
            , spacing 8
            ]
            [ titleBar
            , row
                [ width fill
                , spacing 8
                ]
                [ Input.radio
                    [ spacing 8
                    , width fill
                    ]
                    { label = Input.labelHidden (extractLabelFromLanguageMap cfg.language (.label cfg.singleChoiceFacet))
                    , onChange = changeMsg
                    , selected = chosenOption
                    , options =
                        .items cfg.singleChoiceFacet
                            |> viewOptions cfg.language
                    }
                ]
            ]
        ]


viewOptions : Language -> List FacetItem -> List (Input.Option String msg)
viewOptions language optionList =
    List.map
        (\(FacetItem value label count) ->
            let
                optionLabel =
                    extractLabelFromLanguageMap language label

                formattedCount =
                    formatNumberByLanguage language count
            in
            Input.option value (text (optionLabel ++ " (" ++ formattedCount ++ ")"))
        )
        optionList
