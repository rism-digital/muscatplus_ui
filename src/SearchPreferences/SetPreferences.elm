module SearchPreferences.SetPreferences exposing (SearchPreferenceVariant(..))


type SearchPreferenceVariant
    = StringPreference String
    | ListPreference (List String)
    | BoolPreference Bool
