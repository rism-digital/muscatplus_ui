module Page.Keyboard exposing
    ( Model
    , buildNotationRequestQuery
    , defaultKeyboardQuery
    , initModel
    , update
    , view
    )

import Char exposing (isAlpha, isUpper)
import Config
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Element exposing (Element)
import Flip exposing (flip)
import Language exposing (Language)
import Page.Keyboard.Model exposing (Clef(..), KeySignature(..), Keyboard, KeyboardModel, KeyboardQuery, QueryMode(..), TimeSignature(..), setClef, setKeySignature, setKeyboardQuery, setNoteData, setQueryMode, setTimeSignature, toKeyboardQuery)
import Page.Keyboard.Msg exposing (KeyboardMsg(..))
import Page.Keyboard.PAE exposing (createPAENote)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Keyboard.Views as KeyboardViews
import Page.RecordTypes.Search exposing (NotationFacet)
import Request exposing (createSvgRequest, serverUrl)
import Utilities exposing (choose)


type alias Model msg =
    KeyboardModel msg


buildNotationRequestQuery : KeyboardQuery -> Cmd KeyboardMsg
buildNotationRequestQuery keyboardQuery =
    buildNotationQueryParameters keyboardQuery
        |> serverUrl [ "incipits/render" ]
        |> createSvgRequest ServerRespondedWithRenderedNotation


buildUpdateQuery : Maybe String -> KeyboardModel KeyboardMsg -> ( KeyboardModel KeyboardMsg, Cmd KeyboardMsg )
buildUpdateQuery newNoteData model =
    let
        newQuery =
            setNoteData newNoteData model.query

        debounceMsg =
            provideInput DebouncerSettledToSendPAEText
                |> DebouncerCapturedPAEText

        newModel =
            { model
                | query = newQuery
                , needsProbe = needsProbing model
            }

        url =
            buildNotationQueryParameters newQuery
                |> serverUrl [ "incipits/render" ]
    in
    ( newModel
    , Cmd.batch
        [ createSvgRequest ServerRespondedWithRenderedNotation url
        , update debounceMsg newModel |> Tuple.second
        ]
    )


defaultKeyboardQuery : KeyboardQuery
defaultKeyboardQuery =
    { clef = G2
    , timeSignature = TNone
    , keySignature = KS_N
    , noteData = Nothing
    , queryMode = IntervalQueryMode
    }


initModel : Model msg
initModel =
    { query = defaultKeyboardQuery
    , notation = Nothing
    , needsProbe = False
    , inputIsValid = True
    , paeInputSearchDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , paeHelpExpanded = False
    }


filterPitches : String -> String
filterPitches inputString =
    String.filter (\c -> isAlpha c && isUpper c) inputString


needsProbing : KeyboardModel KeyboardMsg -> Bool
needsProbing model =
    -- If the model is already set to needing a probe, then we won't interrupt that process.
    if model.needsProbe then
        False

    else
        -- check if the query is longer than the configured minimum length
        case .noteData model.query of
            Just noteData ->
                choose (String.length (filterPitches noteData) > Config.minimumQueryLength) True False

            Nothing ->
                False


update : KeyboardMsg -> KeyboardModel KeyboardMsg -> ( KeyboardModel KeyboardMsg, Cmd KeyboardMsg )
update msg model =
    case msg of
        ServerRespondedWithRenderedNotation (Ok ( _, response )) ->
            ( { model
                | notation = Just response
                , needsProbe = False
              }
            , Cmd.none
            )

        ServerRespondedWithRenderedNotation (Err _) ->
            ( model, Cmd.none )

        DebouncerCapturedPAEText textMsg ->
            Debouncer.update update updateDebouncerPAESearchConfig textMsg model

        DebouncerSettledToSendPAEText ->
            ( { model
                | needsProbe = needsProbing model
              }
            , Cmd.none
            )

        UserClickedPianoKeyboardKey noteName octave ->
            let
                note =
                    createPAENote noteName octave

                noteData =
                    case .noteData model.query of
                        Just n ->
                            n ++ note

                        Nothing ->
                            note
            in
            buildUpdateQuery (Just noteData) model

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

        UserChangedQueryMode qMode ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setQueryMode qMode
                        |> flip setKeyboardQuery model
            in
            ( { newModel
                | needsProbe = needsProbing newModel
              }
            , Cmd.none
            )

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

        UserClickedPianoKeyboardChangeTimeSignature tsig ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setTimeSignature tsig
                        |> flip setKeyboardQuery model
            in
            ( newModel
            , buildNotationRequestQuery newModel.query
            )

        UserClickedPianoKeyboardChangeKeySignature ksig ->
            let
                newModel =
                    toKeyboardQuery model
                        |> setKeySignature ksig
                        |> flip setKeyboardQuery model
            in
            ( { newModel
                | needsProbe = needsProbing newModel
              }
            , buildNotationRequestQuery newModel.query
            )

        UserToggledPAEHelpText ->
            ( { model
                | paeHelpExpanded = not model.paeHelpExpanded
              }
            , Cmd.none
            )

        NothingHappenedWithTheKeyboard ->
            ( model, Cmd.none )


updateDebouncerPAESearchConfig : Debouncer.UpdateConfig KeyboardMsg (KeyboardModel KeyboardMsg)
updateDebouncerPAESearchConfig =
    { mapMsg = DebouncerCapturedPAEText
    , getDebouncer = .paeInputSearchDebouncer
    , setDebouncer = \debouncer model -> { model | paeInputSearchDebouncer = debouncer }
    }


{-|

    Exposes only the top level view

-}
view : NotationFacet -> Language -> Keyboard KeyboardMsg -> Element KeyboardMsg
view notationFacet lang keyboardConfig =
    KeyboardViews.view notationFacet lang keyboardConfig
