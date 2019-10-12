module Viewer exposing (Viewer, decoder, getAccountData, getCred, getEmail, getId, setAccountData)

{-| The logged-in user currently viewing this page.
-}

import Account
import Api.Core as Core
import Json.Decode as Decode



-- TYPES


type Viewer
    = Viewer Account.AccountData Core.Cred



-- INFO


getCred : Viewer -> Core.Cred
getCred (Viewer _ cred) =
    cred


getEmail : Viewer -> String
getEmail (Viewer _ cred) =
    Core.getEmail cred


getAccountData : Viewer -> Account.AccountData
getAccountData (Viewer accountData _) =
    accountData


setAccountData : Account.AccountData -> Viewer -> Viewer
setAccountData accountData (Viewer _ cred) =
    Viewer accountData cred


getId : Viewer -> String
getId (Viewer _ cred) =
    Core.getId cred


decoder : Decode.Decoder (Core.Cred -> Viewer)
decoder =
    Decode.map Viewer Account.decoder
