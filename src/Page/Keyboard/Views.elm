module Page.Keyboard.Views exposing (..)

import Element
    exposing
        ( Element
        , alignLeft
        , alignTop
        , centerX
        , column
        , el
        , fill
        , fillPortion
        , height
        , paddingXY
        , px
        , row
        , spacing
        , width
        )
import Language exposing (Language, extractLabelFromLanguageMap)
import Page.Keyboard.Model exposing (Keyboard(..))
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (queryModeStrToQueryMode)
import Page.Keyboard.Views.FormInput exposing (viewPaeInput, viewRenderControls)
import Page.Keyboard.Views.PianoInput exposing (viewPianoInput)
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
                        [ width fill ]
                        [ column
                            [ centerX
                            ]
                            [ viewPianoInput language (Keyboard model config) ]
                        ]
                    , row
                        [ width fill
                        , spacing lineSpacing
                        ]
                        [ column
                            [ width <| fillPortion 3 ]
                            [ viewPaeInput language notationFacet (Keyboard model config) ]
                        , column
                            [ width <| fillPortion 1 ]
                            [ row
                                [ width fill
                                , width (px 200)
                                ]
                                [ dropdownSelect
                                    { selectedMsg = \s -> UserChangedQueryMode <| queryModeStrToQueryMode s
                                    , mouseUpMsg = Nothing
                                    , mouseDownMsg = Nothing
                                    , choices = queryModeOptions
                                    , choiceFn = \selected -> queryModeStrToQueryMode selected
                                    , currentChoice = .queryMode model.query
                                    , selectIdent = "keyboard-query-mode-select"
                                    , label = Just <| .label notationFacet.queryModes
                                    , language = language
                                    }
                                ]
                            ]
                        ]
                    ]
                ]
            , row
                [ width fill
                , paddingXY 0 10
                ]
                [ el
                    [ width fill
                    ]
                    (viewMaybe viewSVGRenderedIncipit model.notation)
                ]
            , viewRenderControls language notationFacet (Keyboard model config)
            ]
        ]
