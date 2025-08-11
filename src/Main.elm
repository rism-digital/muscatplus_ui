module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Device exposing (isMobileView)
import Dict
import Flags exposing (Flags)
import Json.Decode exposing (Value)
import Maybe.Extra as ME
import Model exposing (Model(..))
import Msg exposing (Msg)
import Page.About as About
import Page.Error as NotFound
import Page.Front as Front
import Page.Front.Msg exposing (FrontMsg(..))
import Page.Keyboard.Query exposing (buildNotationQueryParameters)
import Page.Query exposing (QueryArgs)
import Page.Record as Record exposing (sourceFetchCmd)
import Page.Record.Model exposing (RecordPageModel)
import Page.Record.Msg exposing (RecordMsg)
import Page.Request exposing (createProbeRequestWithDecoder)
import Page.Route as Route exposing (Route(..), baseRecordPathFromRoute)
import Page.Search as Search
import Page.SideBar as Sidebar
import Page.UpdateHelpers exposing (addNationalCollectionFilter, addNationalCollectionQueryParameter, createProbeUrl)
import Session exposing (Session)
import Subscriptions
import Update
import Url exposing (Url)
import Url.Builder exposing (toQuery)
import Views


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = Msg.ClientChangedUrl
        , onUrlRequest = Msg.UserRequestedUrlChange
        , subscriptions = Subscriptions.subscriptions
        , update = Update.update
        , view = Views.view
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

        countryListRequest =
            if isMobileView session.isFramed session.device then
                Cmd.none

            else if not (Dict.isEmpty session.allNationalCollections) then
                -- if the national collections property is not empty, it means that the
                -- country list was passed in via the flags and successfully decoded,
                -- so no need to re-fetch it.
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
                        , initialData = flags.initialData
                        }
                        |> addNationalCollectionFilter session.restrictedToNationalCollection

                frontDataFetchCmd =
                    case flags.initialData of
                        Just _ ->
                            -- if the initial data was passed in, no need to
                            -- fetch it.
                            Cmd.none

                        Nothing ->
                            Front.frontPageRequest initialUrl

                probeUrl =
                    createProbeUrl session initialBody.activeSearch
            in
            ( FrontPage session initialBody
            , Cmd.batch
                [ Cmd.batch
                    [ frontDataFetchCmd
                    , createProbeRequestWithDecoder ServerRespondedWithProbeData probeUrl
                    ]
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

                updatedSession =
                    if ME.isNothing qargs.nationalCollection then
                        { session | restrictedToNationalCollection = Nothing }

                    else
                        session

                kqArgParams =
                    buildNotationQueryParameters kqargs
                        |> toQuery
                        |> String.dropLeft 1

                newQparams =
                    addNationalCollectionQueryParameter updatedSession qargs

                fullQueryParams =
                    String.concat [ newQparams, "&", kqArgParams ]

                searchUrl =
                    { initialUrl | query = Just fullQueryParams }
            in
            ( SearchPage updatedSession initialBody
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
                ( initialBody, initialCmds ) =
                    recordRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , route = route
                        , session = session
                        }
            in
            ( SourcePage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        SourceContentsPageRoute _ qargs ->
            let
                ( initialBody, initialCmds ) =
                    recordContentsRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , qargs = qargs
                        , route = route
                        , session = session
                        }
            in
            ( SourcePage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        SourceHoldingsPageRoute _ _ ->
            let
                ( initialBody, initialCmds ) =
                    recordHoldingsRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , route = route
                        , session = session
                        }
            in
            ( HoldingPage session initialBody, initialCmds )

        PersonPageRoute _ ->
            let
                ( initialBody, initialCmds ) =
                    recordRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , route = route
                        , session = session
                        }
            in
            ( PersonPage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        PersonSourcePageRoute _ qargs ->
            let
                ( initialBody, initialCmds ) =
                    recordContentsRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , qargs = qargs
                        , route = route
                        , session = session
                        }
            in
            ( PersonPage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        InstitutionPageRoute _ ->
            let
                ( initialBody, initialCmds ) =
                    recordRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , route = route
                        , session = session
                        }
            in
            ( InstitutionPage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        InstitutionSourcePageRoute _ qargs ->
            let
                ( initialBody, initialCmds ) =
                    recordContentsRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , qargs = qargs
                        , route = route
                        , session = session
                        }
            in
            ( InstitutionPage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        PublicationPageRoute _ ->
            let
                ( initialBody, initialCmds ) =
                    recordRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , route = route
                        , session = session
                        }
            in
            ( PublicationPage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        PublicationWorksPageRoute _ qargs ->
            let
                ( initialBody, initialCmds ) =
                    recordContentsRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , qargs = qargs
                        , route = route
                        , session = session
                        }
            in
            ( PublicationPage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        PublicationsListPageRoute ->
            let
                ( initialBody, initialCmds ) =
                    recordRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , route = route
                        , session = session
                        }
            in
            ( PublicationListPage session initialBody
            , Cmd.batch
                [ initialCmds
                , countryListRequest
                ]
            )

        WorkPageRoute _ ->
            let
                ( initialBody, initialCmds ) =
                    recordRouteHelper
                        { initialData = flags.initialData
                        , initialUrl = initialUrl
                        , route = route
                        , session = session
                        }
            in
            ( WorkPage session initialBody
            , Cmd.batch
                [ initialCmds
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


recordRouteHelper :
    { initialData : Maybe Value
    , initialUrl : Url
    , route : Route
    , session : Session
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
recordRouteHelper { initialData, initialUrl, route, session } =
    let
        recordCfg =
            { incomingUrl = initialUrl
            , route = route
            , queryArgs = Nothing
            , nationalCollection = session.restrictedToNationalCollection
            , searchPreferences = session.searchPreferences
            , initialData = initialData
            }

        initialBody =
            Record.init recordCfg
                |> addNationalCollectionFilter session.restrictedToNationalCollection

        fetchInitialSourceResultsCmd =
            sourceFetchCmd initialBody initialUrl route

        fetchInitialRecordBodyCmd =
            case initialData of
                Just _ ->
                    Cmd.none

                Nothing ->
                    Record.recordPageRequest session.cacheBuster initialUrl
    in
    ( initialBody
    , Cmd.batch
        [ fetchInitialRecordBodyCmd
        , fetchInitialSourceResultsCmd
        ]
        |> Cmd.map Msg.UserInteractedWithRecordPage
    )


recordContentsRouteHelper :
    { initialData : Maybe Value
    , initialUrl : Url
    , qargs : QueryArgs
    , route : Route
    , session : Session
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
recordContentsRouteHelper { initialData, initialUrl, qargs, route, session } =
    let
        recordCfg =
            { incomingUrl = initialUrl
            , route = route
            , queryArgs = Just qargs
            , nationalCollection = session.restrictedToNationalCollection
            , searchPreferences = session.searchPreferences
            , initialData = initialData
            }

        initialBody =
            Record.init recordCfg
                |> addNationalCollectionFilter session.restrictedToNationalCollection

        fetchInitialContentsResultsCmd =
            case initialData of
                Just _ ->
                    Cmd.none

                Nothing ->
                    sourceFetchCmd initialBody initialUrl route

        recordUrl =
            { initialUrl | path = baseRecordPathFromRoute route }
    in
    ( initialBody
    , Cmd.batch
        [ Record.recordPageRequest session.cacheBuster recordUrl
        , fetchInitialContentsResultsCmd
        , Record.requestPreviewIfSelected initialBody.selectedResult
        ]
        |> Cmd.map Msg.UserInteractedWithRecordPage
    )


recordHoldingsRouteHelper :
    { initialData : Maybe Value
    , initialUrl : Url
    , route : Route
    , session : Session
    }
    -> ( RecordPageModel RecordMsg, Cmd Msg )
recordHoldingsRouteHelper { initialData, initialUrl, route, session } =
    let
        recordCfg =
            { incomingUrl = initialUrl
            , route = route
            , queryArgs = Nothing
            , nationalCollection = session.restrictedToNationalCollection
            , searchPreferences = session.searchPreferences
            , initialData = initialData
            }

        initialBody =
            Record.init recordCfg
                |> addNationalCollectionFilter session.restrictedToNationalCollection
    in
    ( initialBody
    , Record.recordPageRequest session.cacheBuster initialUrl
        |> Cmd.map Msg.UserInteractedWithRecordPage
    )
