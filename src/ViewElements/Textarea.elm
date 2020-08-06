module ViewElements.Textarea exposing (Textarea, textarea, toHtml, withErrorMessage, withOnBlur)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (ariaLive, role)
import Html.Events exposing (onBlur, onInput)


type Textarea msg
    = Textarea
        { onInput : String -> msg
        , value : String
        , label : String
        , errorMessage : Maybe String
        , onBlur : Maybe msg
        }


textarea : { label : String, onInput : String -> msg } -> String -> Textarea msg
textarea { label, onInput } value =
    Textarea
        { onInput = onInput
        , value = value
        , label = label
        , errorMessage = Nothing
        , onBlur = Nothing
        }



--- OPTIONS ---


withErrorMessage : Maybe String -> Textarea msg -> Textarea msg
withErrorMessage errorMessage (Textarea options) =
    Textarea { options | errorMessage = errorMessage }


withOnBlur : msg -> Textarea msg -> Textarea msg
withOnBlur msg (Textarea options) =
    Textarea { options | onBlur = Just msg }



--- HTML ---


toHtml : Textarea msg -> Html msg
toHtml (Textarea options) =
    div [ class "form-element" ]
        [ label [ class "label" ]
            [ span [ class "label-text" ] [ text options.label ]
            , Html.textarea
                [ class "textarea"
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
