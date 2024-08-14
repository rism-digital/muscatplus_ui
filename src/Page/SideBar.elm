module Page.SideBar exposing (Msg, countryListRequest, update)

import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer
import Page.Query exposing (buildFrontPageUrl)
import Page.RecordTypes.Navigation exposing (NavigationBarOption(..))
import Page.Request exposing (createCountryCodeRequestWithDecoder)
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..))
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Session exposing (Session)


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
            Debouncer.update update updateDebouncer subMsg session

        ClientDebouncedNationalCollectionChooserMessages subMsg ->
            Debouncer.update update ncDebouncer subMsg session

        ClientSetSearchPreferencesThroughPort preferences ->
            ( { session
                | searchPreferences = Just preferences
              }
            , Cmd.none
            )

        UserMouseEnteredSideBar ->
            ( { session
                | expandedSideBar = Expanded
              }
            , Cmd.none
            )

        UserMouseExitedSideBar ->
            -- If the user is interacting with the language chooser, then do not set the
            -- state to collapsed. This is to fix a bug in Firefox where the select dropdown
            -- causes the sidebar to signal that it has lost mouse focus.
            ( { session
                | expandedSideBar = Collapsed
              }
            , Cmd.none
            )

        UserClickedSideBarOptionForFrontPage sidebarOption ->
            ( { session
                | showFrontSearchInterface = sidebarOption
              }
            , buildFrontPageUrl sidebarOption session.restrictedToNationalCollection
                |> Nav.pushUrl session.key
            )

        UserMouseEnteredSideBarOption button ->
            ( { session
                | currentlyHoveredOption = Just button
              }
            , Cmd.none
            )

        UserMouseExitedSideBarOption ->
            ( { session
                | currentlyHoveredOption = Nothing
              }
            , Cmd.none
            )

        UserMouseEnteredCountryChooser ->
            ( { session
                | currentlyHoveredNationalCollectionChooser = True
              }
            , Cmd.none
            )

        UserMouseExitedCountryChooser ->
            ( { session
                | currentlyHoveredNationalCollectionChooser = False
              }
            , Cmd.none
            )

        UserMouseEnteredNationalCollectionSidebarOption ->
            ( { session
                | currentlyHoveredNationalCollectionSidebarOption = True
              }
            , Cmd.none
            )

        UserMouseExitedNationalCollectionSidebarOption ->
            ( { session
                | currentlyHoveredNationalCollectionSidebarOption = False
              }
            , Cmd.none
            )

        UserMouseEnteredAboutMenuSidebarOption ->
            ( { session
                | currentlyHoveredAboutMenuSidebarOption = True
              }
            , Cmd.none
            )

        UserMouseExitedAboutMenuSidebarOption ->
            ( { session
                | currentlyHoveredAboutMenuSidebarOption = False
              }
            , Cmd.none
            )

        UserMouseEnteredLanguageChooserSidebarOption ->
            ( { session
                | currentlyHoveredLanguageChooserSidebarOption = True
              }
            , Cmd.none
            )

        UserMouseExitedLanguageChooserSidebarOption ->
            ( { session
                | currentlyHoveredLanguageChooserSidebarOption = False
              }
            , Cmd.none
            )

        UserChoseNationalCollection countryCode ->
            ( { session
                | showFrontSearchInterface = SourceSearchOption
                , restrictedToNationalCollection = countryCode

                -- reset the user interface to the source search option to avoid getting stuck on the
                -- people or incipits interface when a national collection is chosen.
              }
            , Cmd.batch
                [ PortSendSetNationalCollectionSelection countryCode
                    |> encodeMessageForPortSend
                    |> sendOutgoingMessageOnPort
                , buildFrontPageUrl session.showFrontSearchInterface countryCode
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

        NothingHappened ->
            ( session, Cmd.none )


updateDebouncer : Debouncer.UpdateConfig SideBarMsg Session
updateDebouncer =
    { mapMsg = ClientDebouncedSideBarMessages
    , getDebouncer = .sideBarExpansionDebouncer
    , setDebouncer = \debouncer s -> { s | sideBarExpansionDebouncer = debouncer }
    }


ncDebouncer : Debouncer.UpdateConfig SideBarMsg Session
ncDebouncer =
    { mapMsg = ClientDebouncedNationalCollectionChooserMessages
    , getDebouncer = .nationalCollectionChooserDebouncer
    , setDebouncer = \debouncer s -> { s | nationalCollectionChooserDebouncer = debouncer }
    }
