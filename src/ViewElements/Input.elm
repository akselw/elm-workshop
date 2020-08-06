module ViewElements.Input exposing (Input, input, toHtml, withErrorMessage, withOnBlur)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (ariaLive, role)
import Html.Events exposing (onBlur, onInput)


type Input msg
    = Input
        { onInput : String -> msg
        , value : String
        , label : String
        , errorMessage : Maybe String
        , onBlur : Maybe msg
        }


input : { label : String, onInput : String -> msg } -> String -> Input msg
input { label, onInput } value =
    Input
        { onInput = onInput
        , value = value
        , label = label
        , errorMessage = Nothing
        , onBlur = Nothing
        }



--- OPTIONS ---


withErrorMessage : Maybe String -> Input msg -> Input msg
withErrorMessage errorMessage (Input options) =
    Input { options | errorMessage = errorMessage }


withOnBlur : msg -> Input msg -> Input msg
withOnBlur msg (Input options) =
    Input { options | onBlur = Just msg }



--- HTML ---


toHtml : Input msg -> Html msg
toHtml (Input options) =
    div [ class "form-element" ]
        [ label [ class "label" ]
            [ span [ class "label-text" ] [ text options.label ]
            , Html.input
                [ class "input"
                , classList [ ( "error", options.errorMessage /= Nothing ) ]
                , value options.value
                , onInput options.onInput
                , options.onBlur
                    |> Maybe.map onBlur
                    |> Maybe.withDefault noAttribute
                ]
                []
            , case options.errorMessage of
                Just errorMessage ->
                    div [ role "alert", ariaLive "assertive" ]
                        [ p [ class "error-message" ] [ text errorMessage ] ]

                Nothing ->
                    text ""
            ]
        ]


noAttribute : Html.Attribute msg
noAttribute =
    classList []
