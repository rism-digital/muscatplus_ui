module Language.Tooltips exposing (tooltips)

import Language exposing (Language(..), LanguageMap, LanguageValues(..))


tooltips :
    { diammProject : LanguageMap
    , associatedPlace : LanguageMap
    , city : LanguageMap
    , composerAuthor : LanguageMap
    , compositeVolume : LanguageMap
    , dateRange : LanguageMap
    , formatExtent : LanguageMap
    , gender : LanguageMap
    , hasDigitization : LanguageMap
    , hasIiif : LanguageMap
    , hasIncipits : LanguageMap
    , incipit : LanguageMap
    , institutionNumHoldings : LanguageMap
    , institutionSigla : LanguageMap
    , materialType : LanguageMap
    , otherPeople : LanguageMap
    , profession : LanguageMap
    , roles : LanguageMap
    , scoring : LanguageMap
    , sourceCollections : LanguageMap
    , sourceContents : LanguageMap
    , subjects : LanguageMap
    , textLanguage : LanguageMap
    }
tooltips =
    { diammProject =
        [ LanguageValues English englishHideDiammRecordsToggleTooltip ]
    , associatedPlace =
        [ LanguageValues English englishAssociatedPlaceTooltip ]
    , city =
        [ LanguageValues English englishCityTooltip ]
    , composerAuthor =
        [ LanguageValues English englishComposerRelationshipsTooltip
        , LanguageValues French frenchComposerRelationshipsTooltip
        ]
    , compositeVolume =
        [ LanguageValues English englishCompositeVolumeToggleTooltip ]
    , dateRange =
        [ LanguageValues English englishDateRangeTooltip ]
    , formatExtent =
        [ LanguageValues English englishFormatExtentTooltip ]
    , gender =
        [ LanguageValues English englishGenderTooltip ]
    , hasDigitization =
        [ LanguageValues English englishHasDigitizationToggleTooltip ]
    , hasIiif =
        [ LanguageValues English englishHasIiifToggleTooltip ]
    , hasIncipits =
        [ LanguageValues English englishHasIncipitsToggleTooltip ]
    , incipit =
        [ LanguageValues English englishIncipitSearchTooltip
        , LanguageValues French frenchIncipitSearchTooltip
        ]
    , institutionNumHoldings =
        [ LanguageValues English englishInstitutionNumHoldingsToggle ]
    , institutionSigla =
        [ LanguageValues English englishInstitutionSiglaTooltip ]
    , materialType =
        [ LanguageValues English englishMaterialTypeTooltip ]
    , otherPeople =
        [ LanguageValues English englishOtherPeopleRelationshipsTooltip ]
    , profession =
        [ LanguageValues English englishProfessionTooltip ]
    , roles =
        [ LanguageValues English englishRolesTooltip ]
    , scoring =
        [ LanguageValues English englishScoringTooltip ]
    , sourceCollections =
        [ LanguageValues English englishSourceCollectionsToggleTooltip ]
    , sourceContents =
        [ LanguageValues English englishSourceContentsToggleTooltip ]
    , subjects =
        [ LanguageValues English englishSubjectsTooltip ]
    , textLanguage =
        [ LanguageValues English englishTextLanguageTooltip ]
    }


englishHideDiammRecordsToggleTooltip : List String
englishHideDiammRecordsToggleTooltip =
    [ """Exclude search results that come from the DIAMM project.""" ]


englishCompositeVolumeToggleTooltip : List String
englishCompositeVolumeToggleTooltip =
    [ """Limit your results to sources that are not composite volumes.""" ]


englishSourceCollectionsToggleTooltip : List String
englishSourceCollectionsToggleTooltip =
    [ """Limit your results to sources that are not collection records. This will return
         sources that represent items in a collection, or single-item source records.""" ]


englishSourceContentsToggleTooltip : List String
englishSourceContentsToggleTooltip =
    [ """Limit your results to only source records that represent collection records or
         single-item sources. These are records that represent a physical volume in a library.""" ]


