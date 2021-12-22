module Msg exposing (Msg(..))

import Browser exposing (UrlRequest)
import Element exposing (Device)
import Page.Front as Front
import Page.NotFound as NotFound
import Page.Record as Record
import Page.Search as Search
import Page.SideBar as SideBar
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
    = ClientChangedUrl Url
    | UserRequestedUrlChange UrlRequest
    | UserResizedWindow Device
    | UserInteractedWithFrontPage Front.Msg
    | UserInteractedWithSearchPage Search.Msg
    | UserInteractedWithRecordPage Record.Msg
    | UserInteractedWithNotFoundPage NotFound.Msg
    | UserInteractedWithSideBar SideBar.Msg
    | NothingHappened -- for stubbing out messages and development, a.k.a. 'NoOp'
