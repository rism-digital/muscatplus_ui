module Page.SideBar exposing (Msg, countryListRequest, update)

import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer exposing (UpdateConfig)
import Page.NavigationBar exposing (NavigationBar(..))
import Page.Query exposing (buildFrontPageUrl)
import Page.Request exposing (createCountryCodeRequestWithDecoder)
import Page.Route exposing (routeToResultMode)
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..))
import Page.SideBar.Options exposing (SideBarOptions, updateCurrentlyHoveredAboutMenuSidebarOption, updateCurrentlyHoveredLanguageChooserSidebarOption, updateCurrentlyHoveredNationalCollectionSidebarOption, updateCurrentlyHoveredNationalCollectionStatus, updateCurrentlyHoveredStatus, updateExpansionStatus, updateNationalCollectionChooserDebouncer, updateSideBarExpansionDebouncer)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Session exposing (Session, updateSideBarOptions)


type alias Msg =
    SideBarMsg


countryListRequest : Cmd SideBarMsg
countryListRequest =
    createCountryCodeRequestWithDecoder ServerRespondedWithCountryCodeList


update : SideBarMsg -> Session -> ( Session, Cmd SideBarMsg )
update msg session =
    case msg of
        ServerRespondedWithCountryCodeList (Ok ( _, response )) ->
            ( { session
                | allNationalCollections = response
              }
            , Cmd.none
            )

        ServerRespondedWithCountryCodeList (Err _) ->
            ( session, Cmd.none )

        ClientDebouncedSideBarMessages subMsg ->
            --( session, Cmd.none )
            case session.navigationBar of
                SideBar options ->
                    Debouncer.update update (updateDebouncer options) subMsg session

                BottomBar _ ->
                    ( session, Cmd.none )

        ClientDebouncedNationalCollectionChooserMessages subMsg ->
            case session.navigationBar of
                SideBar options ->
                    Debouncer.update update (ncDebouncer options) subMsg session

                BottomBar _ ->
                    ( session, Cmd.none )

        ClientSetSearchPreferencesThroughPort preferences ->
            ( { session
                | searchPreferences = Just preferences
              }
            , Cmd.none
            )

        UserMouseEnteredSideBar ->
            ( updateExpansionStatus Expanded
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseExitedSideBar ->
            ( updateExpansionStatus Collapsed
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserClickedSideBarOptionForFrontPage resultMode ->
            ( session
            , buildFrontPageUrl resultMode session.restrictedToNationalCollection
                |> Nav.pushUrl session.key
            )

        UserMouseEnteredSideBarOption button ->
            ( updateCurrentlyHoveredStatus (Just button)
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseExitedSideBarOption ->
            ( updateCurrentlyHoveredStatus Nothing
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseEnteredCountryChooser ->
            ( updateCurrentlyHoveredNationalCollectionStatus True
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseExitedCountryChooser ->
            ( updateCurrentlyHoveredNationalCollectionStatus False
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseEnteredNationalCollectionSidebarOption ->
            ( updateCurrentlyHoveredNationalCollectionSidebarOption True
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseExitedNationalCollectionSidebarOption ->
            ( updateCurrentlyHoveredNationalCollectionSidebarOption False
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseEnteredAboutMenuSidebarOption ->
            ( updateCurrentlyHoveredAboutMenuSidebarOption True
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseExitedAboutMenuSidebarOption ->
            ( updateCurrentlyHoveredAboutMenuSidebarOption False
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseEnteredLanguageChooserSidebarOption ->
            ( updateCurrentlyHoveredLanguageChooserSidebarOption True
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserMouseExitedLanguageChooserSidebarOption ->
            ( updateCurrentlyHoveredLanguageChooserSidebarOption False
                |> updateSideBarOptions session
            , Cmd.none
            )

        UserChoseNationalCollection countryCode ->
            ( { session
                | restrictedToNationalCollection = countryCode
              }
            , Cmd.batch
                [ PortSendSetNationalCollectionSelection countryCode
                    |> encodeMessageForPortSend
                    |> sendOutgoingMessageOnPort
                , buildFrontPageUrl (routeToResultMode session.route) countryCode
                    |> Nav.pushUrl session.key
                ]
            )

        UserChoseLanguage lang ->
            ( { session
                | language = lang
              }
            , PortSendSaveLanguagePreference lang
                |> encodeMessageForPortSend
                |> sendOutgoingMessageOnPort
            )

        ClientUpdatedMuscatLinks newValue ->
            ( { session
                | showMuscatLinks = newValue
              }
            , Cmd.none
            )


updateDebouncer : SideBarOptions -> UpdateConfig SideBarMsg Session
updateDebouncer options =
    let
        setter debounceMsg model =
            updateSideBarExpansionDebouncer debounceMsg
                |> updateSideBarOptions model
    in
    { mapMsg = ClientDebouncedSideBarMessages
    , getDebouncer = \_ -> options.sideBarExpansionDebouncer
    , setDebouncer = setter
    }


ncDebouncer : SideBarOptions -> UpdateConfig SideBarMsg Session
ncDebouncer options =
    let
        setter debounceMsg model =
            updateNationalCollectionChooserDebouncer debounceMsg
                |> updateSideBarOptions model
    in
    { mapMsg = ClientDebouncedNationalCollectionChooserMessages
    , getDebouncer = \_ -> options.nationalCollectionChooserDebouncer
    , setDebouncer = setter
    }
