module Api.Api exposing (createCollabRequest, getCollabRequest, getCollabRequestWithOwner, getCollabRequests, getCurrentUser, inviteCollab, login, logout, register, updateAccount)

{-| This module contains the `Cmd.Cmd`s to access API routes.
-}

import Account
import Api.Core as Core
import Api.Endpoint as Endpoint
import Api.Errors.Form as FormError
import Api.Errors.GetCurrentUser as GetCurrentUserError
import Api.Errors.Unknown as UnknownError
import CollabRequest exposing (CollabRequestData)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
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



-- CREATE COLLAB REQUEST


{-| Upon success get the ID of the newly created collab request.
-}
createCollabRequest : CollabRequestData -> (Result.Result (Core.HttpError FormError.Error) String -> msg) -> Cmd.Cmd msg
createCollabRequest collabRequestData handleResult =
    Core.post
        Endpoint.collabRequests
        standardTimeout
        Nothing
        (Http.jsonBody <| CollabRequest.encode collabRequestData)
        (Core.expectJson handleResult (Decode.field "collabRequestId" Decode.string) FormError.decoder)



-- GET COLLAB REQUEST


getCollabRequest :
    String
    -> (Result.Result (Core.HttpError UnknownError.Error) CollabRequest.CollabRequest -> msg)
    -> Cmd.Cmd msg
getCollabRequest collabRequestId handleResult =
    Core.get
        (Endpoint.collabRequest collabRequestId False)
        standardTimeout
        Nothing
        (Core.expectJson handleResult CollabRequest.decoder UnknownError.decoder)


getCollabRequestWithOwner :
    String
    -> (Result.Result (Core.HttpError UnknownError.Error) CollabRequest.CollabRequestWithOwner -> msg)
    -> Cmd.Cmd msg
getCollabRequestWithOwner collabRequestId handleResult =
    Core.get
        (Endpoint.collabRequest collabRequestId True)
        standardTimeout
        Nothing
        (Core.expectJson handleResult CollabRequest.collabRequestWithOwnerDecoder UnknownError.decoder)


{-| Gets a users collab-requests.
-}
getCollabRequests :
    (Result.Result (Core.HttpError UnknownError.Error) (List CollabRequest.CollabRequest) -> msg)
    -> Cmd.Cmd msg
getCollabRequests handleResult =
    Core.get
        Endpoint.collabRequests
        standardTimeout
        Nothing
        (Core.expectJson handleResult (Decode.list CollabRequest.decoder) UnknownError.decoder)



-- INVITE A COLLAB


{-| Invite a collab to an open collab-request.
-}
inviteCollab : String -> String -> (Result.Result (Core.HttpError FormError.Error) () -> msg) -> Cmd.Cmd msg
inviteCollab collabRequestId invitedCollabEmail handleResult =
    Core.post
        (Endpoint.collabRequestInvites collabRequestId)
        standardTimeout
        Nothing
        (Http.jsonBody <| Encode.object [ ( "invitedCollabEmail", Encode.string invitedCollabEmail ) ])
        (Core.expectJson handleResult (Decode.succeed ()) FormError.decoder)



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
