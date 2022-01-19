module Page.SideBar exposing (..)

import Browser.Navigation as Nav
import Debouncer.Messages as Debouncer
import Json.Encode as Encode
import Language exposing (parseLocaleToLanguage)
import Page.RecordTypes.Countries exposing (CountryCode)
import Page.Request exposing (createCountryCodeRequestWithDecoder)
import Page.SideBar.Msg exposing (SideBarMsg(..), SideBarOption, sideBarOptionToModeString)
import Ports.LocalStorage exposing (saveLanguagePreference, saveNationalCollectionSelection)
import Request exposing (serverUrl)
import Session exposing (Session, SideBarAnimationStatus(..))
import Url.Builder exposing (QueryParameter(..))


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
                -- TODO: Change this to trigger a reload of the facets from the
                --     server so we get the values that are good for the national
                --     collection that they are searching on.
                encodedSelection =
                    case countryCode of
                        Just c ->
                            Encode.string c

                        Nothing ->
                            Encode.null

                requestUrl =
                    buildFrontPageUrl session.showFrontSearchInterface countryCode
            in
            ( { session
                | restrictedToNationalCollection = countryCode
              }
            , Cmd.batch
                [ saveNationalCollectionSelection encodedSelection
                , Nav.pushUrl session.key requestUrl
                ]
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
