module Main exposing (main)

import Browser exposing (Document)
import Browser.Navigation as Navigation
import Html exposing (..)
import Page.Article
import Page.Articles
import Routes
import Url exposing (Url)



--- MODEL ---
-- Model only represents the current page, and holds that page's model


type alias Model =
    { page : Page
    , navigationKey : Navigation.Key
    }


type Page
    = NotFound
    | Articles Page.Articles.Model
    | Article Page.Article.Model



--- UPDATE ---


type Msg
    = NoOp
    | ArticlesMsg Page.Articles.Msg
    | ArticleMsg Page.Article.Msg
    | UrlChanged Url.Url
    | UrlRequestChanged Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        ArticlesMsg articlesMsg ->
            case model.page of
                Articles articlesModel ->
                    Page.Articles.update articlesMsg articlesModel
                        |> mapPage model.navigationKey Articles ArticlesMsg

                _ ->
                    ( model, Cmd.none )

        ArticleMsg articleMsg ->
            case model.page of
                Article articleModel ->
                    Page.Article.update articleMsg articleModel
                        |> mapPage model.navigationKey Article ArticleMsg

                _ ->
                    ( model, Cmd.none )

        UrlChanged url ->
            initFromUrl model.navigationKey url

        UrlRequestChanged (Browser.External urlString) ->
            ( model, Navigation.load urlString )

        UrlRequestChanged (Browser.Internal url) ->
            ( model
            , url
                |> Url.toString
                |> Navigation.pushUrl model.navigationKey
            )


mapPage : Navigation.Key -> (pageModel -> Page) -> (pageMsg -> Msg) -> ( pageModel, Cmd pageMsg ) -> ( Model, Cmd Msg )
mapPage navigationKey modelConstructor msgConstructor ( pageModel, cmd ) =
    ( { page = modelConstructor pageModel
      , navigationKey = navigationKey
      }
    , Cmd.map msgConstructor cmd
    )


initFromUrl : Navigation.Key -> Url -> ( Model, Cmd Msg )
initFromUrl navigationKey url =
    url
        |> Routes.fromUrl
        |> Maybe.map (initFromRoute navigationKey)
        |> Maybe.withDefault (initPageNotFound navigationKey)


initFromRoute : Navigation.Key -> Routes.Route -> ( Model, Cmd Msg )
initFromRoute navigationKey route =
    case route of
        Routes.Articles ->
            Page.Articles.init
                |> mapPage navigationKey Articles ArticlesMsg

        Routes.Article articleId ->
            articleId
                |> Page.Article.init
                |> mapPage navigationKey Article ArticleMsg


initPageNotFound : Navigation.Key -> ( Model, Cmd msg )
initPageNotFound navigationKey =
    ( { page = NotFound
      , navigationKey = navigationKey
      }
    , Cmd.none
    )



--- VIEW ---


viewDocument : Model -> Document Msg
viewDocument model =
    case model.page of
        NotFound ->
            { title = "Page Not Found"
            , body = [ text "Not found" ]
            }

        Articles articlesModel ->
            articlesModel
                |> Page.Articles.viewDocument
                |> mapDocument ArticlesMsg

        Article articleModel ->
            articleModel
                |> Page.Article.viewDocument
                |> mapDocument ArticleMsg


mapDocument : (pageMsg -> Msg) -> Document pageMsg -> Document Msg
mapDocument msg document =
    { title = document.title
    , body =
        document.body
            |> List.map (Html.map msg)
    }



--- PROGRAM ---


main =
    Browser.application
        { init = init
        , update = update
        , view = viewDocument
        , subscriptions = always Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequestChanged
        }


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init _ url navigationKey =
    initFromUrl navigationKey url
