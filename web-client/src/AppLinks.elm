module AppLinks exposing (linkToBrowseTaskRequest)

import Route


linkToBrowseTaskRequest : String -> String
linkToBrowseTaskRequest taskRequestId =
    linkTo <| Route.routeToString <| Route.BrowseTaskRequest taskRequestId


linkTo : String -> String
linkTo suffix =
    "__WEBPACK_CONSTANT_WEB_BASE_URL__" ++ "/" ++ suffix
