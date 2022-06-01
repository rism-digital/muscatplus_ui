module Update exposing (..)

import Browser
import Browser.Navigation as Nav
import Device exposing (setDevice)
import Flip exposing (flip)
import Model exposing (Model(..), toSession, updateSession)
import Msg exposing (Msg)
import Page.About as AboutPage
import Page.Front as FrontPage
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.NotFound as NotFoundPage
import Page.Query exposing (buildQueryParameters, toNextQuery)
import Page.Record as RecordPage
import Page.Route as Route exposing (parseUrl, setRoute, setUrl)
import Page.Search as SearchPage
import Page.SideBar as SideBar
import Url exposing (Url)
import Url.Builder exposing (toQuery)


changePage : Url -> Model -> ( Model, Cmd Msg )
changePage url model =
    let
        route =
            parseUrl url

        newSession =
            toSession model
                |> setRoute route
                |> setUrl url
    in
    case route of
        Route.FrontPageRoute qargs ->
            let
                initialModel =
                    FrontPage.init
                        { queryArgs = qargs }
            in
            ( FrontPage newSession initialModel
            , Cmd.map Msg.UserInteractedWithFrontPage (FrontPage.frontPageRequest url)
            )

        Route.NotFoundPageRoute ->
            ( NotFoundPage newSession NotFoundPage.init
            , Cmd.none
            )

        Route.SearchPageRoute qargs kqargs ->
            let
                -- set the old data on the Loading response
                -- so that the view keeps the old appearance until
                -- the new data is loaded. In the case where we're
                -- coming from another page, or the response doesn't
                -- already contain server data we instead initialize
                -- a default search page model.
                searchCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = qargs
                    , keyboardQueryArgs = kqargs
                    }

                newModel =
                    case model of
                        SearchPage _ oldPageModel ->
                            SearchPage.load searchCfg oldPageModel

                        _ ->
                            SearchPage.init searchCfg

                newQparams =
                    toNextQuery newModel.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                newKeyboardParams =
                    buildNotationQueryParameters kqargs
                        |> toQuery
                        |> String.dropLeft 1

                fullQueryParams =
                    newQparams ++ "&" ++ newKeyboardParams

                searchUrl =
                    { url | query = Just fullQueryParams }
            in
            ( SearchPage newSession newModel
            , Cmd.batch
                [ SearchPage.searchPageRequest searchUrl
                , SearchPage.requestPreviewIfSelected newModel.selectedResult
                ]
                |> Cmd.map Msg.UserInteractedWithSearchPage
            )

        Route.SourcePageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                sourceModel =
                    RecordPage.init recordCfg
            in
            ( SourcePage newSession sourceModel
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        Route.PersonPageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                newModel =
                    case model of
                        PersonPage _ oldModel ->
                            RecordPage.load recordCfg oldModel

                        _ ->
                            RecordPage.init recordCfg

                sourceQuery =
                    toNextQuery newModel.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                sourcesUrl =
                    { url | path = url.path ++ "/sources", query = Just sourceQuery }
            in
            ( PersonPage newSession newModel
            , Cmd.batch
                [ RecordPage.recordPageRequest url
                , RecordPage.recordSearchRequest sourcesUrl
                ]
                |> Cmd.map Msg.UserInteractedWithRecordPage
            )

        Route.PersonSourcePageRoute _ qargs ->
            let
                recordPath =
                    String.replace "/sources" "" url.path

                recordUrl =
                    { url | path = recordPath }

                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                newModel =
                    case model of
                        PersonPage _ oldModel ->
                            RecordPage.load recordCfg oldModel

                        _ ->
                            RecordPage.init recordCfg

                newQparams =
                    toNextQuery newModel.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                sourceUrl =
                    { url | query = Just newQparams }
            in
            ( PersonPage newSession newModel
            , Cmd.batch
                [ RecordPage.recordPageRequest recordUrl
                , RecordPage.recordSearchRequest sourceUrl
                , RecordPage.requestPreviewIfSelected newModel.selectedResult
                ]
                |> Cmd.map Msg.UserInteractedWithRecordPage
            )

        Route.InstitutionPageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                newModel =
                    case model of
                        InstitutionPage _ oldModel ->
                            RecordPage.load recordCfg oldModel

                        _ ->
                            RecordPage.init recordCfg

                sourceQuery =
                    toNextQuery newModel.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                sourcesUrl =
                    { url | path = url.path ++ "/sources", query = Just sourceQuery }
            in
            ( InstitutionPage newSession newModel
            , Cmd.batch
                [ RecordPage.recordPageRequest url
                , RecordPage.recordSearchRequest sourcesUrl
                ]
                |> Cmd.map Msg.UserInteractedWithRecordPage
            )

        Route.InstitutionSourcePageRoute _ qargs ->
            let
                recordPath =
                    String.replace "/sources" "" url.path

                recordUrl =
                    { url | path = recordPath }

                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                newModel =
                    case model of
                        InstitutionPage _ oldModel ->
                            RecordPage.load recordCfg oldModel

                        _ ->
                            RecordPage.init recordCfg

                newQparams =
                    toNextQuery newModel.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                sourceUrl =
                    { url | query = Just newQparams }
            in
            ( InstitutionPage newSession newModel
            , Cmd.batch
                [ RecordPage.recordPageRequest recordUrl
                , RecordPage.recordSearchRequest sourceUrl
                , RecordPage.requestPreviewIfSelected newModel.selectedResult
                ]
                |> Cmd.map Msg.UserInteractedWithRecordPage
            )

        Route.PlacePageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                placeModel =
                    RecordPage.init recordCfg
            in
            ( PlacePage newSession placeModel
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        Route.AboutPageRoute ->
            ( AboutPage newSession AboutPage.init
            , Cmd.map Msg.UserInteractedWithAboutPage (AboutPage.initialCmd url)
            )

        _ ->
            ( NotFoundPage newSession NotFoundPage.init, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg _ ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Msg.ClientChangedUrl url, _ ) ->
            changePage url model

        ( Msg.UserRequestedUrlChange urlRequest, _ ) ->
            let
                session =
                    toSession model
            in
            case urlRequest of
                Browser.Internal url ->
                    -- if the app is loading the viewer, treat it as an external link.
                    if url.path == "/viewer.html" then
                        ( model, Nav.load <| Url.toString url )

                    else
                        ( model, Nav.pushUrl session.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( Msg.UserResizedWindow device, _ ) ->
            let
                newModel =
                    toSession model
                        |> setDevice device
                        |> flip updateSession model
            in
            ( newModel, Cmd.none )

        ( Msg.UserInteractedWithSideBar sideBarMsg, _ ) ->
            let
                ( newSession, sidebarCmd ) =
                    toSession model
                        |> SideBar.update sideBarMsg

                newModel =
                    updateSession newSession model
            in
            ( newModel
            , Cmd.map Msg.UserInteractedWithSideBar sidebarCmd
            )

        ( Msg.UserInteractedWithFrontPage frontMsg, FrontPage session pageModel ) ->
            FrontPage.update session frontMsg pageModel
                |> updateWith (FrontPage session) Msg.UserInteractedWithFrontPage model

        ( Msg.UserInteractedWithSearchPage searchMsg, SearchPage session pageModel ) ->
            SearchPage.update session searchMsg pageModel
                |> updateWith (SearchPage session) Msg.UserInteractedWithSearchPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, SourcePage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (SourcePage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, PersonPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (PersonPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, InstitutionPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (InstitutionPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, PlacePage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (PlacePage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithAboutPage recordMsg, AboutPage session pageModel ) ->
            AboutPage.update session recordMsg pageModel
                |> updateWith (AboutPage session) Msg.UserInteractedWithAboutPage model

        ( Msg.UserInteractedWithNotFoundPage notFoundMsg, NotFoundPage session pageModel ) ->
            NotFoundPage.update session notFoundMsg pageModel
                |> updateWith (NotFoundPage session) Msg.UserInteractedWithNotFoundPage model

        ( Msg.NothingHappened, _ ) ->
            ( model, Cmd.none )

        ( Msg.ClientReceivedABadPortMessage _, _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
