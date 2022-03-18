module Page.Keyboard exposing (..)

import Array
import Config
import Element exposing (Element)
import Flip exposing (flip)
import Language exposing (Language)
import List.Extra as LE
import Page.Keyboard.Model exposing (Clef(..), Keyboard(..), KeyboardModel, KeyboardQuery, QueryMode(..), setClef, setKeyboardQuery, setNoteData, setQueryMode, toKeyboardQuery)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (createPAENote)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Keyboard.Views as KeyboardViews
import Page.RecordTypes.Incipit exposing (incipitValidationBodyDecoder)
import Page.RecordTypes.Search exposing (NotationFacet)
import Request exposing (createRequest, createSvgRequest, serverUrl)
import Utlities exposing (choose)


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
    , queryMode = IntervalQueryMode
    }


initModel : Model
initModel =
    { query = defaultKeyboardQuery
    , notation = Nothing
    , needsProbe = False
    , inputIsValid = True
    }


toNotation : { a | notation : Maybe String } -> Maybe String
toNotation model =
    model.notation


setNotation : Maybe String -> { a | notation : Maybe String } -> { a | notation : Maybe String }
setNotation newNotation oldRecord =
    { oldRecord | notation = newNotation }


setQuery : KeyboardQuery -> { a | query : KeyboardQuery } -> { a | query : KeyboardQuery }
setQuery newQuery oldModel =
    { oldModel | query = newQuery }


buildUpdateQuery : Maybe String -> Model -> ( Model, Cmd KeyboardMsg )
buildUpdateQuery newNoteData model =
    let
        newQuery =
            setNoteData newNoteData model.query

        url =
            buildNotationQueryParameters newQuery
                |> serverUrl [ "incipits/render" ]
    in
    ( { model
        | query = newQuery
      }
    , createSvgRequest ServerRespondedWithRenderedNotation url
    )


buildNotationRequestQuery : KeyboardQuery -> Cmd KeyboardMsg
buildNotationRequestQuery keyboardQuery =
    buildNotationQueryParameters keyboardQuery
        |> serverUrl [ "incipits/render" ]
        |> createSvgRequest ServerRespondedWithRenderedNotation


buildNotationValidationQuery : KeyboardQuery -> Cmd KeyboardMsg
buildNotationValidationQuery keyboardQuery =
    buildNotationQueryParameters keyboardQuery
        |> serverUrl [ "incipits/render" ]
        |> createRequest ServerRespondedWithNotationValidation incipitValidationBodyDecoder


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

        ServerRespondedWithNotationValidation (Ok ( _, response )) ->
            ( { model
                | inputIsValid = response.isValid
              }
            , Cmd.none
            )

        ServerRespondedWithNotationValidation (Err error) ->
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
                            n ++ note

                        Nothing ->
                            note

                needsProbing =
                    choose (String.length noteData > Config.minimumQueryLength) True False

                newModel =
                    { model | needsProbe = needsProbing }
            in
            buildUpdateQuery (Just noteData) newModel

        ClientRequestedRenderedNotation ->
            let
                noteData =
                    .noteData model.query
            in
            buildUpdateQuery noteData model

        UserInteractedWithPAEText text ->
            let
                -- Drop any characters that exceed the 1024 limit.
                checkedLengthText =
                    if String.length text > 1024 then
                        String.left 1024 text

                    else
                        text

                -- Ensure that any pitches letters that are entered are upper-cased
                -- skips "b" since that can also be a flat!
                newText =
                    String.map
                        (\c ->
                            if List.member c [ 'a', 'c', 'd', 'e', 'f', 'g' ] then
                                Char.toUpper c

                            else
                                c
                        )
                        checkedLengthText
            in
            buildUpdateQuery (Just newText) model

        UserRequestedProbeUpdate ->
            ( { model | needsProbe = True }, Cmd.none )

        UserClickedPianoKeyboardChangeClef clef ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setClef clef
                        |> flip setKeyboardQuery model
            in
            ( newModel
            , buildNotationRequestQuery newModel.query
            )

        UserChangedQueryMode qMode ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setQueryMode qMode
                        |> flip setKeyboardQuery model
            in
            ( { newModel | needsProbe = True }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


{-|

    Exposes only the top level view

-}
view : NotationFacet -> Language -> Keyboard -> Element KeyboardMsg
view notationFacet lang keyboardConfig =
    KeyboardViews.view notationFacet lang keyboardConfig
