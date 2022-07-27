module Page.Front exposing
    ( FrontConfig
    , Model
    , Msg
    , frontPageRequest
    , frontProbeSubmit
    , init
    , update
    )

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setActiveSuggestionDebouncer, setKeyboard, setRangeFacetValues, toActiveSearch, toKeyboard)
import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Flip exposing (flip)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg(..))
import Page.Keyboard as Keyboard exposing (buildNotationRequestQuery)
import Page.Keyboard.Model exposing (toKeyboardQuery)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (FrontQueryArgs, buildQueryParameters, defaultQueryArgs, frontQueryArgsToQueryArgs, resetPage, setKeywordQuery, setMode, setNextQuery, toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.Request exposing (createProbeRequestWithDecoder, createRequestWithDecoder)
import Page.SideBar.Msg exposing (SideBarOption(..), sideBarOptionToResultMode)
import Page.UpdateHelpers exposing (addNationalCollectionFilter, createProbeUrl, probeSubmit, textQuerySuggestionSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedSelectFacetSort, userClickedFacetPanelToggle, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userFocusedRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Request exposing (serverUrl)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)


type alias FrontConfig =
    { queryArgs : FrontQueryArgs
    }


type alias Model =
    FrontPageModel FrontMsg


type alias Msg =
    FrontMsg


frontPageRequest : Url -> Cmd FrontMsg
frontPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithFrontData (Url.toString initialUrl)


frontProbeSubmit : Session -> FrontPageModel FrontMsg -> ( FrontPageModel FrontMsg, Cmd FrontMsg )
frontProbeSubmit session model =
    let
        resultMode =
            sideBarOptionToResultMode session.showFrontSearchInterface

        newModel =
            toNextQuery model.activeSearch
                |> setMode resultMode
                |> flip setNextQuery model.activeSearch
                |> flip setActiveSearch model
                |> setProbeResponse (Loading Nothing)
    in
    probeSubmit ServerRespondedWithProbeData session newModel


init : FrontConfig -> FrontPageModel FrontMsg
init cfg =
    let
        convertedQueryArgs =
            frontQueryArgsToQueryArgs cfg.queryArgs
    in
    { response = Loading Nothing
    , activeSearch =
        ActiveSearch.init
            { queryArgs = convertedQueryArgs
            , keyboardQueryArgs = Just Keyboard.defaultKeyboardQuery
            }
    , probeResponse = NoResponseToShow
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , applyFilterPrompt = False
    }


searchSubmit : Session -> FrontPageModel FrontMsg -> ( FrontPageModel FrontMsg, Cmd FrontMsg )
searchSubmit session model =
    let
        activeSearch =
            toActiveSearch model

        resetPageInQueryArgs =
            activeSearch
                |> toNextQuery
                |> resetPage

        -- when submitting a new search, reset the page
        -- to the first page.
        pageResetModel =
            activeSearch
                |> setNextQuery resetPageInQueryArgs
                |> flip setActiveSearch model

        newModel =
            addNationalCollectionFilter session.restrictedToNationalCollection pageResetModel

        notationQueryParameters =
            case toKeyboard pageResetModel.activeSearch of
                Just kq ->
                    toKeyboardQuery kq
                        |> buildNotationQueryParameters

                Nothing ->
                    []

        resultMode =
            sideBarOptionToResultMode session.showFrontSearchInterface

        textQueryParameters =
            toNextQuery newModel.activeSearch
                |> setMode resultMode
                |> buildQueryParameters

        searchUrl =
            serverUrl [ "search" ] (List.append textQueryParameters notationQueryParameters)
    in
    ( newModel
    , Nav.pushUrl session.key searchUrl
    )


setProbeResponse : Response ProbeData -> { a | probeResponse : Response ProbeData } -> { a | probeResponse : Response ProbeData }
setProbeResponse newResponse oldModel =
    { oldModel | probeResponse = newResponse }


update : Session -> FrontMsg -> FrontPageModel FrontMsg -> ( FrontPageModel FrontMsg, Cmd FrontMsg )
update session msg model =
    case msg of
        ServerRespondedWithFrontData (Ok ( _, response )) ->
            let
                notationRenderCmd =
                    case session.showFrontSearchInterface of
                        IncipitSearchOption ->
                            case toKeyboard model.activeSearch of
                                Just kq ->
                                    Cmd.map UserInteractedWithPianoKeyboard (buildNotationRequestQuery (toKeyboardQuery kq))

                                Nothing ->
                                    Cmd.none

                        _ ->
                            Cmd.none

                newModel =
                    { model
                        | response = Response response
                        , probeResponse = Loading Nothing
                    }

                probeUrl =
                    createProbeUrl session newModel.activeSearch
            in
            ( newModel
            , Cmd.batch
                [ notationRenderCmd
                , createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl
                ]
            )

        ServerRespondedWithFrontData (Err err) ->
            ( { model
                | response = Error err
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Ok ( _, response )) ->
            let
                keyboardModel =
                    .keyboard model.activeSearch

                newKeyboardModel =
                    case keyboardModel of
                        Just km ->
                            Just { km | needsProbe = False }

                        Nothing ->
                            Nothing

                newActiveSearch =
                    setKeyboard newKeyboardModel model.activeSearch
            in
            ( { model
                | probeResponse = Response response
                , activeSearch = newActiveSearch
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Err err) ->
            ( { model
                | probeResponse = Error err
              }
            , Cmd.none
            )

        ServerRespondedWithSuggestionData (Ok ( _, response )) ->
            let
                newModel =
                    setActiveSuggestion (Just response) model.activeSearch
                        |> flip setActiveSearch model
            in
            ( newModel
            , Cmd.none
            )

        ServerRespondedWithSuggestionData (Err _) ->
            ( model, Cmd.none )

        DebouncerCapturedProbeRequest frontMsg ->
            Debouncer.update (update session) updateDebouncerProbeConfig frontMsg model

        DebouncerSettledToSendProbeRequest ->
            probeSubmit ServerRespondedWithProbeData session model

        DebouncerCapturedQueryFacetSuggestionRequest incomingMsg ->
            Debouncer.update (update session) updateDebouncerSuggestConfig incomingMsg model

        DebouncerSettledToSendQueryFacetSuggestionRequest suggestionUrl ->
            ( model
            , textQuerySuggestionSubmit suggestionUrl ServerRespondedWithSuggestionData
            )

        UserClickedFacetPanelToggle panelAlias expandedPanels ->
            userClickedFacetPanelToggle panelAlias expandedPanels model

        UserEnteredTextInKeywordQueryBox queryText ->
            let
                debounceMsg =
                    provideInput DebouncerSettledToSendProbeRequest
                        |> DebouncerCapturedProbeRequest

                newText =
                    if String.isEmpty queryText then
                        Nothing

                    else
                        Just queryText

                newQueryArgs =
                    toNextQuery model.activeSearch
                        |> setKeywordQuery newText

                newModel =
                    setNextQuery newQueryArgs model.activeSearch
                        |> flip setActiveSearch model
            in
            update session debounceMsg newModel

        UserClickedToggleFacet facetAlias ->
            userClickedToggleFacet facetAlias model
                |> frontProbeSubmit session

        UserChangedFacetBehaviour alias facetBehaviour ->
            userChangedFacetBehaviour alias facetBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromQueryFacet alias query model
                |> frontProbeSubmit session

        UserEnteredTextInQueryFacet alias query suggestionUrl ->
            let
                debounceMsg =
                    String.append suggestionUrl query
                        |> DebouncerSettledToSendQueryFacetSuggestionRequest
                        |> provideInput
                        |> DebouncerCapturedQueryFacetSuggestionRequest

                newModel =
                    userEnteredTextInQueryFacet alias query model
            in
            update session debounceMsg newModel

        UserChoseOptionFromQueryFacetSuggest alias selectedValue currentBehaviour ->
            updateQueryFacetFilters alias selectedValue currentBehaviour model
                |> frontProbeSubmit session

        UserEnteredTextInRangeFacet alias inputBox value ->
            ( userEnteredTextInRangeFacet alias inputBox value model
            , Cmd.none
            )

        UserFocusedRangeFacet alias ->
            userFocusedRangeFacet alias model

        UserLostFocusRangeFacet alias ->
            userLostFocusOnRangeFacet alias model
                |> frontProbeSubmit session

        UserChangedSelectFacetSort alias facetSort ->
            ( userChangedSelectFacetSort alias facetSort model
            , Cmd.none
            )

        UserClickedSelectFacetExpand alias ->
            ( userClickedSelectFacetExpand alias model
            , Cmd.none
            )

        UserClickedSelectFacetItem alias facetValue ->
            userClickedSelectFacetItem alias facetValue model
                |> frontProbeSubmit session

        UserInteractedWithPianoKeyboard keyboardMsg ->
            case toKeyboard model.activeSearch of
                Just oldKeyboardModel ->
                    let
                        ( keyboardModel, keyboardCmd ) =
                            Keyboard.update keyboardMsg oldKeyboardModel

                        newModel =
                            setKeyboard (Just keyboardModel) model.activeSearch
                                |> flip setActiveSearch model

                        probeModel =
                            if keyboardModel.needsProbe then
                                { newModel
                                    | probeResponse = Loading Nothing
                                }

                            else
                                newModel

                        probeCmd =
                            if keyboardModel.needsProbe then
                                let
                                    resultMode =
                                        sideBarOptionToResultMode session.showFrontSearchInterface

                                    probeUrl =
                                        toNextQuery probeModel.activeSearch
                                            |> setMode resultMode
                                            |> flip setNextQuery probeModel.activeSearch
                                            |> createProbeUrl session
                                in
                                createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl

                            else
                                Cmd.none
                    in
                    ( probeModel
                    , Cmd.batch
                        [ Cmd.map UserInteractedWithPianoKeyboard keyboardCmd
                        , probeCmd
                        ]
                    )

                Nothing ->
                    ( model, Cmd.none )

        UserTriggeredSearchSubmit ->
            searchSubmit session model

        UserResetAllFilters ->
            let
                -- we don't reset *all* parameters; we keep the
                -- currently selected result mode so that the user
                -- doesn't get bounced back to the 'sources' tab.
                currentMode =
                    toNextQuery model.activeSearch
                        |> toMode

                adjustedQueryArgs =
                    { defaultQueryArgs | mode = currentMode }

                ( newModel, cmds ) =
                    setNextQuery adjustedQueryArgs model.activeSearch
                        |> setRangeFacetValues Dict.empty
                        |> setKeyboard (Just Keyboard.initModel)
                        |> flip setActiveSearch model
                        |> frontProbeSubmit session

                notationRenderCmd =
                    case session.showFrontSearchInterface of
                        IncipitSearchOption ->
                            case toKeyboard newModel.activeSearch of
                                Just kq ->
                                    Cmd.map UserInteractedWithPianoKeyboard (buildNotationRequestQuery (toKeyboardQuery kq))

                                Nothing ->
                                    Cmd.none

                        _ ->
                            Cmd.none
            in
            ( newModel
            , Cmd.batch
                [ cmds
                , notationRenderCmd
                ]
            )

        NothingHappened ->
            ( model, Cmd.none )


updateDebouncerProbeConfig : Debouncer.UpdateConfig FrontMsg (FrontPageModel FrontMsg)
updateDebouncerProbeConfig =
    { mapMsg = DebouncerCapturedProbeRequest
    , getDebouncer = .probeDebouncer
    , setDebouncer = \debouncer model -> { model | probeDebouncer = debouncer }
    }


updateDebouncerSuggestConfig : Debouncer.UpdateConfig FrontMsg (FrontPageModel FrontMsg)
updateDebouncerSuggestConfig =
    { mapMsg = DebouncerCapturedQueryFacetSuggestionRequest
    , getDebouncer = \model -> .activeSuggestionDebouncer model.activeSearch
    , setDebouncer =
        \debouncer model ->
            model.activeSearch
                |> setActiveSuggestionDebouncer debouncer
                |> flip setActiveSearch model
    }
