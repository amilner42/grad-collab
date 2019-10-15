module Api.Endpoint exposing (Endpoint, TaskRequestQueryParams, login, logout, me, request, taskRequest, taskRequestEmptyQueryParams, taskRequests, user, users)

{-| This module defines the opaque `Endpoint` type and the `request` ability to make an http request to an endpoint.
-}

import Field
import Http
import ListUtil
import Url.Builder exposing (QueryParameter, int, string)


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


type alias TaskRequestQueryParams =
    { forUserId : Maybe String
    , researchField : Maybe Field.Field
    , fieldRequestingHelpFrom : Maybe Field.Field
    }


taskRequestEmptyQueryParams : TaskRequestQueryParams
taskRequestEmptyQueryParams =
    { forUserId = Nothing
    , researchField = Nothing
    , fieldRequestingHelpFrom = Nothing
    }


taskRequests : TaskRequestQueryParams -> Endpoint
taskRequests { forUserId, researchField, fieldRequestingHelpFrom } =
    url [ "task-requests" ] <|
        ListUtil.filterByMaybe
            [ ( forUserId, \val -> string "forUserId" val )
            , ( researchField |> Maybe.map Field.toString, \val -> string "researchField" val )
            , ( fieldRequestingHelpFrom |> Maybe.map Field.toString, \val -> string "fieldRequestingHelpFrom" val )
            ]


taskRequest : String -> Bool -> Endpoint
taskRequest taskRequestId withUser =
    url [ "task-requests", taskRequestId ]
        [ int "withUser" <|
            if withUser then
                1

            else
                0
        ]



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
