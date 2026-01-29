module Update exposing (update)

import Basics.Extra as BE
import Browser
import Browser.Navigation as Nav
import Device exposing (isMobileView, setDevice, setWindow)
import Maybe.Extra as ME
import Model exposing (Model(..), toSession, updateSession)
import Msg exposing (Msg)
import Page.About as AboutPage
import Page.BottomBar as BottomBar
import Page.BottomBar.Options as BottomBarOptions
import Page.Error as NotFoundPage
import Page.Front as FrontPage
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.NavigationBar exposing (NavigationBar(..), setNavigationBar)
import Page.Query exposing (QueryArgs, buildQueryParameters, toNextQuery)
import Page.Record as RecordPage
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Route as Route exposing (Route, baseRecordPathFromRoute, isMEIDownloadRoute, isPNGDownloadRoute, parseUrl, setRoute, setUrl)
import Page.Search as SearchPage
import Page.SideBar as SideBar
import Page.SideBar.Options as SideBarOptions
import Page.UpdateHelpers exposing (joinQueryParams)
import Request exposing (serverUrl)
import Response exposing (Response(..))
import Session exposing (Session)
import Url exposing (Url)
import Url.Builder exposing (toQuery)


changePage : Url -> Model -> ( Model, Cmd Msg )
changePage url model =
    let
        previousUrl =
            toSession model
                |> .url

        previousRoute =
            toSession model
                |> .route

        newSession =
            toSession model
                |> setRoute route
                |> setUrl url

        route =
            parseUrl url
    in
    case route of
        Route.FrontPageRoute qargs ->
            let
                initialPageBody =
                    FrontPage.init
                        { queryArgs = qargs
                        , initialData = Nothing
                        , session = newSession
                        }
            in
            ( FrontPage newSession initialPageBody
            , FrontPage.frontPageRequest url
                |> Cmd.map Msg.UserInteractedWithFrontPage
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
                    , searchPreferences = newSession.searchPreferences
                    , session = newSession
                    }

                newPageBody =
                    case model of
                        SearchPage _ oldPageBody ->
                            SearchPage.load searchCfg oldPageBody

                        _ ->
                            SearchPage.init searchCfg

                updatedSession =
                    if ME.isNothing qargs.nationalCollection then
                        { newSession | restrictedToNationalCollection = Nothing }

                    else
                        newSession

                -- optimization. If the actual query has not changed, then
                -- we do not need to trigger a new search request. This happens
                -- primarily when choosing a preview, where the fragment will change
                -- indicating the selected preview, but the actual search query will
                -- not change.
                queryHasChanged =
                    Maybe.map2 (/=) previousUrl.query url.query
                        |> Maybe.withDefault True

                isLoading =
                    case model of
                        SearchPage _ pageBody ->
                            case pageBody.response of
                                Loading r ->
                                    ME.isJust r

                                _ ->
                                    False

                        _ ->
                            False

                searchCmd =
                    if queryHasChanged || isLoading then
                        let
                            newKeyboardParams =
                                buildNotationQueryParameters kqargs
                                    |> toQuery
                                    |> String.dropLeft 1

                            newQparams =
                                toNextQuery newPageBody.activeSearch
                                    |> buildQueryParameters
                                    |> toQuery
                                    |> String.dropLeft 1

                            fullQueryParams =
                                joinQueryParams [ newQparams, newKeyboardParams ]

                            searchUrl =
                                { url | query = Just fullQueryParams }
                        in
                        SearchPage.searchPageRequest searchUrl

                    else
                        Cmd.none
            in
            ( SearchPage updatedSession newPageBody
            , Cmd.batch
                [ searchCmd
                , SearchPage.requestPreviewIfSelected newPageBody.selectedResult
                ]
                |> Cmd.map Msg.UserInteractedWithSearchPage
            )

        Route.SourcePageRoute _ ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordPageHelper
                        { model = model
                        , newSession = newSession
                        , previousRoute = previousRoute
                        , previousUrl = previousUrl
                        , route = route
                        , url = url
                        }
            in
            ( SourcePage newSession newPageBody
            , refreshCmds
            )

        Route.SourceContentsPageRoute _ qargs ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordContentsPageHelper
                        { model = model
                        , newSession = newSession
                        , previousUrl = previousUrl
                        , qargs = qargs
                        , route = route
                        , url = url
                        }
            in
            ( SourcePage newSession newPageBody
            , refreshCmds
            )

        Route.SourceHoldingsPageRoute _ _ ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordHoldingPageHelper
                        { model = model
                        , newSession = newSession
                        , previousUrl = previousUrl
                        , route = route
                        , url = url
                        }
            in
            ( HoldingPage newSession newPageBody
            , refreshCmds
            )

        Route.PersonPageRoute _ ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordPageHelper
                        { model = model
                        , newSession = newSession
                        , previousRoute = previousRoute
                        , previousUrl = previousUrl
                        , route = route
                        , url = url
                        }
            in
            ( PersonPage newSession newPageBody
            , refreshCmds
            )

        Route.PersonSourcePageRoute _ qargs ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordContentsPageHelper
                        { model = model
                        , newSession = newSession
                        , previousUrl = previousUrl
                        , qargs = qargs
                        , route = route
                        , url = url
                        }
            in
            ( PersonPage newSession newPageBody
            , refreshCmds
            )

        Route.InstitutionPageRoute _ ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordPageHelper
                        { model = model
                        , newSession = newSession
                        , previousRoute = previousRoute
                        , previousUrl = previousUrl
                        , route = route
                        , url = url
                        }
            in
            ( InstitutionPage newSession newPageBody
            , refreshCmds
            )

        Route.InstitutionSourcePageRoute _ qargs ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordContentsPageHelper
                        { model = model
                        , newSession = newSession
                        , previousUrl = previousUrl
                        , qargs = qargs
                        , route = route
                        , url = url
                        }
            in
            ( InstitutionPage newSession newPageBody
            , refreshCmds
            )

        Route.PublicationPageRoute _ ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordPageHelper
                        { model = model
                        , newSession = newSession
                        , previousRoute = previousRoute
                        , previousUrl = previousUrl
                        , route = route
                        , url = url
                        }
            in
            ( PublicationPage newSession newPageBody
            , refreshCmds
            )

        Route.PublicationWorksPageRoute _ qargs ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordContentsPageHelper
                        { model = model
                        , newSession = newSession
                        , previousUrl = previousUrl
                        , qargs = qargs
                        , route = route
                        , url = url
                        }
            in
            ( PublicationPage newSession newPageBody
            , refreshCmds
            )

        Route.PublicationsListPageRoute ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordPageHelper
                        { model = model
                        , newSession = newSession
                        , previousRoute = previousRoute
                        , previousUrl = previousUrl
                        , route = route
                        , url = url
                        }
            in
            ( PublicationListPage newSession newPageBody
            , refreshCmds
            )

        Route.WorkPageRoute _ ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordPageHelper
                        { model = model
                        , newSession = newSession
                        , previousRoute = previousRoute
                        , previousUrl = previousUrl
                        , route = route
                        , url = url
                        }
            in
            ( WorkPage newSession newPageBody
            , refreshCmds
            )

        Route.WorkSourcePageRoute _ qargs ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordContentsPageHelper
                        { model = model
                        , newSession = newSession
                        , previousUrl = previousUrl
                        , qargs = qargs
                        , route = route
                        , url = url
                        }
            in
            ( WorkPage newSession newPageBody
            , refreshCmds
            )

        Route.AboutPageRoute ->
            ( AboutPage newSession (AboutPage.init newSession)
            , AboutPage.initialCmd url
                |> Cmd.map Msg.UserInteractedWithAboutPage
            )

        Route.HelpPageRoute ->
            ( HelpPage newSession
            , Cmd.none
            )

        Route.OptionsPageRoute ->
            ( OptionsPage newSession (AboutPage.init newSession)
            , Cmd.none
            )

        Route.NotFoundPageRoute ->
            ( NotFoundPage newSession NotFoundPage.init
            , Cmd.none
            )


