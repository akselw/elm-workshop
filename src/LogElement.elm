module LogElement exposing (LogElement, encode, fromHttpError)

import Http
import Json.Encode


type LogElement
    = HttpError HttpErrorInfo


type alias HttpErrorInfo =
    { operation : String
    , errorType : String
    , extraInfo : Maybe String
    }


fromHttpError : String -> Http.Error -> Maybe LogElement
fromHttpError operation error =
    case error of
        Http.BadUrl message ->
            HttpError
                { operation = operation
                , errorType = "BadUrl"
                , extraInfo = Just message
                }
                |> Just

        Http.Timeout ->
            HttpError
                { operation = operation
                , errorType = "Timeout"
                , extraInfo = Nothing
                }
                |> Just

        Http.NetworkError ->
            Nothing

        Http.BadStatus statusCode ->
            HttpError
                { operation = operation
                , errorType = "BadStatus"
                , extraInfo =
                    statusCode
                        |> String.fromInt
                        |> Just
                }
                |> Just

        Http.BadBody message ->
            HttpError
                { operation = operation
                , errorType = "BadBody"
                , extraInfo = Just message
                }
                |> Just



--- ENCODING ---


encode : LogElement -> Json.Encode.Value
encode logElement =
    case logElement of
        HttpError info ->
            Json.Encode.object
                [ ( "operasjon", Json.Encode.string info.operation )
                , ( "errorType", Json.Encode.string info.errorType )
                , ( "message"
                  , info
                        |> messageFromHttpError
                        |> Json.Encode.string
                  )
                ]


messageFromHttpError : HttpErrorInfo -> String
messageFromHttpError info =
    case info.extraInfo of
        Just extraInfo ->
            info.errorType ++ " " ++ extraInfo ++ " on operation \"" ++ info.operation ++ "\""

        Nothing ->
            info.errorType ++ " on operation \"" ++ info.operation ++ "\""
