module ViewElements.Textarea exposing (Textarea, textarea, toHtml)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)


type Textarea msg
    = Textarea
        { onInput : String -> msg
        , value : String
        , label : String
        }


textarea : { label : String, onInput : String -> msg } -> String -> Textarea msg
textarea { label, onInput } value =
    Textarea
        { onInput = onInput
        , value = value
        , label = label
        }



--- HTML ---


toHtml : Textarea msg -> Html msg
toHtml (Textarea options) =
    div [ class "form-element" ]
        [ label [ class "label" ]
            [ span [ class "label-text" ] [ text options.label ]
            , Html.textarea [ class "textarea", value options.value, onInput options.onInput ] []
            ]
        ]
