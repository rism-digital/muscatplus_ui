module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Desktop
import Device exposing (isMobileView)
import Flags exposing (Flags)
import Mobile
import Model exposing (Model(..), toSession)
import Msg exposing (Msg)
import Page.About as About
import Page.Error as NotFound
import Page.Front as Front
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Record as Record
import Page.Route as Route exposing (Route(..))
import Page.Search as Search
import Page.SideBar as Sidebar
import Page.UpdateHelpers exposing (addNationalCollectionFilter, addNationalCollectionQueryParameter)
import Session exposing (Session)
import Subscriptions
import Update
import Url exposing (Url)
import Url.Builder exposing (toQuery)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = Msg.ClientChangedUrl
        , onUrlRequest = Msg.UserRequestedUrlChange
        , subscriptions = Subscriptions.subscriptions
        , update = Update.update
        , view = view
        }


view : Model -> Browser.Document Msg
view model =
    if isMobileView (.device (toSession model)) then
        Mobile.view model

    else
        Desktop.view model


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

        countryListRequest =
            if isMobileView session.device then
                Cmd.none

            else
                Cmd.map Msg.UserInteractedWithSideBar Sidebar.countryListRequest
    in
    case route of
        FrontPageRoute qargs ->
            let
                initialBody =
                    Front.init
                        { queryArgs = qargs
                        , searchPreferences = session.searchPreferences
                        }
                        |> addNationalCollectionFilter session.restrictedToNationalCollection
            in
            ( FrontPage session initialBody
            , Cmd.batch
                [ Front.frontPageRequest initialUrl
                    |> Cmd.map Msg.UserInteractedWithFrontPage
                , countryListRequest
                ]
            )

        SearchPageRoute qargs kqargs ->
            let
                searchCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = qargs
                    , keyboardQueryArgs = kqargs
                    , searchPreferences = session.searchPreferences
                    }

                initialBody =
                    Search.init searchCfg
                        |> addNationalCollectionFilter session.restrictedToNationalCollection

                kqArgParams =
                    buildNotationQueryParameters kqargs
                        |> toQuery
                        |> String.dropLeft 1

                newQparams =
                    addNationalCollectionQueryParameter session qargs

                fullQueryParams =
                    String.concat [ newQparams, "&", kqArgParams ]

                searchUrl =
                    { initialUrl | query = Just fullQueryParams }
            in
            ( SearchPage session initialBody
            , Cmd.batch
                [ Cmd.batch
                    [ Search.searchPageRequest searchUrl
                    , Search.requestPreviewIfSelected initialBody.selectedResult
                    ]
                    |> Cmd.map Msg.UserInteractedWithSearchPage
                , countryListRequest
                ]
            )

        SourcePageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = session.restrictedToNationalCollection
                    , searchPreferences = session.searchPreferences
                    }

                initialBody =
                    Record.init recordCfg
                        |> addNationalCollectionFilter session.restrictedToNationalCollection

                ncQueryParam =
                    Maybe.map (\c -> "nc=" ++ c) session.restrictedToNationalCollection

                sourceContentsPath =
                    if String.endsWith "/" initialUrl.path then
                        initialUrl.path ++ "contents"

                    else
                        initialUrl.path ++ "/contents"

                sourcesUrl =
                    { initialUrl
                        | path = sourceContentsPath
                        , query = ncQueryParam
                    }
            in
            ( SourcePage session initialBody
            , Cmd.batch
                [ Cmd.batch
                    [ Record.recordPageRequest session.cacheBuster initialUrl
                    , Record.recordSearchRequest sourcesUrl
                    ]
                    |> Cmd.map Msg.UserInteractedWithRecordPage
                , countryListRequest
                ]
            )

        SourceContentsPageRoute _ qargs ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = session.restrictedToNationalCollection
                    , searchPreferences = session.searchPreferences
                    }

                initialBody =
                    Record.init recordCfg
                        |> addNationalCollectionFilter session.restrictedToNationalCollection

                recordPath =
                    String.replace "/contents" "" initialUrl.path

                recordUrl =
                    { initialUrl | path = recordPath }

                newQparams =
                    addNationalCollectionQueryParameter session qargs

                sourcesUrl =
                    { initialUrl | query = Just newQparams }
            in
            ( SourcePage session initialBody
            , Cmd.batch
                [ Cmd.batch
                    [ Record.recordPageRequest session.cacheBuster recordUrl
                    , Record.recordSearchRequest sourcesUrl
                    , Record.requestPreviewIfSelected initialBody.selectedResult
                    ]
                    |> Cmd.map Msg.UserInteractedWithRecordPage
                , countryListRequest
                ]
            )

        PersonPageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = session.restrictedToNationalCollection
                    , searchPreferences = session.searchPreferences
                    }

                initialBody =
                    Record.init recordCfg
                        |> addNationalCollectionFilter session.restrictedToNationalCollection

                ncQueryParam =
                    Maybe.map (\c -> "nc=" ++ c) session.restrictedToNationalCollection

                sourcesUrl =
                    { initialUrl | path = initialUrl.path ++ "/sources", query = ncQueryParam }
            in
            ( PersonPage session initialBody
            , Cmd.batch
                [ Cmd.batch
                    [ Record.recordPageRequest session.cacheBuster initialUrl
                    , Record.recordSearchRequest sourcesUrl
                    ]
                    |> Cmd.map Msg.UserInteractedWithRecordPage
                , countryListRequest
                ]
            )

        PersonSourcePageRoute _ qargs ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = session.restrictedToNationalCollection
                    , searchPreferences = session.searchPreferences
                    }

                initialBody =
                    Record.init recordCfg
                        |> addNationalCollectionFilter session.restrictedToNationalCollection

                recordPath =
                    String.replace "/sources" "" initialUrl.path

                recordUrl =
                    { initialUrl | path = recordPath }

                newQparams =
                    addNationalCollectionQueryParameter session qargs

                sourcesUrl =
                    { initialUrl | query = Just newQparams }
            in
            ( PersonPage session initialBody
            , Cmd.batch
                [ Cmd.batch
                    [ Record.recordPageRequest session.cacheBuster recordUrl
                    , Record.recordSearchRequest sourcesUrl
                    , Record.requestPreviewIfSelected initialBody.selectedResult
                    ]
                    |> Cmd.map Msg.UserInteractedWithRecordPage
                , countryListRequest
                ]
            )

        InstitutionPageRoute _ ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Nothing
                    , nationalCollection = session.restrictedToNationalCollection
                    , searchPreferences = session.searchPreferences
                    }

                initialBody =
                    Record.init recordCfg
                        |> addNationalCollectionFilter session.restrictedToNationalCollection

                ncQueryParam =
                    Maybe.map (\c -> "nc=" ++ c) session.restrictedToNationalCollection

                sourcesUrl =
                    { initialUrl | path = initialUrl.path ++ "/sources", query = ncQueryParam }
            in
            ( InstitutionPage session initialBody
            , Cmd.batch
                [ Cmd.batch
                    [ Record.recordPageRequest session.cacheBuster initialUrl
                    , Record.recordSearchRequest sourcesUrl
                    ]
                    |> Cmd.map Msg.UserInteractedWithRecordPage
                , countryListRequest
                ]
            )

        InstitutionSourcePageRoute _ qargs ->
            let
                recordCfg =
                    { incomingUrl = initialUrl
                    , route = route
                    , queryArgs = Just qargs
                    , nationalCollection = session.restrictedToNationalCollection
                    , searchPreferences = session.searchPreferences
                    }

                initialBody =
                    Record.init recordCfg
                        |> addNationalCollectionFilter session.restrictedToNationalCollection

                recordPath =
                    String.replace "/sources" "" initialUrl.path

                recordUrl =
                    { initialUrl | path = recordPath }

                newQparams =
                    addNationalCollectionQueryParameter session qargs

                sourcesUrl =
                    { initialUrl | query = Just newQparams }
            in
            ( InstitutionPage session initialBody
            , Cmd.batch
                [ Cmd.batch
                    [ Record.recordPageRequest session.cacheBuster recordUrl
                    , Record.recordSearchRequest sourcesUrl
                    , Record.requestPreviewIfSelected initialBody.selectedResult
                    ]
                    |> Cmd.map Msg.UserInteractedWithRecordPage
                , countryListRequest
                ]
            )

        AboutPageRoute ->
            ( AboutPage session (About.init session)
            , Cmd.batch
                [ About.initialCmd initialUrl
                    |> Cmd.map Msg.UserInteractedWithAboutPage
                , countryListRequest
                ]
            )

        HelpPageRoute ->
            ( HelpPage session
            , countryListRequest
            )

        OptionsPageRoute ->
            ( OptionsPage session (About.init session)
            , countryListRequest
            )

        _ ->
            ( NotFoundPage session NotFound.init
            , Cmd.batch
                [ NotFound.initialCmd initialUrl
                    |> Cmd.map Msg.UserInteractedWithNotFoundPage
                , countryListRequest
                ]
            )
