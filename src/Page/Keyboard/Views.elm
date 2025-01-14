module Page.Keyboard.Views exposing (view)

import Element exposing (Element, alignLeft, alignTop, centerX, column, el, fill, height, minimum, paddingXY, pointer, px, row, spacing, width, wrappedRow)
import Element.Events exposing (onClick)
import Language exposing (Language, extractLabelFromLanguageMap)
import Maybe.Extra as ME
import Page.Keyboard.Model exposing (KeyboardModel)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.Query exposing (queryModeStrToQueryMode)
import Page.Keyboard.Views.FormInput exposing (viewPaeInput, viewRenderControls)
import Page.Keyboard.Views.FullKeyboard exposing (fullKeyboard)
import Page.Keyboard.Views.PaeHelp exposing (viewPaeHelp)
import Page.RecordTypes.Search exposing (NotationFacet)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewIf, viewMaybe, viewSVGRenderedIncipit)
import Page.UI.Images exposing (audioMutedSvg, audioUnmutedSvg)
import Page.UI.Style exposing (colourScheme)
import SearchPreferences exposing (SearchPreferences)


view :
    { language : Language
    , model : KeyboardModel KeyboardMsg
    , notationFacet : NotationFacet
    , searchPreferences : Maybe SearchPreferences
    , suppressInMobileUi : Bool
    }
    -> Element KeyboardMsg
view { language, model, notationFacet, searchPreferences, suppressInMobileUi } =
    let
        queryModeOptions =
            .options notationFacet.queryModes
                |> List.map (\{ label, value } -> ( value, extractLabelFromLanguageMap language label ))

        isMuted =
            ME.unwrap True .audioMuted searchPreferences

        keyboardControl =
            viewIf
                (row
                    [ width fill
                    , paddingXY 0 20
                    ]
                    [ column
                        [ centerX ]
                        [ row
                            [ width fill ]
                            [ fullKeyboard isMuted []
                            ]
                        , row
                            [ width fill
                            , height (px 20)
                            , paddingXY 0 10
                            ]
                            [ el
                                [ width (px 18)
                                , height (px 18)
                                , alignLeft
                                , onClick (UserToggledAudioMuted (not isMuted))
                                , pointer
                                ]
                                (if isMuted then
                                    audioMutedSvg colourScheme.red

                                 else
                                    audioUnmutedSvg colourScheme.lightBlue
                                )
                            ]
                        ]
                    ]
                )
                (not suppressInMobileUi)

        renderControls =
            viewIf
                (row
                    [ width fill
                    , spacing 10
                    ]
                    (viewRenderControls language notationFacet model)
                )
                (not suppressInMobileUi)

        paeHelp =
            viewIf (viewPaeHelp language model) (not suppressInMobileUi)
    in
    row
        [ width fill
        , height fill
        , spacing lineSpacing
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , height fill
            , spacing lineSpacing
            ]
            [ row
                [ width fill
                ]
                [ column
                    [ alignTop
                    , centerX
                    ]
                    [ el
                        [ width (fill |> minimum 300) ]
                        (viewMaybe viewSVGRenderedIncipit model.notation)
                    ]
                ]
            , renderControls
            , keyboardControl
            , viewPaeInput language model
            , row
                [ width fill
                , spacing lineSpacing
                , alignLeft
                ]
                [ column
                    [ width fill
                    , alignLeft
                    ]
                    [ dropdownSelect
                        { selectedMsg = \s -> UserChangedQueryMode (queryModeStrToQueryMode s)
                        , mouseDownMsg = Nothing
                        , mouseUpMsg = Nothing
                        , choices = queryModeOptions
                        , choiceFn = \selected -> queryModeStrToQueryMode selected
                        , currentChoice = .queryMode model.query
                        , selectIdent = "keyboard-query-mode-select"
                        , label = Just (.label notationFacet.queryModes)
                        , language = language
                        , inverted = False
                        }
                    ]
                ]
            , paeHelp
            ]
        ]
