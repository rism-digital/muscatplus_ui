module Page.SideBar exposing (..)

import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer
import Json.Encode as Encode
import Language exposing (parseLocaleToLanguage)
import Page.Request exposing (createCountryCodeRequestWithDecoder)
import Page.SideBar.Msg exposing (SideBarMsg(..))
import Ports.LocalStorage exposing (saveLanguagePreference, saveNationalCollectionSelection)
import Session exposing (Session, SideBarAnimationStatus(..))


type alias Msg =
    SideBarMsg


countryListRequest : Cmd SideBarMsg
countryListRequest =
    createCountryCodeRequestWithDecoder ServerRespondedWithCountryCodeList


updateDebouncer : Debouncer.UpdateConfig SideBarMsg Session
updateDebouncer =
    { mapMsg = ClientDebouncedSideBarMessages
    , getDebouncer = .sideBarExpansionDebouncer
    , setDebouncer = \debouncer s -> { s | sideBarExpansionDebouncer = debouncer }
    }


update : SideBarMsg -> Session -> ( Session, Cmd SideBarMsg )
update msg session =
    case msg of
        ServerRespondedWithCountryCodeList (Ok ( _, response )) ->
            ( { session
                | allNationalCollections = response
              }
            , Cmd.none
            )

        ServerRespondedWithCountryCodeList (Err error) ->
            ( session, Cmd.none )

        ClientDebouncedSideBarMessages subMsg ->
            Debouncer.update update updateDebouncer subMsg session

        UserMouseEnteredSideBar ->
            ( { session
                | expandedSideBar = Expanding
              }
            , Cmd.none
            )

        UserMouseExitedSideBar ->
            ( { session
                | expandedSideBar = Collapsing
              }
            , Cmd.none
            )

        UserMouseEnteredSideBarOption button ->
            ( { session
                | currentlyHoveredOption = Just button
              }
            , Cmd.none
            )

        UserMouseExitedSideBarOption button ->
            ( { session
                | currentlyHoveredOption = Nothing
              }
            , Cmd.none
            )

        UserClickedSideBarOptionForFrontPage sidebarOption ->
            ( { session
                | showFrontSearchInterface = sidebarOption
              }
            , Nav.pushUrl session.key "/"
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

        UserChoseNationalCollection countryCode ->
            let
                encodedSelection =
                    case countryCode of
                        Just c ->
                            Encode.string c

                        Nothing ->
                            Encode.null
            in
            ( { session
                | restrictedToNationalCollection = countryCode
              }
            , saveNationalCollectionSelection encodedSelection
            )

        UserChangedLanguageSelect lang ->
            let
                encodedLang =
                    Encode.string lang
            in
            ( { session
                | language = parseLocaleToLanguage lang
              }
            , saveLanguagePreference encodedLang
            )
