module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Flags exposing (Flags)
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.About as About
import Page.Front as Front
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.NotFound as NotFound
import Page.Record as Record
import Page.Route as Route exposing (Route(..))
import Page.Search as Search
import Page.SideBar as Sidebar
import Page.UpdateHelpers exposing (addNationalCollectionFilter, addNationalCollectionQueryParameter)
import Session
import Subscriptions
import Update
import Url exposing (Url)
import Url.Builder exposing (toQuery)
import View


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        , onUrlChange = Msg.ClientChangedUrl
        , onUrlRequest = Msg.UserRequestedUrlChange
        }


{-|

    The initial model state

-}
init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags initialUrl key =
    let
        route =
            Route.parseUrl initialUrl

        session =
            Session.init flags initialUrl key
    in
    case route of
        FrontPageRoute qargs ->
            let
                initialModel =
                    Front.init
                        { queryArgs = qargs }
            in
            ( FrontPage session initialModel
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithFrontPage <| Front.frontPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        SearchPageRoute qargs kqargs ->
            let
                searchCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = qargs
                    , keyboardQueryArgs = kqargs
                    }

                initialModel =
                    Search.init searchCfg

                ncAppliedModel =
                    addNationalCollectionFilter session.restrictedToNationalCollection initialModel

                newQparams =
                    addNationalCollectionQueryParameter session qargs

                kqArgParams =
                    buildNotationQueryParameters kqargs
                        |> toQuery
                        |> String.dropLeft 1

                fullQueryParams =
                    newQparams ++ "&" ++ kqArgParams

                searchUrl =
                    { initialUrl | query = Just fullQueryParams }
            in
            ( SearchPage session ncAppliedModel
            , Cmd.batch
                [ Cmd.batch
                    [ Search.searchPageRequest searchUrl
                    , Search.requestPreviewIfSelected initialModel.selectedResult
                    ]
                    |> Cmd.map Msg.UserInteractedWithSearchPage
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        PersonPageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = session.restrictedToNationalCollection
                    }

                initialModel =
                    Record.init recordCfg

                ncAppliedModel =
                    addNationalCollectionFilter session.restrictedToNationalCollection initialModel

                ncQueryParam =
                    case session.restrictedToNationalCollection of
                        Just c ->
                            Just ("nc=" ++ c)

                        Nothing ->
                            Nothing

                sourcesUrl =
                    { initialUrl | path = initialUrl.path ++ "/sources", query = ncQueryParam }
            in
            ( PersonPage session ncAppliedModel
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordSearchRequest sourcesUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        PersonSourcePageRoute _ qargs ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = session.restrictedToNationalCollection
                    }

                initialModel =
                    Record.init recordCfg

                ncAppliedModel =
                    addNationalCollectionFilter session.restrictedToNationalCollection initialModel

                recordPath =
                    String.replace "/sources" "" initialUrl.path

                newQparams =
                    addNationalCollectionQueryParameter session qargs

                recordUrl =
                    { initialUrl | path = recordPath }

                sourcesUrl =
                    { initialUrl | query = Just newQparams }
            in
            ( PersonPage session ncAppliedModel
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest recordUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordSearchRequest sourcesUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.requestPreviewIfSelected initialModel.selectedResult
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        InstitutionPageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = session.restrictedToNationalCollection
                    }

                initialModel =
                    Record.init recordCfg

                ncAppliedModel =
                    addNationalCollectionFilter session.restrictedToNationalCollection initialModel

                ncQueryParam =
                    case session.restrictedToNationalCollection of
                        Just c ->
                            Just ("nc=" ++ c)

                        Nothing ->
                            Nothing

                sourcesUrl =
                    { initialUrl | path = initialUrl.path ++ "/sources", query = ncQueryParam }
            in
            ( InstitutionPage session ncAppliedModel
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordSearchRequest sourcesUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        InstitutionSourcePageRoute _ qargs ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = session.restrictedToNationalCollection
                    }

                initialModel =
                    Record.init recordCfg

                ncAppliedModel =
                    addNationalCollectionFilter session.restrictedToNationalCollection initialModel

                recordPath =
                    String.replace "/sources" "" initialUrl.path

                newQparams =
                    addNationalCollectionQueryParameter session qargs

                recordUrl =
                    { initialUrl | path = recordPath }

                sourcesUrl =
                    { initialUrl | query = Just newQparams }
            in
            ( InstitutionPage session ncAppliedModel
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest recordUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordSearchRequest sourcesUrl
                , Cmd.map Msg.UserInteractedWithRecordPage <| Record.requestPreviewIfSelected initialModel.selectedResult
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        SourcePageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = session.restrictedToNationalCollection
                    }
            in
            ( SourcePage session <| Record.init recordCfg
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        PlacePageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = session.restrictedToNationalCollection
                    }
            in
            ( PlacePage session <| Record.init recordCfg
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithRecordPage <| Record.recordPageRequest initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        AboutPageRoute ->
            ( AboutPage session <| About.init
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithAboutPage <| About.initialCmd initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )

        _ ->
            ( NotFoundPage session NotFound.init
            , Cmd.batch
                [ Cmd.map Msg.UserInteractedWithNotFoundPage <| NotFound.initialCmd initialUrl
                , Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
                ]
            )
