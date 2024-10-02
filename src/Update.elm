module Update exposing (update)

import Basics.Extra as BE
import Browser
import Browser.Navigation as Nav
import Device exposing (setDevice, setWindow)
import Model exposing (Model(..), isSourcePage, toSession, updateSession)
import Msg exposing (Msg)
import Page.About as AboutPage
import Page.BottomBar as BottomBar
import Page.Error as NotFoundPage
import Page.Front as FrontPage
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs, buildQueryParameters, toNextQuery)
import Page.Record as RecordPage
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Route as Route exposing (Route, isMEIDownloadRoute, isPNGDownloadRoute, parseUrl, setRoute, setUrl)
import Page.Search as SearchPage
import Page.SideBar as SideBar
import Session exposing (Session)
import Url exposing (Url)
import Url.Builder exposing (toQuery)


changeRecordPageHelper :
    { model : Model
    , previousUrl : Url
    , url : Url
    , newSession : Session
    , route : Route
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
changeRecordPageHelper { model, previousUrl, url, newSession, route } =
    let
        recordCfg =
            { incomingUrl = url
            , route = route
            , queryArgs = Nothing
            , nationalCollection = newSession.restrictedToNationalCollection
            , searchPreferences = newSession.searchPreferences
            }

        contentsUrlSuffix =
            if isSourcePage model then
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
    , previousUrl : Url
    , url : Url
    , newSession : Session
    , route : Route
    , qargs : QueryArgs
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
changeRecordContentsPageHelper { model, previousUrl, url, newSession, route, qargs } =
    let
        contentsUrlSuffix =
            if isSourcePage model then
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
                ( Route.PersonSourcePageRoute _ _, PersonPage _ oldPageBody ) ->
                    samePage oldPageBody

                ( Route.SourceContentsPageRoute _ _, SourcePage _ oldPageBody ) ->
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
            , Cmd.map Msg.UserInteractedWithFrontPage (FrontPage.frontPageRequest url)
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
                        , previousUrl = previousUrl
                        , url = url
                        , newSession = newSession
                        , route = route
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
                        , url = url
                        , previousUrl = previousUrl
                        , qargs = qargs
                        , newSession = newSession
                        , route = route
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
                        , previousUrl = previousUrl
                        , url = url
                        , newSession = newSession
                        , route = route
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
                        , url = url
                        , previousUrl = previousUrl
                        , qargs = qargs
                        , newSession = newSession
                        , route = route
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
                        , previousUrl = previousUrl
                        , url = url
                        , newSession = newSession
                        , route = route
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
                        , url = url
                        , previousUrl = previousUrl
                        , qargs = qargs
                        , newSession = newSession
                        , route = route
                        }
            in
            ( InstitutionPage newSession newPageBody
            , refreshCmds
            )

        Route.AboutPageRoute ->
            ( AboutPage newSession (AboutPage.init newSession)
            , Cmd.map Msg.UserInteractedWithAboutPage (AboutPage.initialCmd url)
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
                        ( model, Nav.load (Url.toString url) )

                    else
                        let
                            session =
                                toSession model
                        in
                        ( model, Nav.pushUrl session.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( Msg.UserResizedWindow device width height, _ ) ->
            let
                newModel =
                    toSession model
                        |> setDevice device
                        |> setWindow ( width, height )
                        |> BE.flip updateSession model
            in
            ( newModel, Cmd.none )

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
