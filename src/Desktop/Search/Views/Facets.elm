module Desktop.Search.Views.Facets exposing (facetSearchMsgConfig, viewModeItems)

import Element exposing (Element, alignBottom, alignLeft, centerX, centerY, el, fill, height, padding, paddingXY, px, row, spacing, width)
import Language exposing (Language)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..), ModeFacet)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.UI.Components exposing (Tab(..), tabView)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Images exposing (institutionSvg, musicNotationSvg, peopleSvg, sourcesSvg)
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

        rowMode =
            parseStringToResultMode value

        currentModeIsSelected =
            selectedMode == rowMode

        iconTmpl svg =
            el
                [ width (px 25)
                , height fill
                , padding 4
                , centerX
                , centerY
                ]
                svg

        iconColour =
            if currentModeIsSelected then
                colourScheme.white

            else
                colourScheme.darkBlue

        icon =
            case rowMode of
                SourcesMode ->
                    iconTmpl (sourcesSvg iconColour)

                PeopleMode ->
                    iconTmpl (peopleSvg iconColour)

                InstitutionsMode ->
                    iconTmpl (institutionSvg iconColour)

                IncipitsMode ->
                    iconTmpl (musicNotationSvg iconColour)

        thisTab =
            CountTab label (truncate count |> Just)
    in
    tabView
        { clickMsg = UserClickedModeItem fitem
        , icon = icon
        , isSelected = currentModeIsSelected
        , language = language
        , tab = thisTab
        }


viewModeItems : ResultMode -> Language -> ModeFacet -> Element SearchMsg
viewModeItems selectedMode language typeFacet =
    row
        [ width fill
        , height (px 30)
        , paddingXY 10 0
        , alignLeft
        , alignBottom
        , spacing 10
        ]
        (List.map (viewModeItem selectedMode language) typeFacet.items)
