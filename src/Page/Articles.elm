module Page.Articles exposing
    ( Model
    , Msg
    , init
    , update
    , viewDocument
    )

import Api
import Article exposing (Article)
import ArticleId
import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (href)
import Http
import LogElement
import ViewElements.Container as Container
import ViewElements.Header as Header



--- MODEL ---


type Model
    = Loading
    | Failure Http.Error
    | Success SuccessModel


type alias SuccessModel =
    { articles : List Article }



--- UPDATE ---


type Msg
    = FetchedArticles (Result Http.Error (List Article))
    | ErrorLogged (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchedArticles result ->
            case result of
                Ok articles ->
                    ( Success { articles = articles }, Cmd.none )

                Err error ->
                    ( Failure error
                    , error
                        |> LogElement.fromHttpError "Get articles"
                        |> Maybe.map (Api.writeToServerLog ErrorLogged)
                        |> Maybe.withDefault Cmd.none
                    )

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
    [ Header.header
    , Container.mainContent
        [ viewContent model
        ]
    ]


viewContent : Model -> Html Msg
viewContent model =
    case model of
        Loading ->
            text "Spinner"

        Failure error ->
            text "error"

        Success successModel ->
            viewSuccess successModel


viewSuccess : SuccessModel -> Html Msg
viewSuccess successModel =
    viewArticles successModel.articles


viewArticles : List Article -> Html Msg
viewArticles articles =
    ul []
        (List.map viewArticle articles)


viewArticle : Article -> Html Msg
viewArticle article =
    li []
        [ a [ href ("/article/" ++ (Article.id >> ArticleId.toString) article) ]
            [ text (Article.title article) ]
        ]



--- INIT ---


init : ( Model, Cmd Msg )
init =
    ( Loading, Api.getArticles FetchedArticles )
