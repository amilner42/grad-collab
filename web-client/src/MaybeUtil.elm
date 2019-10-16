module MaybeUtil exposing (isJust, isNothing, mapWithDefault)


isNothing : Maybe a -> Bool
isNothing =
    (==) Nothing


isJust : Maybe a -> Bool
isJust =
    isNothing >> not


mapWithDefault : b -> (a -> b) -> Maybe a -> b
mapWithDefault default func maybeVal =
    Maybe.map func maybeVal
        |> Maybe.withDefault default
