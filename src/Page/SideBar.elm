module Page.SideBar exposing (..)

import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer
import Language exposing (parseLocaleToLanguage)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.Request exposing (createCountryCodeRequestWithDecoder)
import Page.SideBar.Msg exposing (SideBarMsg(..), SideBarOption(..), sideBarOptionToModeString)
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import Request exposing (serverUrl)
import Session exposing (Session, SideBarAnimationStatus(..))
import Url.Builder


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
    serverUrl [ "/" ] <| modeParameter :: ncParameter


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

        UserMouseExitedSideBarOption _ ->
            ( { session
                | currentlyHoveredOption = Nothing
              }
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
                outMsg =
                    PortSendSetNationalCollectionSelection countryCode

                requestUrl =
                    buildFrontPageUrl session.showFrontSearchInterface countryCode
            in
            ( { session
                | restrictedToNationalCollection = countryCode

                -- reset the user interface to the source search option to avoid getting stuck on the
                -- people or incipits interface when a national collection is chosen.
                , showFrontSearchInterface = SourceSearchOption
              }
            , Cmd.batch
                [ encodeMessageForPortSend outMsg
                    |> sendOutgoingMessageOnPort
                , Nav.pushUrl session.key requestUrl
                ]
            )

        UserChangedLanguageSelect lang ->
            let
                outMsg =
                    PortSendSaveLanguagePreference lang
            in
            ( { session
                | language = parseLocaleToLanguage lang
              }
            , encodeMessageForPortSend outMsg
                |> sendOutgoingMessageOnPort
            )
