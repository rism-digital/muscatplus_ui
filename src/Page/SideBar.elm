module Page.SideBar exposing (..)

import Browser.Navigation as Nav
import Language exposing (parseLocaleToLanguage)
import Page.Request exposing (createCountryCodeRequestWithDecoder)
import Page.SideBar.Msg exposing (SideBarMsg(..))
import Ports.LocalStorage exposing (saveLanguagePreference)
import Session exposing (Session, SideBarAnimationStatus(..))


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

        ServerRespondedWithCountryCodeList (Err error) ->
            ( session, Cmd.none )

        UserMouseEnteredSideBar ->
            ( { session | expandedSideBar = Expanding }, Cmd.none )

        UserMouseExitedSideBar ->
            ( { session | expandedSideBar = Collapsing }, Cmd.none )

        UserMouseEnteredSideBarOption button ->
            ( { session | currentlyHoveredOption = Just button }, Cmd.none )

        UserMouseExitedSideBarOption button ->
            ( { session | currentlyHoveredOption = Nothing }, Cmd.none )

        UserClickedSideBarOptionForFrontPage sidebarOption ->
            ( { session | showFrontSearchInterface = sidebarOption }
            , Nav.pushUrl session.key "/"
            )

        UserMouseEnteredCountryChooser ->
            ( { session | currentlyHoveredNationalCollectionChooser = True }, Cmd.none )

        UserMouseExitedCountryChooser ->
            ( { session | currentlyHoveredNationalCollectionChooser = False }, Cmd.none )

        UserChoseNationalCollection countryCode ->
            ( { session | restrictedToNationalCollection = countryCode }, Cmd.none )

        UserChangedLanguageSelect lang ->
            ( { session | language = parseLocaleToLanguage lang }
            , saveLanguagePreference lang
            )
