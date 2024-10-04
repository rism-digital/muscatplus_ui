module SearchPreferences.SetPreferences exposing (SearchPreferenceVariant(..))


type SearchPreferenceVariant
    = ListPreference (List String)
    | BoolPreference Bool
