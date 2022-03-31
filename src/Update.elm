module Update exposing (..)

import Browser
import Browser.Navigation as Nav
import Device exposing (setDevice)
import Flip exposing (flip)
import Model exposing (Model(..), toSession, updateSession)
import Msg exposing (Msg)
import Page.Front as FrontPage
import Page.NotFound as NotFoundPage
import Page.Record as RecordPage
import Page.Route as Route exposing (parseUrl, setRoute, setUrl)
import Page.Search as SearchPage
import Page.SideBar as SideBar
import Url exposing (Url)


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
        Route.FrontPageRoute _ ->
            ( FrontPage newSession FrontPage.init
            , Cmd.map Msg.UserInteractedWithFrontPage (FrontPage.frontPageRequest url)
            )

        Route.NotFoundPageRoute ->
            ( NotFoundPage newSession NotFoundPage.init
            , Cmd.none
            )

        Route.SearchPageRoute _ _ ->
            let
                -- set the old data on the Loading response
                -- so that the view keeps the old appearance until
                -- the new data is loaded. In the case where we're
                -- coming from another page, or the response doesn't
                -- already contain server data we instead initialize
                -- a default search page model.
                newPageModel =
                    case model of
                        SearchPage _ oldPageModel ->
                            SearchPage.load url oldPageModel

                        _ ->
                            SearchPage.init url route
            in
            ( SearchPage newSession newPageModel
            , Cmd.batch
                [ SearchPage.searchPageRequest url
                , SearchPage.requestPreviewIfSelected newPageModel.selectedResult
                ]
                |> Cmd.map Msg.UserInteractedWithSearchPage
            )

        Route.SourcePageRoute _ ->
            ( SourcePage newSession (RecordPage.init url route)
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        Route.PersonPageRoute _ ->
            ( PersonPage newSession (RecordPage.init url route)
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        Route.InstitutionPageRoute _ ->
            ( InstitutionPage newSession (RecordPage.init url route)
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
            )

        Route.InstitutionSourcePageRoute _ _ ->
            let
                recordPath =
                    String.replace "/sources" "" url.path

                recordUrl =
                    { url | path = recordPath }

                newModel =
                    case model of
                        InstitutionPage _ oldModel ->
                            RecordPage.load url oldModel

                        _ ->
                            RecordPage.init url route
            in
            ( InstitutionPage newSession newModel
            , Cmd.batch
                [ RecordPage.recordPageRequest recordUrl
                , RecordPage.requestPreviewIfSelected newModel.selectedResult
                ]
                |> Cmd.map Msg.UserInteractedWithRecordPage
            )

        Route.PlacePageRoute _ ->
            ( PlacePage newSession (RecordPage.init url route)
            , Cmd.map Msg.UserInteractedWithRecordPage (RecordPage.recordPageRequest url)
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

        ( Msg.UserInteractedWithNotFoundPage notFoundMsg, NotFoundPage session pageModel ) ->
            NotFoundPage.update session notFoundMsg pageModel
                |> updateWith (NotFoundPage session) Msg.UserInteractedWithNotFoundPage model

        ( Msg.NothingHappened, _ ) ->
            ( model, Cmd.none )

        ( Msg.ClientReceivedABadPortMessage _, _ ) ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
