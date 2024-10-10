module Page.Keyboard.Views exposing (view)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, fillPortion, height, paddingXY, pointer, px, row, spacing, width)
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
import Page.UI.Helpers exposing (viewMaybe, viewSVGRenderedIncipit)
import Page.UI.Images exposing (audioMutedSvg, audioUnmutedSvg)
import Page.UI.Style exposing (colourScheme)
import SearchPreferences exposing (SearchPreferences)


view : Maybe SearchPreferences -> NotationFacet -> Language -> KeyboardModel KeyboardMsg -> Element KeyboardMsg
view searchPreferences notationFacet language model =
    let
        isMuted =
            ME.unwrap True (\prefs -> prefs.audioMuted) searchPreferences

        queryModeOptions =
            .options notationFacet.queryModes
                |> List.map (\{ label, value } -> ( value, extractLabelFromLanguageMap language label ))
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
                , paddingXY 0 10
                ]
                [ column
                    [ width (fillPortion 1)
                    , centerY
                    ]
                    [ viewRenderControls language notationFacet model ]
                , column
                    [ width (fillPortion 4)
                    , centerY
                    ]
                    [ el
                        [ width fill
                        ]
                        (viewMaybe viewSVGRenderedIncipit model.notation)
                    ]
                ]
            , row
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
            , row
                [ width fill
                , spacing lineSpacing
                ]
                [ viewPaeInput language model
                ]
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
            , viewPaeHelp language model
            ]
        ]
