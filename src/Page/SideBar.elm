module Page.SideBar exposing (Msg, countryListRequest, update)

import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer
import Language exposing (parseLocaleToLanguage)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.Request exposing (createCountryCodeRequestWithDecoder)
import Page.SideBar.Msg exposing (SideBarAnimationStatus(..), SideBarMsg(..), SideBarOption(..), sideBarOptionToModeString)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Request exposing (serverUrl)
import Session exposing (Session)
import Url.Builder


type alias Msg =
    SideBarMsg


buildFrontPageUrl : SideBarOption -> Maybe CountryCode -> String
buildFrontPageUrl sidebarOption countryCode =
    let
        modeParameter =
            sideBarOptionToModeString sidebarOption
                |> Url.Builder.string "mode"

        -- Omits the parameter if the country code is Nothing by filtering it from a list.
        ncParameter =
            List.filterMap identity [ countryCode ]
                |> List.map (\c -> Url.Builder.string "nc" c)
    in
    serverUrl [ "/" ] (modeParameter :: ncParameter)


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
            let
                -- If the user is interacting with the language chooser, then do not set the
                -- state to collapsed. This is to fix a bug in Firefox where the select dropdown
                -- causes the sidebar to signal that it has lost mouse focus.
                newSession =
                    if session.currentlyInteractingWithLanguageChooser then
                        session

                    else
                        { session
                            | expandedSideBar = Collapsed
                        }
            in
            ( newSession
            , Cmd.none
            )

        UserClickedSideBarOptionForFrontPage sidebarOption ->
            let
                requestUrl =
                    buildFrontPageUrl sidebarOption session.restrictedToNationalCollection
            in
            ( { session
                | showFrontSearchInterface = sidebarOption
              }
            , Nav.pushUrl session.key requestUrl
            )

        UserMouseEnteredSideBarOption button ->
            ( { session
                | currentlyHoveredOption = Just button
              }
            , Cmd.none
            )

        UserMouseExitedSideBarOption _ ->
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

        UserMouseDownOnLanguageChooser ->
            ( { session
                | currentlyInteractingWithLanguageChooser = True
              }
            , Cmd.none
            )

        UserMouseUpOnLanguageChooser ->
            ( { session
                | currentlyInteractingWithLanguageChooser = False
              }
            , Cmd.none
            )

        UserChoseNationalCollection countryCode ->
            let
                outMsg =
                    PortSendSetNationalCollectionSelection countryCode

                requestUrl =
                    buildFrontPageUrl session.showFrontSearchInterface countryCode
            in
            ( { session
                | showFrontSearchInterface = SourceSearchOption
                , restrictedToNationalCollection = countryCode

                -- reset the user interface to the source search option to avoid getting stuck on the
                -- people or incipits interface when a national collection is chosen.
              }
            , Cmd.batch
                [ encodeMessageForPortSend outMsg
                    |> sendOutgoingMessageOnPort
                , Nav.pushUrl session.key requestUrl
                ]
            )

        UserChangedLanguageSelect lang ->
            ( { session
                | language = parseLocaleToLanguage lang
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