treatUrlAsExternal : Url -> Bool
treatUrlAsExternal requestedUrl =
    List.any identity
        [ requestedUrl.path == "/viewer.html"
        , requestedUrl.path == "/copperplate/copperplate.html"
        , isMEIDownloadRoute requestedUrl
        , isPNGDownloadRoute requestedUrl
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( Msg.ClientChangedUrl url, _ ) ->
            changePage url model

        ( Msg.ClientReceivedABadPortMessage _, _ ) ->
            ( model, Cmd.none )

        ( Msg.UserRequestedUrlChange urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    -- if the app is loading the viewer, treat it as an external link.
                    if treatUrlAsExternal url then
                        ( model
                        , Url.toString url
                            |> Nav.load
                        )

                    else
                        let
                            session =
                                toSession model
                        in
                        ( model
                        , Url.toString url
                            |> Nav.pushUrl session.key
                        )

                Browser.External href ->
                    ( model, Nav.load href )

        ( Msg.UserResizedWindow device width height, _ ) ->
            let
                isFramed =
                    toSession model
                        |> .isFramed

                navBar =
                    if isMobileView isFramed device then
                        BottomBar BottomBarOptions.init

                    else
                        SideBar SideBarOptions.init
            in
            ( toSession model
                |> setDevice device
                |> setWindow ( width, height )
                |> setNavigationBar navBar
                |> BE.flip updateSession model
            , Cmd.none
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

        ( Msg.UserInteractedWithRecordPage recordMsg, HoldingPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (HoldingPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, InstitutionPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (InstitutionPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, PublicationPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (PublicationPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, PublicationListPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (PublicationListPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithRecordPage recordMsg, WorkPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (WorkPage session) Msg.UserInteractedWithRecordPage model

        ( Msg.UserInteractedWithNotFoundPage notFoundMsg, NotFoundPage session pageModel ) ->
            NotFoundPage.update session notFoundMsg pageModel
                |> updateWith (NotFoundPage session) Msg.UserInteractedWithNotFoundPage model

        ( Msg.UserInteractedWithAboutPage recordMsg, AboutPage session pageModel ) ->
            AboutPage.update session recordMsg pageModel
                |> updateWith (AboutPage session) Msg.UserInteractedWithAboutPage model

        ( Msg.UserInteractedWithAboutPage recordMsg, OptionsPage session pageModel ) ->
            AboutPage.update session recordMsg pageModel
                |> updateWith (OptionsPage session) Msg.UserInteractedWithAboutPage model

        ( Msg.UserInteractedWithSideBar sideBarMsg, _ ) ->
            let
                ( newSession, sidebarCmd ) =
                    toSession model
                        |> SideBar.update sideBarMsg
            in
            ( updateSession newSession model
            , Cmd.map Msg.UserInteractedWithSideBar sidebarCmd
            )

        ( Msg.UserInteractedWithBottomBar bottomBarMsg, _ ) ->
            let
                ( newSession, bottomBarCmd ) =
                    toSession model
                        |> BottomBar.update bottomBarMsg
            in
            ( updateSession newSession model
            , Cmd.map Msg.UserInteractedWithBottomBar bottomBarCmd
            )

        ( Msg.NothingHappened, _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg _ ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


changeRecordPageHelper :
    { model : Model
    , newSession : Session
    , previousRoute : Route
    , previousUrl : Url
    , route : Route
    , url : Url
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
changeRecordPageHelper { model, newSession, previousRoute, previousUrl, route, url } =
    let
        recordCfg =
            { incomingUrl = url
            , route = route
            , queryArgs = Nothing
            , initialData = Nothing
            , session = newSession
            }

        previousRecordPath =
            baseRecordPathFromRoute previousRoute

        ( newPageBody, isSameRecordPage ) =
            reuseRecordPageBody
                { recordCfg = recordCfg
                , previousUrl = previousUrl
                , route = route
                , model = model
                , reuseIf =
                    \incoming ->
                        incoming.path
                            == previousUrl.path
                            || incoming.path
                            == previousRecordPath
                , getOldBody = getRecordBodyForRoute
                }
    in
    if isSameRecordPage then
        ( newPageBody, Cmd.none )

    else
        ( newPageBody
        , RecordPage.recordPageRequest newSession.cacheBuster url
            |> Cmd.map Msg.UserInteractedWithRecordPage
        )


changeRecordContentsPageHelper :
    { model : Model
    , newSession : Session
    , previousUrl : Url
    , qargs : QueryArgs
    , route : Route
    , url : Url
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
changeRecordContentsPageHelper { model, newSession, previousUrl, qargs, route, url } =
    let
        recordCfg =
            { incomingUrl = url
            , route = route
            , queryArgs = Just qargs
            , initialData = Nothing
            , session = newSession
            }

        recordPath =
            baseRecordPathFromRoute route

        ( newPageBody, isSameRecordPage ) =
            reuseRecordPageBody
                { recordCfg = recordCfg
                , previousUrl = previousUrl
                , route = route
                , model = model
                , reuseIf =
                    \incoming ->
                        incoming.path == previousUrl.path || previousUrl.path == recordPath
                , getOldBody = getRecordBodyForRoute
                }

        newQparams =
            toNextQuery newPageBody.activeSearch
                |> buildQueryParameters

        sourceUrl =
            serverUrl [ url.path ] newQparams
    in
    if isSameRecordPage then
        let
            resultsFetchCmd =
                if url.path == previousUrl.path && url.query == previousUrl.query then
                    Cmd.none

                else
                    RecordPage.recordSearchRequest sourceUrl
        in
        ( newPageBody
        , Cmd.batch
            [ RecordPage.requestPreviewIfSelected newPageBody.selectedResult
            , resultsFetchCmd
            ]
            |> Cmd.map Msg.UserInteractedWithRecordPage
        )

    else
        let
            recordUrl =
                { url | path = recordPath }
        in
        ( newPageBody
        , Cmd.batch
            [ RecordPage.recordSearchRequest sourceUrl
            , RecordPage.recordPageRequest newSession.cacheBuster recordUrl
            , RecordPage.requestPreviewIfSelected newPageBody.selectedResult
            ]
            |> Cmd.map Msg.UserInteractedWithRecordPage
        )


changeRecordHoldingPageHelper :
    { model : Model
    , newSession : Session
    , previousUrl : Url
    , route : Route
    , url : Url
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
changeRecordHoldingPageHelper { model, newSession, previousUrl, route, url } =
    let
        recordCfg =
            { incomingUrl = url
            , route = route
            , queryArgs = Nothing
            , initialData = Nothing
            , session = newSession
            }

        ( newPageBody, isSameRecordPage ) =
            reuseRecordPageBody
                { recordCfg = recordCfg
                , previousUrl = previousUrl
                , route = route
                , model = model
                , reuseIf = \incoming -> incoming.path == previousUrl.path
                , getOldBody = getRecordBodyForRoute
                }
    in
    if isSameRecordPage then
        ( newPageBody, Cmd.none )

    else
        ( newPageBody
        , RecordPage.recordPageRequest newSession.cacheBuster url
            |> Cmd.map Msg.UserInteractedWithRecordPage
        )


reuseRecordPageBody :
    { recordCfg : RecordPage.RecordConfig
    , previousUrl : Url
    , route : Route
    , model : Model
    , reuseIf : Url -> Bool
    , getOldBody : Route -> Model -> Maybe (RecordPageModel RecordMsg)
    }
    -> ( RecordPageModel RecordMsg, Bool )
reuseRecordPageBody cfg =
    case cfg.getOldBody cfg.route cfg.model of
        Just oldBody ->
            if cfg.reuseIf cfg.recordCfg.incomingUrl then
                ( RecordPage.load cfg.recordCfg oldBody, True )

            else
                ( RecordPage.init cfg.recordCfg, False )

        Nothing ->
            ( RecordPage.init cfg.recordCfg, False )


getRecordBodyForRoute : Route -> Model -> Maybe (RecordPageModel RecordMsg)
getRecordBodyForRoute route model =
    case ( route, model ) of
        ( Route.SourceContentsPageRoute _ _, SourcePage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.PersonSourcePageRoute _ _, PersonPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.InstitutionSourcePageRoute _ _, InstitutionPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.PublicationWorksPageRoute _ _, PublicationPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.WorkSourcePageRoute _ _, WorkPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.SourcePageRoute _, SourcePage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.PersonPageRoute _, PersonPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.InstitutionPageRoute _, InstitutionPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.PublicationPageRoute _, PublicationPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.PublicationsListPageRoute, PublicationListPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.WorkPageRoute _, WorkPage _ oldPageBody ) ->
            Just oldPageBody

        ( Route.SourceHoldingsPageRoute _ _, HoldingPage _ oldPageBody ) ->
            Just oldPageBody

        _ ->
            Nothing
