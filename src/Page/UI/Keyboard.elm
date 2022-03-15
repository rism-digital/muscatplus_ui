module Page.UI.Keyboard exposing (..)

import Array
import Config
import Element exposing (Element, alignLeft, alignTop, column, el, fill, height, paddingXY, px, row, text, width)
import Element.Input as Input
import Language exposing (Language)
import List.Extra as LE
import Page.UI.Components exposing (dropdownSelect)
import Page.UI.Helpers exposing (viewMaybe)
import Page.UI.Incipits exposing (viewSVGRenderedIncipit)
import Page.UI.Keyboard.Keyboard exposing (blackKeyWidth, octaveConfig, renderKey, whiteKeyWidthScale)
import Page.UI.Keyboard.Model exposing (Clef(..), Keyboard(..), KeyboardInputMode(..), KeyboardModel, KeyboardQuery, clefStringMap, setNoteData)
import Page.UI.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.UI.Keyboard.PAE exposing (clefStrToClef, createPAENote)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Request exposing (createSvgRequest, serverUrl)


type alias Model =
    KeyboardModel


init : Int -> ( Keyboard, Cmd KeyboardMsg )
init numOctaves =
    let
        -- needs a config and a model instance
        model =
            initModel

        config =
            { numOctaves = numOctaves }
    in
    ( Keyboard model config, Cmd.none )


defaultKeyboardQuery : KeyboardQuery
defaultKeyboardQuery =
    { clef = G2
    , timeSignature = ""
    , keySignature = ""
    , noteData = Nothing
    }


initModel : Model
initModel =
    { query = defaultKeyboardQuery
    , notation = Nothing
    , needsProbe = False
    , inputMode = PianoInput
    }


toNotation : { a | notation : Maybe String } -> Maybe String
toNotation model =
    model.notation


setNotation : Maybe String -> { a | notation : Maybe String } -> { a | notation : Maybe String }
setNotation newNotation oldRecord =
    { oldRecord | notation = newNotation }


toInputMode : { a | inputMode : KeyboardInputMode } -> KeyboardInputMode
toInputMode model =
    model.inputMode


setInputMode : KeyboardInputMode -> { a | inputMode : KeyboardInputMode } -> { a | inputMode : KeyboardInputMode }
setInputMode newMode oldModel =
    { oldModel | inputMode = newMode }


setQuery : KeyboardQuery -> { a | query : KeyboardQuery } -> { a | query : KeyboardQuery }
setQuery newQuery oldModel =
    { oldModel | query = newQuery }


toggleInputMode : KeyboardInputMode -> KeyboardInputMode
toggleInputMode oldMode =
    if oldMode == PianoInput then
        FormInput

    else
        PianoInput


buildUpdateQuery : Maybe (List String) -> Model -> ( Model, Cmd KeyboardMsg )
buildUpdateQuery newNoteData model =
    let
        newQuery =
            setNoteData newNoteData model.query

        url =
            buildNotationQueryParameters newQuery
                |> serverUrl [ "incipits/render" ]
    in
    ( { model | query = newQuery }
    , createSvgRequest ServerRespondedWithRenderedNotation url
    )


buildNotationRequestQuery : KeyboardQuery -> Cmd KeyboardMsg
buildNotationRequestQuery keyboardQuery =
    let
        keyboardQp =
            buildNotationQueryParameters keyboardQuery

        url =
            serverUrl [ "incipits/render" ] keyboardQp
    in
    createSvgRequest ServerRespondedWithRenderedNotation url


