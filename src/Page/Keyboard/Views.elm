module Page.Keyboard.Views exposing (view)

import Element exposing (Element, alignLeft, alignTop, centerX, centerY, column, el, fill, fillPortion, height, paddingXY, row, spacing, width)
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Keyboard.Model exposing (Keyboard(..))
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.Query exposing (queryModeStrToQueryMode)
import Page.Keyboard.Views.FormInput exposing (viewPaeInput, viewRenderControls)
import Page.Keyboard.Views.FullKeyboard exposing (fullKeyboard)
import Page.Keyboard.Views.PaeHelp exposing (viewPaeHelp)
import Page.RecordTypes.Search exposing (NotationFacet)
import Page.UI.Attributes exposing (lineSpacing)
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Record.Incipits exposing (viewSVGRenderedIncipit)


view : NotationFacet -> Language -> Keyboard KeyboardMsg -> Element KeyboardMsg
view notationFacet language (Keyboard model config) =
    let
        queryModeOptions =
            .options notationFacet.queryModes
                |> List.map (\{ label, value } -> ( value, extractLabelFromLanguageMap language label ))
    in
    row
        [ width fill
        , alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , height fill
            , alignLeft
            ]
            [ row
                [ width fill
                , height fill
                , spacing lineSpacing
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
                            [ viewRenderControls language notationFacet (Keyboard model config) ]
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
                            [ fullKeyboard
                                []
                            ]
                        ]
                    , row
                        [ width fill
                        , spacing lineSpacing
                        ]
                        [ viewPaeInput language notationFacet (Keyboard model config)
                        ]
                    , row
                        [ width fill
                        , spacing lineSpacing
                        , alignLeft
                        , paddingXY 0 10
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
                                }
                            ]
                        ]
                    , viewPaeHelp language (Keyboard model config)
                    ]
                ]
            ]
        ]
