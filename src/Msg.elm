module Msg exposing (Msg(..))

import Browser exposing (UrlRequest)
import Element exposing (Device)
import Http
import Page.Model exposing (CurrentRecordViewTab)
import Page.Query exposing (FacetBehaviour)
import Page.RecordTypes.Search exposing (FacetItem)
import Page.Response exposing (ServerData)
import Page.UI.Facets.RangeSlider as RangeSlider
import Url exposing (Url)


{-|

    Follows the convention on message names in this talk:
    https://www.youtube.com/watch?v=w6OVDBqergc

    Specifically, names should answer "What happened?" The three
    components of the message name are:

    1. What happened? (Action)
    2. Who did it? (Agent)
    3. Where/how? (Location, optional)

    The pattern is:

    [Agent][Action](Location)

    The types of Agent are:
     - User
     - Server
     - Client (for actions that are issued from the browser or the app)

    The types of Actions can be (but are not necessarily limited to):
      - Clicked
      - Resized
      - InputText
      - Hovered
      - Selected
      - Changed
      - Responded

    The Location is a concise description of the place in the application
    where the message was issued. This could be something like:

      - SearchButton
      - Window
      - Preview
      - Url

     Putting these together, we end up with messages like:

      - UserResizedWindow
      - ServerRespondedWithData
      - ServerRespondedWithPreview
      - UserChangedLanguageSelect
      - UserCheckedFacet
      - etc...

-}
type Msg
    = ServerRespondedWithData (Result Http.Error ServerData)
    | ServerRespondedWithPreview (Result Http.Error ServerData)
    | ServerRespondedWithPageSearch (Result Http.Error ServerData)
    | ClientChangedUrl Url
    | ClientJumpedToId
    | ClientResetViewport
    | UserClickedSearchSubmitButton
    | UserInputTextInQueryBox String
    | UserChangedLanguageSelect String
    | UserChangedFacetBehaviour FacetBehaviour
    | UserClickedFacetToggle String
    | UserClickedFacetItem String FacetItem Bool
    | UserClickedFacetExpand String
    | UserClickedModeItem String FacetItem Bool
    | UserMovedRangeSlider String RangeSlider.Msg
    | UserClickedToCItem String
    | UserClickedRecordViewTab CurrentRecordViewTab
    | UserClickedSearchResultForPreview String
    | UserClickedRecordViewTabPagination String
    | UserClickedPageSearchSubmitButton String
    | UserInputTextInPageQueryBox String
    | UserResizedWindow Device
    | UserRequestedUrlChange UrlRequest
    | UserClickedClosePreviewWindow
    | NothingHappened -- for stubbing out messages and development, a.k.a. 'NoOp'
