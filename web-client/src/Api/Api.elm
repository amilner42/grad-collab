module Api.Api exposing (createTaskRequest, getCurrentUser, getTaskRequest, getTaskRequestWithOwner, getTaskRequests, login, logout, register, updateAccount)

{-| This module contains the `Cmd.Cmd`s to access API routes.
-}

import Account
import Api.Core as Core
import Api.Endpoint as Endpoint
import Api.Errors.Form as FormError
import Api.Errors.GetCurrentUser as GetCurrentUserError
import Api.Errors.Unknown as UnknownError
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import TaskRequest exposing (TaskRequestData)
import User exposing (User)


standardTimeout =
    Just (seconds 10)



-- GET CURRENT LOGGED IN USER


getCurrentUser : (Result.Result (Core.HttpError GetCurrentUserError.Error) User -> msg) -> Cmd.Cmd msg
getCurrentUser handleResult =
    Core.get
        Endpoint.me
        standardTimeout
        Nothing
        (Core.expectJson handleResult User.decoder GetCurrentUserError.decoder)



-- LOGIN


type alias LoginBody =
    { email : String, password : String }


login : LoginBody -> (Result.Result (Core.HttpError FormError.Error) User -> msg) -> Cmd.Cmd msg
login { email, password } handleResult =
    let
        encodedLoginData =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]

        body =
            Http.jsonBody encodedLoginData
    in
    Core.post
        Endpoint.login
        (Just (seconds 10))
        Nothing
        body
        (Core.expectJson handleResult User.decoder FormError.decoder)



-- REGISTER


type alias RegisterBody =
    { email : String, password : String }


register : RegisterBody -> (Result.Result (Core.HttpError FormError.Error) User -> msg) -> Cmd.Cmd msg
register { email, password } handleResult =
    let
        encodedUserRegisterData =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "password", Encode.string password )
                ]

        body =
            Http.jsonBody encodedUserRegisterData
    in
    Core.post
        Endpoint.users
        standardTimeout
        Nothing
        body
        (Core.expectJson handleResult User.decoder FormError.decoder)



-- LOGOUT


logout : (Result.Result (Core.HttpError UnknownError.Error) () -> msg) -> Cmd.Cmd msg
logout handleResult =
    Core.post
        Endpoint.logout
        standardTimeout
        Nothing
        Http.emptyBody
        (Core.expectJson handleResult (Decode.succeed ()) UnknownError.decoder)



-- CREATE TASK REQUEST


{-| Upon success get the ID of the newly created task request.
-}
createTaskRequest : TaskRequestData -> (Result.Result (Core.HttpError FormError.Error) String -> msg) -> Cmd.Cmd msg
createTaskRequest taskRequestData handleResult =
    Core.post
        Endpoint.taskRequests
        standardTimeout
        Nothing
        (Http.jsonBody <| TaskRequest.encode taskRequestData)
        (Core.expectJson handleResult (Decode.field "taskRequestId" Decode.string) FormError.decoder)



-- GET TASK REQUEST


getTaskRequest :
    String
    -> (Result.Result (Core.HttpError UnknownError.Error) TaskRequest.TaskRequest -> msg)
    -> Cmd.Cmd msg
getTaskRequest taskRequestId handleResult =
    Core.get
        (Endpoint.taskRequest taskRequestId False)
        standardTimeout
        Nothing
        (Core.expectJson handleResult TaskRequest.decoder UnknownError.decoder)


getTaskRequestWithOwner :
    String
    -> (Result.Result (Core.HttpError UnknownError.Error) TaskRequest.TaskRequestWithOwner -> msg)
    -> Cmd.Cmd msg
getTaskRequestWithOwner taskRequestId handleResult =
    Core.get
        (Endpoint.taskRequest taskRequestId True)
        standardTimeout
        Nothing
        (Core.expectJson handleResult TaskRequest.taskRequestWithOwnerDecoder UnknownError.decoder)


{-| Gets a users task-requests.
-}
getTaskRequests :
    (Result.Result (Core.HttpError UnknownError.Error) (List TaskRequest.TaskRequest) -> msg)
    -> Cmd.Cmd msg
getTaskRequests handleResult =
    Core.get
        Endpoint.taskRequests
        standardTimeout
        Nothing
        (Core.expectJson handleResult (Decode.list TaskRequest.decoder) UnknownError.decoder)



-- UPDATE AN ACCOUNT


updateAccount :
    String
    -> Account.AccountData
    -> (Result.Result (Core.HttpError FormError.Error) () -> msg)
    -> Cmd.Cmd msg
updateAccount userId accountData handleResult =
    Core.patch
        (Endpoint.user userId)
        standardTimeout
        Nothing
        (Http.jsonBody <| Account.encode accountData)
        (Core.expectJson handleResult (Decode.succeed ()) FormError.decoder)



-- INTERNAL HELPERS


{-| Convert seconds to milliseconds.
-}
seconds : Float -> Float
seconds =
    (*) 1000
