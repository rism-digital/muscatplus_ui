module Update exposing (update)

import Basics.Extra as BE
import Browser
import Browser.Navigation as Nav
import Device exposing (isMobileView, setDevice, setWindow)
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
import Page.Route as Route exposing (Route, isMEIDownloadRoute, isPNGDownloadRoute, isSourcePageRoute, parseUrl, setRoute, setUrl)
import Page.Search as SearchPage
import Page.SideBar as SideBar
import Page.SideBar.Options as SideBarOptions
import Session exposing (Session)
import Url exposing (Url)
import Url.Builder exposing (toQuery)


changePage : Url -> Model -> ( Model, Cmd Msg )
changePage url model =
    let
        previousUrl =
            toSession model
                |> .url

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
                        , searchPreferences = newSession.searchPreferences
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
                    }

                newPageBody =
                    case model of
                        SearchPage _ oldPageBody ->
                            SearchPage.load searchCfg oldPageBody

                        _ ->
                            SearchPage.init searchCfg

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
                    newQparams ++ "&" ++ newKeyboardParams

                searchUrl =
                    { url | query = Just fullQueryParams }
            in
            ( SearchPage newSession newPageBody
            , Cmd.batch
                [ SearchPage.searchPageRequest searchUrl
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

        Route.PersonPageRoute _ ->
            let
                ( newPageBody, refreshCmds ) =
                    changeRecordPageHelper
                        { model = model
                        , newSession = newSession
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
                navBar =
                    if isMobileView device then
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

        ( Msg.UserInteractedWithRecordPage recordMsg, InstitutionPage session pageModel ) ->
            RecordPage.update session recordMsg pageModel
                |> updateWith (InstitutionPage session) Msg.UserInteractedWithRecordPage model

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
    , previousUrl : Url
    , route : Route
    , url : Url
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
changeRecordPageHelper { model, newSession, previousUrl, route, url } =
    let
        recordCfg =
            { incomingUrl = url
            , route = route
            , queryArgs = Nothing
            , nationalCollection = newSession.restrictedToNationalCollection
            , searchPreferences = newSession.searchPreferences
            }

        contentsUrlSuffix =
            if isSourcePageRoute url then
                "/contents"

            else
                "/sources"

        samePage oldBody =
            if url.path == previousUrl.path || url.path == String.replace contentsUrlSuffix "" previousUrl.path then
                ( RecordPage.load recordCfg oldBody, True )

            else
                ( RecordPage.init recordCfg, False )

        ( newPageBody, isSameRecordPage ) =
            case ( route, model ) of
                ( Route.SourcePageRoute _, SourcePage _ oldPageBody ) ->
                    samePage oldPageBody

                ( Route.PersonPageRoute _, PersonPage _ oldPageBody ) ->
                    samePage oldPageBody

                ( Route.InstitutionPageRoute _, InstitutionPage _ oldPageBody ) ->
                    samePage oldPageBody

                _ ->
                    ( RecordPage.init recordCfg, False )
    in
    if isSameRecordPage then
        ( newPageBody, Cmd.none )

    else
        let
            sourceQuery =
                toNextQuery newPageBody.activeSearch
                    |> buildQueryParameters
                    |> toQuery
                    |> String.dropLeft 1

            sourceContentsPath =
                if String.endsWith "/" url.path then
                    url.path ++ String.dropLeft 1 contentsUrlSuffix

                else
                    url.path ++ contentsUrlSuffix

            sourcesUrl =
                { url
                    | path = sourceContentsPath
                    , query = Just sourceQuery
                }
        in
        ( newPageBody
        , Cmd.batch
            [ RecordPage.recordPageRequest newSession.cacheBuster url
            , RecordPage.recordSearchRequest sourcesUrl
            ]
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
        contentsUrlSuffix =
            if isSourcePageRoute url then
                "/contents"

            else
                "/sources"

        recordPath =
            String.replace contentsUrlSuffix "" url.path

        recordCfg =
            { incomingUrl = url
            , route = route
            , queryArgs = Just qargs
            , nationalCollection = newSession.restrictedToNationalCollection
            , searchPreferences = newSession.searchPreferences
            }

        samePage oldBody =
            if url.path == previousUrl.path || previousUrl.path == recordPath then
                RecordPage.load recordCfg oldBody

            else
                RecordPage.init recordCfg

        newPageBody =
            case ( route, model ) of
                ( Route.SourceContentsPageRoute _ _, SourcePage _ oldPageBody ) ->
                    samePage oldPageBody

                ( Route.PersonSourcePageRoute _ _, PersonPage _ oldPageBody ) ->
                    samePage oldPageBody

                ( Route.InstitutionSourcePageRoute _ _, InstitutionPage _ oldPageBody ) ->
                    samePage oldPageBody

                _ ->
                    RecordPage.init recordCfg

        recordUrl =
            { url | path = recordPath }

        newQparams =
            toNextQuery newPageBody.activeSearch
                |> buildQueryParameters
                |> toQuery
                |> String.dropLeft 1

        sourceUrl =
            { url | query = Just newQparams }
    in
    ( newPageBody
    , Cmd.batch
        [ RecordPage.recordPageRequest newSession.cacheBuster recordUrl
        , RecordPage.recordSearchRequest sourceUrl
        , RecordPage.requestPreviewIfSelected newPageBody.selectedResult
        ]
        |> Cmd.map Msg.UserInteractedWithRecordPage
    )