update : KeyboardMsg -> KeyboardModel -> ( KeyboardModel, Cmd KeyboardMsg )
update msg model =
    case msg of
        ServerRespondedWithRenderedNotation (Ok ( _, response )) ->
            ( { model
                | notation = Just response
                , needsProbe = False
              }
            , Cmd.none
            )

        ServerRespondedWithRenderedNotation (Err error) ->
            ( model, Cmd.none )

        UserClickedPianoKeyboardKey noteName octave ->
            let
                query =
                    model.query

                note =
                    createPAENote noteName octave

                noteData =
                    case query.noteData of
                        Just n ->
                            Array.fromList n
                                |> Array.push note
                                |> Array.toList

                        Nothing ->
                            [ note ]

                needsProbing =
                    if List.length noteData > Config.minimumQueryLength then
                        True

                    else
                        False

                newModel =
                    { model | needsProbe = needsProbing }
            in
            buildUpdateQuery (Just noteData) newModel

        UserClickedPianoKeyboardDeleteNote ->
            let
                query =
                    model.query

                noteData =
                    Maybe.withDefault [] query.noteData
                        |> LE.init
            in
            buildUpdateQuery noteData model

        ClientRequestedRenderedNotation ->
            let
                noteData =
                    .noteData model.query
            in
            buildUpdateQuery noteData model

        UserToggledInputMode mode ->
            ( { model
                | inputMode = mode
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


view : Language -> Keyboard -> Element KeyboardMsg
view language (Keyboard model config) =
    let
        inputView =
            if model.inputMode == PianoInput then
                viewPianoInput language (Keyboard model config)

            else
                viewFormInput language (Keyboard model config)
    in
    row
        [ alignTop
        , alignLeft
        ]
        [ column
            [ width fill
            , height fill
            ]
            [ row
                [ width fill
                , height fill
                ]
                [ column
                    [ width <| px 120
                    , alignTop
                    ]
                    [ Input.radio
                        []
                        { onChange = \s -> UserToggledInputMode s
                        , options =
                            [ Input.option PianoInput (text "Piano")
                            , Input.option FormInput (text "Form")
                            ]
                        , selected = Just model.inputMode
                        , label = Input.labelAbove [] (text "Choose input")
                        }
                    ]
                , column
                    [ width fill
                    , height fill
                    ]
                    [ inputView ]
                ]
            , row
                [ width fill
                , height (px 120)
                , paddingXY 0 10
                ]
                [ el
                    [ width fill
                    , height (px 120)
                    ]
                    (viewMaybe viewSVGRenderedIncipit model.notation)
                ]
            ]
        ]


viewFormInput : Language -> Keyboard -> Element KeyboardMsg
viewFormInput language (Keyboard model config) =
    let
        clefSelect =
            el
                [ width (px 100) ]
                (dropdownSelect
                    (\clefStr -> UserClickedPianoKeyboardChangeClef <| clefStrToClef clefStr)
                    (List.map (\( s, _ ) -> ( s, s )) clefStringMap)
                    (\selected -> clefStrToClef selected)
                    (.clef model.query)
                )

        paeInput =
            el
                [ width fill ]
                (Input.text
                    [ width fill ]
                    { onChange = UserEnteredPAEText
                    , text = "PAE Input"
                    , placeholder = Nothing
                    , label = Input.labelAbove [] (text "PAE Input")
                    }
                )
    in
    row
        [ width fill
        , height fill
        , alignTop
        ]
        [ column
            [ width fill
            , height fill
            , alignTop
            ]
            [ row
                [ width fill ]
                [ clefSelect ]
            , row
                [ width fill ]
                [ paeInput ]
            ]
        ]


viewPianoInput : Language -> Keyboard -> Element KeyboardMsg
viewPianoInput language (Keyboard model config) =
    let
        numOctaves =
            config.numOctaves

        -- calculate the size of the div for the keyboard
        -- subtract 1 to account for the border overlap
        -- multiply by 7 for each white key
        octaveWidth =
            ((toFloat blackKeyWidth - 1) * whiteKeyWidthScale) * 7

        keyboardWidth =
            (octaveWidth * toFloat numOctaves)
                |> ceiling
    in
    row
        [ width (px keyboardWidth)
        , height fill
        ]
        (List.repeat numOctaves octaveConfig
            |> List.concat
            |> List.indexedMap (renderKey UserClickedPianoKeyboardKey)
        )
