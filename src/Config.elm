module Config exposing (..)


serverUrl : String
serverUrl =
    "http://dev.rism.offline"


flagsPath : String
flagsPath =
    "/static/images/flags/"


minimumQueryLength : Int
minimumQueryLength =
    3


defaultRows : Int
defaultRows =
    20


muscatLinkBase : String
muscatLinkBase =
    "https://muscat.rism.info/admin/"


uiVersion : String
uiVersion =
    "development"
