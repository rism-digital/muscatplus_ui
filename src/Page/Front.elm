module Page.Front exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setKeyboard, setRangeFacetValues, toActiveSearch, toKeyboard)
import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer exposing (debounce, fromSeconds, provideInput, toDebouncer)
import Dict
import Flip exposing (flip)
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg(..))
import Page.Keyboard as Keyboard exposing (buildNotationRequestQuery)
import Page.Keyboard.Model exposing (toKeyboardQuery)
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (buildQueryParameters, defaultQueryArgs, resetPage, setKeywordQuery, setMode, setNextQuery, toMode, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.Request exposing (createErrorMessage, createProbeRequestWithDecoder, createRequestWithDecoder)
import Page.Search.UpdateHelpers exposing (addNationalCollectionFilter, createProbeUrl, probeSubmit, updateQueryFacetFilters, userChangedFacetBehaviour, userChangedSelectFacetSort, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Page.SideBar.Msg exposing (SideBarOption(..), sideBarOptionToResultMode)
import Request exposing (serverUrl)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)


type alias Model =
    FrontPageModel FrontMsg


type alias Msg =
    FrontMsg


init : FrontPageModel FrontMsg
init =
    { response = Loading Nothing
    , activeSearch = ActiveSearch.empty
    , probeResponse = NoResponseToShow
    , probeDebouncer = debounce (fromSeconds 0.5) |> toDebouncer
    , applyFilterPrompt = False
    }


setProbeResponse : Response ProbeData -> { a | probeResponse : Response ProbeData } -> { a | probeResponse : Response ProbeData }
setProbeResponse newResponse oldModel =
    { oldModel | probeResponse = newResponse }


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

        notationQueryParameters =
            toActiveSearch pageResetModel
                |> toKeyboard
                |> toKeyboardQuery
                |> buildNotationQueryParameters

        newModel =
            addNationalCollectionFilter session.restrictedToNationalCollection pageResetModel

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


updateDebouncerConfig : Debouncer.UpdateConfig FrontMsg (FrontPageModel FrontMsg)
updateDebouncerConfig =
    { mapMsg = DebouncerCapturedProbeRequest
    , getDebouncer = .probeDebouncer
    , setDebouncer = \debouncer model -> { model | probeDebouncer = debouncer }
    }


update : Session -> FrontMsg -> FrontPageModel FrontMsg -> ( FrontPageModel FrontMsg, Cmd FrontMsg )
update session msg model =
    case msg of
        ServerRespondedWithFrontData (Ok ( _, response )) ->
            let
                keyboardQuery =
                    toKeyboard model.activeSearch
                        |> toKeyboardQuery

                notationRenderCmd =
                    case session.showFrontSearchInterface of
                        IncipitSearchOption ->
                            Cmd.map UserInteractedWithPianoKeyboard (buildNotationRequestQuery keyboardQuery)

                        _ ->
                            Cmd.none
            in
            ( { model
                | response = Response response
              }
            , notationRenderCmd
            )

        ServerRespondedWithFrontData (Err err) ->
            ( { model
                | response = Error (createErrorMessage err)
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

        DebouncerCapturedProbeRequest frontMsg ->
            Debouncer.update (update session) updateDebouncerConfig frontMsg model

        DebouncerSettledToSendProbeRequest ->
            probeSubmit ServerRespondedWithProbeData session model

        ServerRespondedWithSuggestionData (Err err) ->
            ( model, Cmd.none )

        ServerRespondedWithProbeData (Ok ( _, response )) ->
            ( { model
                | probeResponse = Response response
                , applyFilterPrompt = True
              }
            , Cmd.none
            )

        ServerRespondedWithProbeData (Err err) ->
            ( { model
                | probeResponse = Error (createErrorMessage err)
              }
            , Cmd.none
            )

        UserChangedFacetBehaviour alias facetBehaviour ->
            userChangedFacetBehaviour alias facetBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

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
            in
            setNextQuery adjustedQueryArgs model.activeSearch
                |> setRangeFacetValues Dict.empty
                |> setKeyboard Keyboard.initModel
                |> flip setActiveSearch model
                |> frontProbeSubmit session

        UserEnteredTextInKeywordQueryBox queryText ->
            let
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

                debounceMsg =
                    provideInput DebouncerSettledToSendProbeRequest
                        |> DebouncerCapturedProbeRequest
            in
            update session debounceMsg newModel

        UserClickedToggleFacet facetAlias ->
            userClickedToggleFacet facetAlias model
                |> frontProbeSubmit session

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromQueryFacet alias query model
                |> frontProbeSubmit session

        UserEnteredTextInQueryFacet alias query suggestionUrl ->
            userEnteredTextInQueryFacet alias query suggestionUrl ServerRespondedWithSuggestionData model

        UserChoseOptionFromQueryFacetSuggest alias selectedValue currentBehaviour ->
            updateQueryFacetFilters alias selectedValue currentBehaviour model
                |> frontProbeSubmit session

        UserEnteredTextInRangeFacet alias inputBox value ->
            ( userEnteredTextInRangeFacet alias inputBox value model
            , Cmd.none
            )

        UserFocusedRangeFacet alias valueType ->
            ( model, Cmd.none )

        UserLostFocusRangeFacet alias valueType ->
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

        UserClickedSelectFacetItem alias facetValue isClicked ->
            userClickedSelectFacetItem alias facetValue model
                |> frontProbeSubmit session

        UserInteractedWithPianoKeyboard keyboardMsg ->
            let
                ( keyboardModel, keyboardCmd ) =
                    toKeyboard model.activeSearch
                        |> Keyboard.update keyboardMsg

                resultMode =
                    sideBarOptionToResultMode session.showFrontSearchInterface

                newModel =
                    setKeyboard keyboardModel model.activeSearch
                        |> flip setActiveSearch model

                probeCmd =
                    if keyboardModel.needsProbe then
                        let
                            probeUrl =
                                toNextQuery newModel.activeSearch
                                    |> setMode resultMode
                                    |> flip setNextQuery newModel.activeSearch
                                    |> createProbeUrl
                        in
                        createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl

                    else
                        Cmd.none
            in
            ( newModel
            , Cmd.batch
                [ Cmd.map UserInteractedWithPianoKeyboard keyboardCmd
                , probeCmd
                ]
            )

        NothingHappened ->
            ( model, Cmd.none )
