module Config exposing (defaultRows, flagsPath, minimumQueryLength, muscatLinkBase, serverUrl, uiVersion)


defaultRows : Int
defaultRows =
    20


flagsPath : String
flagsPath =
    "/static/images/flags/"


minimumQueryLength : Int
minimumQueryLength =
    3


muscatLinkBase : String
muscatLinkBase =
    "https://muscat.rism.info/admin/"


serverUrl : String
serverUrl =
    "http://dev.rism.offline"


uiVersion : String
uiVersion =
    "development"
