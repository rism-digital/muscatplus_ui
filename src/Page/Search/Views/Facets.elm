module Page.Search.Views.Facets exposing (facetSearchMsgConfig, viewModeItems)

import Element exposing (Element, alignBottom, alignLeft, centerX, centerY, el, fill, height, none, paddingXY, pointer, px, row, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Page.RecordTypes.ResultMode exposing (ResultMode, parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..), ModeFacet)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (headingLG)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Images exposing (institutionSvg, liturgicalFestivalSvg, musicNotationSvg, peopleSvg, sourcesSvg, unknownSvg)
import Page.UI.Style exposing (colourScheme)


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
    , nothingHappenedMsg = SearchMsg.NothingHappened
    }


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
                "festivals" ->
                    iconTmpl (liturgicalFestivalSvg colourScheme.slateGrey)

                "incipits" ->
                    iconTmpl (musicNotationSvg colourScheme.slateGrey)

                "institutions" ->
                    iconTmpl (institutionSvg colourScheme.slateGrey)

                "people" ->
                    iconTmpl (peopleSvg colourScheme.slateGrey)

                "sources" ->
                    iconTmpl (sourcesSvg colourScheme.slateGrey)

                _ ->
                    iconTmpl (unknownSvg colourScheme.slateGrey)

        itemCount =
            formatNumberByLanguage language count

        rowMode =
            parseStringToResultMode value

        selectedTab =
            ( Border.color colourScheme.darkBlue
            , Background.color colourScheme.darkBlue
            , Font.color colourScheme.white
            )

        unselectedTab =
            ( Border.color colourScheme.midGrey
            , Background.color colourScheme.white
            , Font.color colourScheme.black
            )

        ( borderColour, backgroundColour, fontColour ) =
            if selectedMode == rowMode then
                selectedTab

            else
                unselectedTab

        rowStyle =
            [ alignLeft
            , alignBottom
            , Font.center
            , height fill
            , paddingXY 20 5
            , spacingXY 5 0
            , Border.widthEach { bottom = 0, left = 2, right = 2, top = 2 }
            , Border.roundEach { topLeft = 5, topRight = 5, bottomLeft = 0, bottomRight = 0 }
            , onClick (UserClickedModeItem fitem)
            , borderColour
            , backgroundColour
            , fontColour
            , pointer
            ]
    in
    row
        rowStyle
        [ el
            [ paddingXY 5 0 ]
            icon
        , el
            [ alignLeft
            , spacing 10
            , headingLG
            ]
            (text (fullLabel ++ " (" ++ itemCount ++ ")"))
        ]


viewModeItems : ResultMode -> Language -> ModeFacet -> Element SearchMsg
viewModeItems selectedMode language typeFacet =
    let
        rowLabel =
            none

        --row
        --    [ Font.medium
        --    , height fill
        --    , centerY
        --    , headingLG
        --    ]
        --    [ text (extractLabelFromLanguageMap language typeFacet.label) ]
    in
    row
        [ centerX
        , width fill
        , height (px 40)
        , paddingXY 20 0
        , spacing 10
        , alignBottom
        ]
        (List.map (\t -> viewModeItem selectedMode language t) typeFacet.items)
