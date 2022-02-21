module Page.Front exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, setKeyboard, toActiveSearch, toKeyboard)
import Browser.Navigation as Nav
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg(..))
import Page.Query exposing (buildQueryParameters, resetPage, setKeywordQuery, setMode, setNextQuery, toNextQuery)
import Page.RecordTypes.Probe exposing (ProbeData)
import Page.Request exposing (createErrorMessage, createProbeRequestWithDecoder, createRequestWithDecoder)
import Page.Search.UpdateHelpers exposing (addNationalCollectionFilter, createProbeUrl, probeSubmit, updateQueryFacetFilters, updateQueryFacetValues, userChangedSelectFacetSort, userClickedSelectFacetExpand, userClickedSelectFacetItem, userClickedToggleFacet, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
import Page.SideBar.Msg exposing (SideBarOption(..), sideBarOptionToResultMode)
import Page.UI.Keyboard as Keyboard exposing (buildNotationRequestQuery)
import Page.UI.Keyboard.Model exposing (toKeyboardQuery)
import Page.UI.Keyboard.Query exposing (buildNotationQueryParameters)
import Request exposing (serverUrl)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)
import Utlities exposing (flip)


type alias Model =
    FrontPageModel


type alias Msg =
    FrontMsg


init : FrontPageModel
init =
    { response = Loading Nothing
    , activeSearch = ActiveSearch.empty
    , probeResponse = NoResponseToShow
    , applyFilterPrompt = False
    }


setProbeResponse : Response ProbeData -> { a | probeResponse : Response ProbeData } -> { a | probeResponse : Response ProbeData }
setProbeResponse newResponse oldModel =
    { oldModel | probeResponse = newResponse }


frontPageRequest : Url -> Cmd FrontMsg
frontPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithFrontData (Url.toString initialUrl)


frontProbeSubmit : Session -> FrontPageModel -> ( FrontPageModel, Cmd FrontMsg )
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


searchSubmit : Session -> FrontPageModel -> ( FrontPageModel, Cmd FrontMsg )
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
    , Cmd.batch
        [ Nav.pushUrl session.key searchUrl
        ]
    )


update : Session -> FrontMsg -> FrontPageModel -> ( FrontPageModel, Cmd FrontMsg )
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
            ( model, Cmd.none )

        UserChangedFacetBehaviour alias behaviour ->
            ( model, Cmd.none )

        UserTriggeredSearchSubmit ->
            searchSubmit session model

        UserResetAllFilters ->
            ( model, Cmd.none )

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
            in
            setNextQuery newQueryArgs model.activeSearch
                |> flip setActiveSearch model
                |> frontProbeSubmit session

        UserClickedToggleFacet facetAlias ->
            userClickedToggleFacet facetAlias model
                |> frontProbeSubmit session

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromQueryFacet alias query model
                |> frontProbeSubmit session

        UserHitEnterInQueryFacet alias currentBehaviour ->
            updateQueryFacetValues alias currentBehaviour model
                |> frontProbeSubmit session

        UserEnteredTextInQueryFacet alias query suggestionUrl ->
            userEnteredTextInQueryFacet alias query suggestionUrl ServerRespondedWithSuggestionData model

        UserChoseOptionFromQueryFacetSuggest alias selectedValue currentBehaviour ->
            updateQueryFacetFilters alias selectedValue model
                |> updateQueryFacetValues alias currentBehaviour
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
                    if keyboardModel.needsProbe == True then
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
