module Api.Endpoint exposing (Endpoint, collabRequest, collabRequestInvites, collabRequests, login, logout, me, request, user, users)

{-| This module defines the opaque `Endpoint` type and the `request` ability to make an http request to an endpoint.
-}

import Http
import Url.Builder exposing (QueryParameter, int)


type Endpoint
    = Endpoint String


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Http.Body
    , expect : Http.Expect msg
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , endpoint : Endpoint
    , tracker : Maybe String
    }
    -> Cmd msg
request config =
    Http.riskyRequest
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = getEndpointUrl config.endpoint
        , tracker = config.tracker
        }


login : Endpoint
login =
    url [ "login" ] []


logout : Endpoint
logout =
    url [ "logout" ] []


me : Endpoint
me =
    url [ "me" ] []


users : Endpoint
users =
    url [ "users" ] []


user : String -> Endpoint
user userId =
    url [ "users", userId ] []


collabRequests : Endpoint
collabRequests =
    url [ "collab-requests" ] []


collabRequest : String -> Bool -> Endpoint
collabRequest collabRequestId withUser =
    url [ "collab-requests", collabRequestId ]
        [ int "withUser" <|
            if withUser then
                1

            else
                0
        ]


collabRequestInvites : String -> Endpoint
collabRequestInvites collabRequestId =
    url [ "collab-requests", collabRequestId, "invites" ] []



-- INTERNAL


getEndpointUrl : Endpoint -> String
getEndpointUrl (Endpoint str) =
    str


url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
    let
        -- Webpack will set this to the API base URL according to prod/dev mode
        apiBaseUrl =
            "__WEBPACK_CONSTANT_API_BASE_URL__"
    in
    Url.Builder.crossOrigin apiBaseUrl
        paths
        queryParams
        |> Endpoint
