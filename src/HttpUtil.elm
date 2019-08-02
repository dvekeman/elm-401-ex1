module HttpUtil exposing (errorToString)

import Http

errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadUrl url ->
            "Bad URL " ++ url

        Http.BadStatus status ->
            "Bad Status " ++ String.fromInt status

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network Error"

        Http.BadBody body ->
            "Bad body: " ++ body

