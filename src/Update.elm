module Update exposing (update)

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
        oldSession =
            toSession model

        previousUrl =
            oldSession.url

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
                        { queryArgs = qargs }
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
                fullQueryParams =
                    newQparams ++ "&" ++ newKeyboardParams

                newKeyboardParams =
                    buildNotationQueryParameters kqargs
                        |> toQuery
                        |> String.dropLeft 1

                newPageBody =
                    case model of
                        SearchPage _ oldPageBody ->
                            SearchPage.load searchCfg oldPageBody

                        _ ->
                            SearchPage.init searchCfg

                newQparams =
                    toNextQuery newPageBody.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                searchCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = qargs
                    , keyboardQueryArgs = kqargs
                    }

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
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                ( newPageBody, isSameSourcePage ) =
                    case model of
                        SourcePage _ oldPageBody ->
                            if url.path == previousUrl.path || url.path == String.replace "/contents" "" previousUrl.path then
                                ( RecordPage.load recordCfg oldPageBody, True )

                            else
                                ( RecordPage.init recordCfg, False )

                        _ ->
                            ( RecordPage.init recordCfg, False )

                sourceQuery =
                    toNextQuery newPageBody.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                sourceContentsPath =
                    if String.endsWith "/" url.path then
                        url.path ++ "contents"

                    else
                        url.path ++ "/contents"

                sourcesUrl =
                    { url
                        | path = sourceContentsPath
                        , query = Just sourceQuery
                    }

                refreshCmds =
                    if isSameSourcePage then
                        Cmd.none

                    else
                        Cmd.batch
                            [ RecordPage.recordPageRequest url
                            , RecordPage.recordSearchRequest sourcesUrl
                            ]
                            |> Cmd.map Msg.UserInteractedWithRecordPage
            in
            ( SourcePage newSession newPageBody
            , refreshCmds
            )

        Route.SourceContentsPageRoute _ qargs ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                recordPath =
                    String.replace "/contents" "" url.path

                ( newPageBody, isSameSourcePage ) =
                    case model of
                        SourcePage _ oldPageBody ->
                            if url.path == previousUrl.path || previousUrl.path == recordPath then
                                ( RecordPage.load recordCfg oldPageBody, True )

                            else
                                ( RecordPage.init recordCfg, False )

                        _ ->
                            ( RecordPage.init recordCfg, False )

                newQparams =
                    toNextQuery newPageBody.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                recordUrl =
                    { url | path = recordPath }

                sourceUrl =
                    { url | query = Just newQparams }

                refreshCmds =
                    if isSameSourcePage then
                        RecordPage.requestPreviewIfSelected newPageBody.selectedResult
                            |> Cmd.map Msg.UserInteractedWithRecordPage

                    else
                        Cmd.batch
                            [ RecordPage.recordPageRequest recordUrl
                            , RecordPage.recordSearchRequest sourceUrl
                            , RecordPage.requestPreviewIfSelected newPageBody.selectedResult
                            ]
                            |> Cmd.map Msg.UserInteractedWithRecordPage
            in
            ( SourcePage newSession newPageBody
            , refreshCmds
            )

        Route.PersonPageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                ( newPageBody, isSamePersonPage ) =
                    case model of
                        PersonPage _ oldPageBody ->
                            if url.path == previousUrl.path || url.path == String.replace "/sources" "" previousUrl.path then
                                ( RecordPage.load recordCfg oldPageBody, True )

                            else
                                ( RecordPage.init recordCfg, False )

                        _ ->
                            ( RecordPage.init recordCfg, False )

                sourceQuery =
                    toNextQuery newPageBody.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                sourcesUrl =
                    { url | path = url.path ++ "/sources", query = Just sourceQuery }

                refreshCmds =
                    if isSamePersonPage then
                        Cmd.none

                    else
                        Cmd.batch
                            [ RecordPage.recordPageRequest url
                            , RecordPage.recordSearchRequest sourcesUrl
                            ]
                            |> Cmd.map Msg.UserInteractedWithRecordPage
            in
            ( PersonPage newSession newPageBody
            , refreshCmds
            )

        Route.PersonSourcePageRoute _ qargs ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                recordPath =
                    String.replace "/sources" "" url.path

                ( newPageBody, isSamePersonPage ) =
                    case model of
                        PersonPage _ oldPageBody ->
                            if url.path == previousUrl.path || previousUrl.path == recordPath then
                                ( RecordPage.load recordCfg oldPageBody, True )

                            else
                                ( RecordPage.init recordCfg, False )

                        _ ->
                            ( RecordPage.init recordCfg, False )

                newQparams =
                    toNextQuery newPageBody.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                recordUrl =
                    { url | path = recordPath }

                sourceUrl =
                    { url | query = Just newQparams }

                refreshCmds =
                    if isSamePersonPage then
                        RecordPage.requestPreviewIfSelected newPageBody.selectedResult
                            |> Cmd.map Msg.UserInteractedWithRecordPage

                    else
                        Cmd.batch
                            [ RecordPage.recordPageRequest recordUrl
                            , RecordPage.recordSearchRequest sourceUrl
                            , RecordPage.requestPreviewIfSelected newPageBody.selectedResult
                            ]
                            |> Cmd.map Msg.UserInteractedWithRecordPage
            in
            ( PersonPage newSession newPageBody
            , refreshCmds
            )

        Route.InstitutionPageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                ( newPageBody, isSameInstitutionPage ) =
                    case model of
                        InstitutionPage _ oldPageBody ->
                            if url.path == previousUrl.path || url.path == String.replace "/sources" "" previousUrl.path then
                                ( RecordPage.load recordCfg oldPageBody, True )

                            else
                                ( RecordPage.init recordCfg, False )

                        _ ->
                            ( RecordPage.init recordCfg, False )

                sourceQuery =
                    toNextQuery newPageBody.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                sourcesUrl =
                    { url | path = url.path ++ "/sources", query = Just sourceQuery }

                refreshCmds =
                    if isSameInstitutionPage then
                        Cmd.none

                    else
                        Cmd.batch
                            [ RecordPage.recordPageRequest url
                            , RecordPage.recordSearchRequest sourcesUrl
                            ]
                            |> Cmd.map Msg.UserInteractedWithRecordPage
            in
            ( InstitutionPage newSession newPageBody
            , refreshCmds
            )

        Route.InstitutionSourcePageRoute _ qargs ->
            let
                recordCfg =
                    { incomingUrl = url
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = newSession.restrictedToNationalCollection
                    }

                recordPath =
                    String.replace "/sources" "" url.path

                ( newPageBody, isSameInstitutionPage ) =
                    case model of
                        InstitutionPage _ oldPageBody ->
                            if url.path == previousUrl.path || previousUrl.path == recordPath then
                                ( RecordPage.load recordCfg oldPageBody, True )

                            else
                                ( RecordPage.init recordCfg, False )

                        _ ->
                            ( RecordPage.init recordCfg, False )

                newQparams =
                    toNextQuery newPageBody.activeSearch
                        |> buildQueryParameters
                        |> toQuery
                        |> String.dropLeft 1

                recordUrl =
                    { url | path = recordPath }

                sourceUrl =
                    { url | query = Just newQparams }

                refreshCmds =
                    if isSameInstitutionPage then
                        RecordPage.requestPreviewIfSelected newPageBody.selectedResult
                            |> Cmd.map Msg.UserInteractedWithRecordPage

                    else
                        Cmd.batch
                            [ RecordPage.recordPageRequest recordUrl
                            , RecordPage.recordSearchRequest sourceUrl
                            , RecordPage.requestPreviewIfSelected newPageBody.selectedResult
                            ]
                            |> Cmd.map Msg.UserInteractedWithRecordPage
            in
            ( InstitutionPage newSession newPageBody
            , refreshCmds
            )

        Route.AboutPageRoute ->
            ( AboutPage newSession AboutPage.init
            , Cmd.map Msg.UserInteractedWithAboutPage (AboutPage.initialCmd url)
            )

        {-
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
        -}
        Route.NotFoundPageRoute ->
            ( NotFoundPage newSession NotFoundPage.init
            , Cmd.none
            )


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
                    if url.path == "/viewer.html" then
                        ( model, Nav.load (Url.toString url) )

                    else
                        let
                            session =
                                toSession model
                        in
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

        ( Msg.UserInteractedWithSideBar sideBarMsg, _ ) ->
            let
                newModel =
                    updateSession newSession model

                ( newSession, sidebarCmd ) =
                    toSession model
                        |> SideBar.update sideBarMsg
            in
            ( newModel
            , Cmd.map Msg.UserInteractedWithSideBar sidebarCmd
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
