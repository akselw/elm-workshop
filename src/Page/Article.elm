module Page.Article exposing (Model, Msg, init, update, viewDocument)

--- MODEL ---

import Api
import Article exposing (Article)
import ArticleId exposing (ArticleId)
import Browser exposing (Document)
import Comment exposing (Comment)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import LogElement


type Model
    = Loading
    | Failure Http.Error
    | Success SuccessModel


type alias SuccessModel =
    { article : Article
    , comments : List Comment
    }



--- UPDATE ---


type Msg
    = FetchedArticle (Result Http.Error Article)
    | FetchedComments (Result Http.Error (List Comment))
    | ErrorLogged (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedArticle result ->
            case result of
                Ok article ->
                    ( Success
                        { article = article
                        , comments = []
                        }
                    , Cmd.none
                    )

                Err error ->
                    ( Failure error
                    , error
                        |> LogElement.fromHttpError "Get article"
                        |> Maybe.map (Api.writeToServerLog ErrorLogged)
                        |> Maybe.withDefault Cmd.none
                    )

        FetchedComments result ->
            ( model, Cmd.none )

        ErrorLogged result ->
            ( model, Cmd.none )



--- VIEW ---


viewDocument : Model -> Document Msg
viewDocument model =
    { title = "Articles"
    , body = view model
    }


view : Model -> List (Html Msg)
view model =
    case model of
        Loading ->
            [ text "Spinner" ]

        Failure error ->
            [ text "error" ]

        Success successModel ->
            viewSuccess successModel


viewSuccess : SuccessModel -> List (Html Msg)
viewSuccess successModel =
    [ viewArticle successModel.article
    ]


viewArticle : Article -> Html Msg
viewArticle article =
    li [] [ a [ href ("/article/" ++ (Article.id >> ArticleId.toString) article) ] [ text (Article.title article) ] ]



--- INIT ---


init : ArticleId -> ( Model, Cmd Msg )
init articleId =
    ( Loading, Api.getArticle FetchedArticle articleId )
