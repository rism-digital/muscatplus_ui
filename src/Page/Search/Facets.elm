module Page.Search.Facets exposing (facetSearchMsgConfig, viewModeItems)

import Element exposing (Element, alignBottom, alignLeft, centerX, centerY, el, fill, height, none, paddingXY, px, row, spacing, width)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..), ModeFacet)
import Page.RecordTypes.SearchControl exposing (SearchControlOptions(..), resultModeToSearchControlOption)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.UI.Components exposing (Tab(..), tabView)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Images exposing (institutionSvg, musicNotationSvg, peopleSvg, sourcesSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


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
    , userSelectedFacetItemSingleChoiceMsg = SearchMsg.UserClickedSingleChoiceFacetItem
    , userResetSingleChoiceMsg = SearchMsg.UsersClickedSingleChoiceReset
    , userInteractedWithPianoKeyboard = SearchMsg.UserInteractedWithPianoKeyboard
    , userRemovedQueryMsg = SearchMsg.UserRemovedItemFromQueryFacet
    , userEnteredTextQueryMsg = SearchMsg.UserEnteredTextInQueryFacet
    , userChangedBehaviourQueryMsg = SearchMsg.UserChangedFacetBehaviour
    , userChoseOptionQueryMsg = SearchMsg.UserChoseOptionForQueryFacet
    , nothingHappenedMsg = SearchMsg.NothingHappened
    }


viewModeItem : ResultMode -> Session -> FacetItem -> Element SearchMsg
viewModeItem selectedMode session fitem =
    let
        -- uses opaque type destructuring to unpack the values of the facet item.
        (FacetItem value label count) =
            fitem

        rowMode =
            parseStringToResultMode value

        adjustedMode =
            case selectedMode of
                EmptyMode ->
                    SourcesMode

                _ ->
                    selectedMode

        currentModeIsSelected =
            adjustedMode == rowMode

        searchInterface =
            resultModeToSearchControlOption rowMode

        iconTmpl svg =
            el
                [ height (px 15)
                , width (px 15)
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
            case searchInterface of
                SourceSearchOption ->
                    iconTmpl (sourcesSvg iconColour)

                PeopleSearchOption ->
                    iconTmpl (peopleSvg iconColour)

                InstitutionSearchOption ->
                    iconTmpl (institutionSvg iconColour)

                IncipitSearchOption ->
                    iconTmpl (musicNotationSvg iconColour)

                _ ->
                    none

        thisTab =
            CountTab label (truncate count |> Just)
    in
    tabView
        { clickMsg = UserClickedModeItem fitem
        , icon = icon
        , isSelected = currentModeIsSelected
        , language = session.language
        , tab = thisTab
        }


viewModeItems : ResultMode -> Session -> ModeFacet -> Element SearchMsg
viewModeItems selectedMode session typeFacet =
    row
        [ width fill
        , height (px 30)
        , paddingXY 10 0
        , alignLeft
        , alignBottom
        , spacing 10
        ]
        (List.map (viewModeItem selectedMode session) typeFacet.items)
