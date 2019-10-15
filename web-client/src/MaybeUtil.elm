module MaybeUtil exposing (isJust, isNothing)


isNothing : Maybe a -> Bool
isNothing =
    (==) Nothing


isJust : Maybe a -> Bool
isJust =
    isNothing >> not
