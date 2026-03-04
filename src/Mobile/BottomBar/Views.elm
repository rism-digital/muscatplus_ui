module Mobile.BottomBar.Views exposing (view)

import Element exposing (Element, alignBottom, centerX, centerY, column, el, fill, fillPortion, height, htmlAttribute, px, row, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Language exposing (extractLabelFromLanguageMap)
import Language.LocalTranslations exposing (localTranslations)
import Page.BottomBar.Msg exposing (BottomBarMsg(..))
import Page.RecordTypes.ResultMode exposing (ResultMode(..))
import Page.UI.Images exposing (folderMusicSvg, institutionSvg, musicNotationSvg, peopleSvg, sourcesSvg)
import Page.UI.Style exposing (colourScheme)
import Session exposing (Session)


view : Session -> Element BottomBarMsg
view session =
    row
        [ width fill
        , htmlAttribute (HA.style "height" "8vh")
        , Background.color colourScheme.darkBlue
        , Border.widthEach { bottom = 0, left = 0, right = 0, top = 1 }
        , Border.color colourScheme.darkGrey
        , alignBottom
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ centerX
                , centerY
                , width fill
                ]
                [ viewBottomBarOption
                    { clickMsg = UserTouchedBottomBarOptionForFrontPage SourcesMode
                    , icon = sourcesSvg colourScheme.white
                    , label = "Sources"
                    }
                , viewBottomBarOption
                    { clickMsg = UserTouchedBottomBarOptionForFrontPage InstitutionsMode
                    , icon = institutionSvg colourScheme.white
                    , label = "Institutions"
                    }
                , viewBottomBarOption
                    { clickMsg = UserTouchedBottomBarOptionForFrontPage PeopleMode
                    , icon = peopleSvg colourScheme.white
                    , label = "People"
                    }
                , viewBottomBarOption
                    { clickMsg = UserTouchedBottomBarOptionForFrontPage IncipitsMode
                    , icon = musicNotationSvg colourScheme.white
                    , label = "Incipits"
                    }
                , viewBottomBarOption
                    { clickMsg = UserTouchedBottomBarOptionForFrontPage WorkCatalogueMode
                    , icon = folderMusicSvg colourScheme.white
                    , label = extractLabelFromLanguageMap session.language localTranslations.workCatalogues
                    }
                ]
            ]
        ]


viewBottomBarOption :
    { clickMsg : BottomBarMsg
    , icon : Element BottomBarMsg
    , label : String
    }
    -> Element BottomBarMsg
viewBottomBarOption cfg =
    column
        [ width (fillPortion 1)
        , height fill
        , centerY
        , centerX
        , onClick cfg.clickMsg
        ]
        [ el
            [ width (px 24)
            , height (px 24)
            , centerY
            , centerX
            ]
            cfg.icon
        , el
            [ Font.color colourScheme.white
            , Font.size 11
            , Font.center
            , width fill
            , htmlAttribute (HA.style "overflow" "hidden")
            , htmlAttribute (HA.style "text-overflow" "ellipsis")
            , htmlAttribute (HA.style "white-space" "nowrap")
            ]
            (text cfg.label)
        ]
