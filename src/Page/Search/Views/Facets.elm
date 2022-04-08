module Page.Search.Views.Facets exposing (..)

import Element exposing (Element, alignLeft, centerX, centerY, el, fill, height, paddingXY, px, row, spacing, text, width)
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Page.RecordTypes.ResultMode exposing (ResultMode, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..), ModeFacet)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (headingSM)
import Page.UI.Facets.Facets exposing (FacetMsgConfig)
import Page.UI.Images exposing (institutionSvg, liturgicalFestivalSvg, musicNotationSvg, peopleSvg, sourcesSvg, unknownSvg)
import Page.UI.Style exposing (colourScheme, convertColorToElementColor)


facetSearchMsgConfig : FacetMsgConfig SearchMsg
facetSearchMsgConfig =
    { userClickedToggleMsg = SearchMsg.UserClickedToggleFacet
    , userLostFocusRangeMsg = SearchMsg.UserLostFocusRangeFacet
    , userFocusedRangeMsg = SearchMsg.UserFocusedRangeFacet
    , userEnteredTextRangeMsg = SearchMsg.UserEnteredTextInRangeFacet
    , userClickedFacetExpandSelectMsg = SearchMsg.UserClickedSelectFacetExpand
    , userChangedFacetBehaviourSelectMsg = SearchMsg.UserChangedFacetBehaviour
    , userChangedSelectFacetSortSelectMsg = SearchMsg.UserChangedSelectFacetSort
    , userSelectedFacetItemSelectMsg = SearchMsg.UserClickedSelectFacetItem
    , userInteractedWithPianoKeyboard = SearchMsg.UserInteractedWithPianoKeyboard
    , userRemovedQueryMsg = SearchMsg.UserRemovedItemFromQueryFacet
    , userEnteredTextQueryMsg = SearchMsg.UserEnteredTextInQueryFacet
    , userChangedBehaviourQueryMsg = SearchMsg.UserChangedFacetBehaviour
    , userChoseOptionQueryMsg = SearchMsg.UserChoseOptionForQueryFacet
    }


viewModeItems : ResultMode -> Language -> ModeFacet -> Element SearchMsg
viewModeItems selectedMode language typeFacet =
    let
        rowLabel =
            row
                [ Font.medium
                , height fill
                , centerY
                , headingSM
                ]
                [ text (extractLabelFromLanguageMap language typeFacet.label) ]
    in
    row
        [ centerX
        , width fill
        , height (px 40)
        , paddingXY 20 0
        , spacing 10
        , centerY
        ]
        (rowLabel :: List.map (\t -> viewModeItem selectedMode language t) typeFacet.items)


viewModeItem : ResultMode -> Language -> FacetItem -> Element SearchMsg
viewModeItem selectedMode language fitem =
    let
        -- uses opaque type destructuring to unpack the values of the facet item.
        (FacetItem value label count) =
            fitem

        fullLabel =
            extractLabelFromLanguageMap language label

        iconTmpl svg =
            el
                [ width (px 20)
                , height fill
                , centerX
                , centerY
                ]
                svg

        icon =
            case value of
                "sources" ->
                    iconTmpl <| sourcesSvg colourScheme.slateGrey

                "people" ->
                    iconTmpl <| peopleSvg colourScheme.slateGrey

                "institutions" ->
                    iconTmpl <| institutionSvg colourScheme.slateGrey

                "incipits" ->
                    iconTmpl <| musicNotationSvg colourScheme.slateGrey

                "festivals" ->
                    iconTmpl <| liturgicalFestivalSvg colourScheme.slateGrey

                _ ->
                    iconTmpl <| unknownSvg colourScheme.slateGrey

        rowMode =
            parseStringToResultMode value

        baseRowStyle =
            [ alignLeft
            , Font.center
            , height fill
            , Border.widthEach { top = 0, left = 0, bottom = 2, right = 0 }
            ]

        rowStyle =
            if selectedMode == rowMode then
                Border.color (colourScheme.lightBlue |> convertColorToElementColor) :: baseRowStyle

            else
                Border.color (colourScheme.cream |> convertColorToElementColor) :: baseRowStyle

        itemCount =
            formatNumberByLanguage language count
    in
    row
        rowStyle
        [ el
            [ paddingXY 5 0 ]
            icon
        , el
            []
            (button
                [ alignLeft
                , spacing 10
                ]
                { onPress = Just <| UserClickedModeItem fitem
                , label =
                    el
                        [ headingSM
                        , alignLeft
                        ]
                        (text <| fullLabel ++ " (" ++ itemCount ++ ")")
                }
            )
        ]
