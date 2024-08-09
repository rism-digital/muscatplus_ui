module Desktop.Search.Views.Facets exposing (facetSearchMsgConfig, viewModeItems)

import Element exposing (Element, alignBottom, alignLeft, centerX, centerY, el, fill, height, htmlAttribute, padding, paddingXY, pointer, px, row, spacing, spacingXY, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Region as Region
import Html.Attributes as HA
import Language exposing (Language, extractLabelFromLanguageMap, formatNumberByLanguage)
import Page.RecordTypes.ResultMode exposing (ResultMode(..), parseStringToResultMode)
import Page.RecordTypes.Search exposing (FacetItem(..), ModeFacet)
import Page.Search.Msg as SearchMsg exposing (SearchMsg(..))
import Page.UI.Attributes exposing (headingXL, minimalDropShadow)
import Page.UI.Facets.FacetsConfig exposing (FacetMsgConfig)
import Page.UI.Images exposing (institutionSvg, liturgicalFestivalSvg, musicNotationSvg, peopleSvg, sourcesSvg)
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

        fullLabel =
            extractLabelFromLanguageMap language label

        iconTmpl svg =
            el
                [ width (px 30)
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

                LiturgicalFestivalsMode ->
                    iconTmpl (liturgicalFestivalSvg iconColour)

        itemCount =
            formatNumberByLanguage language count

        ( backgroundColour, fontColour ) =
            if currentModeIsSelected then
                ( Background.color colourScheme.darkBlue
                , Font.color colourScheme.white
                )

            else
                ( Background.color colourScheme.white
                , Font.color colourScheme.black
                )

        rowStyle =
            [ alignLeft
            , alignBottom
            , Font.center
            , height fill
            , paddingXY 20 5
            , spacingXY 5 0
            , Border.widthEach { bottom = 0, left = 1, right = 1, top = 1 }
            , minimalDropShadow
            , htmlAttribute (HA.style "clip-path" "inset(-5px -5px 0px -5px)")

            --, Border.roundEach { bottomLeft = 0, bottomRight = 0, topLeft = 3, topRight = 3 }
            , onClick (UserClickedModeItem fitem)
            , Border.color colourScheme.darkBlue
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
            [ headingXL
            , Region.heading 3
            , Font.medium
            , centerY
            ]
            (text (fullLabel ++ " (" ++ itemCount ++ ")"))
        ]


viewModeItems : ResultMode -> Language -> ModeFacet -> Element SearchMsg
viewModeItems selectedMode language typeFacet =
    row
        [ centerX
        , width fill
        , height (px 30)
        , paddingXY 20 0
        , spacing 10
        , alignBottom
        ]
        (List.map (viewModeItem selectedMode language) typeFacet.items)
