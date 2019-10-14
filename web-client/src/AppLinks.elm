module AppLinks exposing (linkToBrowseCollabRequest)

import Route


linkToBrowseCollabRequest : String -> String
linkToBrowseCollabRequest collabRequestId =
    linkTo <| Route.routeToString <| Route.BrowseCollabRequest collabRequestId


linkTo : String -> String
linkTo suffix =
    "__WEBPACK_CONSTANT_WEB_BASE_URL__" ++ "/" ++ suffix