englishHasDigitizationToggleTooltip : List String
englishHasDigitizationToggleTooltip =
    [ """Limit your results to sources that have a digital image representation available.""" ]


englishHasIiifToggleTooltip : List String
englishHasIiifToggleTooltip =
    [ """Limit your results to sources that have a IIIF Manifest attached.""" ]


englishHasIncipitsToggleTooltip : List String
englishHasIncipitsToggleTooltip =
    [ """Limit your results to sources with incipit entries. Note that
         not all incipit entries have musical notation; some have minimal data or
         are text incipit only.""" ]


englishInstitutionSiglaTooltip : List String
englishInstitutionSiglaTooltip =
    [ """Search for sources using a RISM siglum. Wildcard queries are
         supported; for example "GB-O*". """ ]


englishInstitutionNumHoldingsToggle : List String
englishInstitutionNumHoldingsToggle =
    [ """The number of holdings for a given source across all institutions.
         For example, the value of "1" means that there is only one known extant
         copy of a source, while "More than 100" means that there are over 100 known
         copies. Applies only to printed sources.
    """ ]


englishComposerRelationshipsTooltip : List String
englishComposerRelationshipsTooltip =
    [ """The person who is assigned primary authorial responsibility. Source records
        have only one person assigned in this role; other people are listed as secondary
        relationships and can be found using the "Other people" facet lookup.""" ]


frenchComposerRelationshipsTooltip : List String
frenchComposerRelationshipsTooltip =
    [ "" ]


englishOtherPeopleRelationshipsTooltip : List String
englishOtherPeopleRelationshipsTooltip =
    [ """People related to a source in a non-authorial, secondary manner. This may include
        relationships such as a lyricist or librettist (in the case where the source is musical),
        former owners, dedicatees, or other roles.""" ]


englishSubjectsTooltip : List String
englishSubjectsTooltip =
    [ """Subjects used to classify or group a source.""" ]


englishMaterialTypeTooltip : List String
englishMaterialTypeTooltip =
    [ """The material type of a source.""" ]


englishDateRangeTooltip : List String
englishDateRangeTooltip =
    [ """A date range, in years. The date ranges are automatically extracted from 
         the date statement for a source or person, and represent the 
         likely lower and upper bounds of particular statement. If the
         statement, for example, is "second half of the 15th century", then
         the range would be 1450-1500. In some cases a date range cannot be
         inferred from a statement, and so will not be available for date
         range searching.
    """ ]


englishFormatExtentTooltip : List String
englishFormatExtentTooltip =
    [ """The format and extent of a source.""" ]


englishTextLanguageTooltip : List String
englishTextLanguageTooltip =
    [ """The language(s) of any musical texts in the source.""" ]


englishScoringTooltip : List String
englishScoringTooltip =
    [ """Terms drawn from the 'scoring' field for sources. The autocomplete will
         show the closest match to a known term, but wildcards are also supported.
         "vl*", for example, will show all sources with violin, regardless of the
          number ("vl (2)", "vl (3)", etc.).""" ]


englishGenderTooltip : List String
englishGenderTooltip =
    [ """The gender, where known or appropriate, of a person.""" ]


englishAssociatedPlaceTooltip : List String
englishAssociatedPlaceTooltip =
    [ """A place that has some association with a person or institution.""" ]


englishRolesTooltip : List String
englishRolesTooltip =
    [ """The roles that a person has in relation to a source.
         These are based on a subset of the MARC21 relator codes.
         The values shown are translated from the underlying relator code value.""" ]


englishProfessionTooltip : List String
englishProfessionTooltip =
    [ """A known profession, job, or organizational membership.
         These values come from the authority record for a person.""" ]


englishCityTooltip : List String
englishCityTooltip =
    [ """A city associated with an institution.""" ]


englishIncipitSearchTooltip : List String
englishIncipitSearchTooltip =
    [ """English incipit search tooltip""" ]


frenchIncipitSearchTooltip : List String
frenchIncipitSearchTooltip =
    []
