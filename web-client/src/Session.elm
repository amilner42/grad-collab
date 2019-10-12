module Session exposing (Session(..), navKey, user)

{-| A session contains a `Nav.Key` and a `User.User` if you are logged-in.
-}

import Browser.Navigation as Nav
import User exposing (User)


type Session
    = LoggedIn Nav.Key User
    | Guest Nav.Key


user : Session -> Maybe User
user session =
    case session of
        LoggedIn _ theUser ->
            Just theUser

        Guest _ ->
            Nothing


navKey : Session -> Nav.Key
navKey session =
    case session of
        LoggedIn key _ ->
            key

        Guest key ->
            key
