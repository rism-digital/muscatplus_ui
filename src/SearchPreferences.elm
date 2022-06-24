module SearchPreferences exposing (SearchPreferences, searchPreferencesDecoder)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Ports.Outgoing exposing (OutgoingMessage(..), encodeMessageForPortSend, sendOutgoingMessageOnPort)
import SearchPreferences.SetPreferences exposing (SearchPreferenceVariant)
import Set exposing (Set)


{-|

    Search Preferences are set in a round-about way, so as to avoid
    needing to keep bits of state in different places, with different
    routes updating it. They represent preferences that are stored in
    local storage that we wish to persist across page loads, so the local storage is, effectively
    the "source of truth" for this data.

    Preferences are stored in the `Session` for the site. When a user performs an action
    that triggers a save to the search preferences (e.g., expands a facet panel) then
    the calling page (a search page, the front page, or a record page) will trigger a save
    to the browser's local storage with the new bit of state they wish to update. This will
    send it off to the local storage, which will handle the save.

    THEN, importantly, the port will send back the resulting preferences object from the
    browser's local storage. The incoming port handler will decode the data back from
    localstorage and then set the new values on the Session object.

-}
type alias SearchPreferences =
    { expandedFacetPanels : Set String
    }


defaultPreferences : SearchPreferences
defaultPreferences =
    { expandedFacetPanels = Set.empty
    }


encodeSearchPreferences : SearchPreferences -> Encode.Value
encodeSearchPreferences prefs =
    Encode.object
        [ ( "expandedFacetPanels", Encode.list (\a -> Encode.string a) (Set.toList prefs.expandedFacetPanels) )
        ]


saveSearchPreference : { key : String, value : SearchPreferenceVariant } -> Cmd msg
saveSearchPreference pref =
    encodeMessageForPortSend (PortSendSaveSearchPreference pref)
        |> sendOutgoingMessageOnPort


searchPreferencesDecoder : Decoder SearchPreferences
searchPreferencesDecoder =
    Decode.succeed SearchPreferences
        |> required "expandedFacetPanels" (list string |> Decode.andThen expandedFacetPanelDecoder)


expandedFacetPanelDecoder : List String -> Decoder (Set String)
expandedFacetPanelDecoder panelValues =
    Set.fromList panelValues
        |> Decode.succeed
