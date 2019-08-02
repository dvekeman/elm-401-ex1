module AuthMsg exposing (AuthFailure(..), withAuth)

import Http


{-| This function wraps a message with unauthenticated / unauthorized checks
-}
withAuth :
    (AuthFailure -> msg) -- ^ The message constructor in case of failure (unauthenticated | unauthorized)
    -> (authMsg -> msg) -- ^ The message constructor in case of success
    -> (Result Http.Error a -> authMsg) -- ^ The sub-message constructor
    -> Result Http.Error a -- ^ The HTTP result
    -> msg
withAuth failMsg successMsg toAuthMsg result =
    if isUnauthenticated result then
        failMsg Unauthenticated

    else if isUnauthorized result then
        failMsg Unauthorized

    else
        successMsg <| toAuthMsg result

type AuthFailure = Unauthenticated | Unauthorized

{-| Helper function to check if the HTTP response is a HTTP 401
-}
isUnauthenticated : Result Http.Error a -> Bool
isUnauthenticated =
    isStatus 401


{-| Helper function to check if the HTTP response is a HTTP 401
-}
isUnauthorized : Result Http.Error a -> Bool
isUnauthorized =
    isStatus 403


isStatus : Int -> Result Http.Error a -> Bool
isStatus status result =
    case result of
        Err error ->
            case error of
                Http.BadStatus httpStatus ->
                    status == httpStatus

                _ ->
                    False

        _ ->
            False
