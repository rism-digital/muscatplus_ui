module Page.Front exposing (..)

import ActiveSearch exposing (setActiveSearch, setActiveSuggestion, toActiveSearch, toKeyboard)
import Browser.Navigation as Nav
import Dict
import Page.Front.Model exposing (FrontPageModel)
import Page.Front.Msg exposing (FrontMsg(..))
import Page.Query exposing (buildQueryParameters, resetPage, setKeywordQuery, setNextQuery, toNextQuery)
import Page.Request exposing (createErrorMessage, createRequestWithDecoder)
import Page.Search.UpdateHelpers exposing (addNationalCollectionFilter, probeSubmit, updateQueryFacetFilters, updateQueryFacetValues, userEnteredTextInQueryFacet, userEnteredTextInRangeFacet, userLostFocusOnRangeFacet, userRemovedItemFromQueryFacet)
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
    , probeResponse = Nothing
    , applyFilterPrompt = False
    }


frontPageRequest : Url -> Cmd FrontMsg
frontPageRequest initialUrl =
    createRequestWithDecoder ServerRespondedWithFrontData (Url.toString initialUrl)


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

        textQueryParameters =
            toNextQuery newModel.activeSearch
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
            ( { model
                | response = Response response
              }
            , Cmd.none
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
                | probeResponse = Just response
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

        UserInputTextInKeywordQueryBox queryText ->
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
            in
            ( newModel, Cmd.none )

        UserRemovedItemFromQueryFacet alias query ->
            userRemovedItemFromQueryFacet alias query model
                |> probeSubmit ServerRespondedWithProbeData session

        UserHitEnterInQueryFacet alias currentBehaviour ->
            updateQueryFacetValues alias currentBehaviour model
                |> probeSubmit ServerRespondedWithProbeData session

        UserEnteredTextInQueryFacet alias query suggestionUrl ->
            userEnteredTextInQueryFacet alias query suggestionUrl ServerRespondedWithSuggestionData model

        UserChoseOptionFromQueryFacetSuggest alias selectedValue currentBehaviour ->
            updateQueryFacetFilters alias selectedValue model
                |> updateQueryFacetValues alias currentBehaviour
                |> probeSubmit ServerRespondedWithProbeData session

        UserEnteredTextInRangeFacet alias inputBox value ->
            ( userEnteredTextInRangeFacet alias inputBox value model
            , Cmd.none
            )

        UserFocusedRangeFacet alias valueType ->
            ( model, Cmd.none )

        UserLostFocusRangeFacet alias valueType ->
            userLostFocusOnRangeFacet alias model
                |> probeSubmit ServerRespondedWithProbeData session

        NothingHappened ->
            ( model, Cmd.none )
