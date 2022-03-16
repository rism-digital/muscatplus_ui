module SearchPreferences.SetPreferences exposing (..)


type SearchPreferenceVariant
    = StringPreference String
    | ListPreference (List String)
