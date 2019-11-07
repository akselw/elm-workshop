module Api exposing (getArticle, getArticles, getComments, writeToServerLog)

import Article exposing (Article)
import ArticleId exposing (ArticleId)
import Comment exposing (Comment)
import Http
import Json.Decode
import LogElement exposing (LogElement)


getArticles : (Result Http.Error (List Article) -> msg) -> Cmd msg
getArticles msg =
    Http.get
        { url = "/api/articles"
        , expect = Http.expectJson msg (Json.Decode.list Article.decode)
        }


getArticle : (Result Http.Error Article -> msg) -> ArticleId -> Cmd msg
getArticle msg articleId =
    Http.get
        { url = "/api/article/" ++ ArticleId.toString articleId
        , expect = Http.expectJson msg Article.decode
        }


getComments : (Result Http.Error (List Comment) -> msg) -> ArticleId -> Cmd msg
getComments msg articleId =
    Http.get
        { url = "/api/article/" ++ ArticleId.toString articleId ++ "/comments"
        , expect = Http.expectJson msg (Json.Decode.list Comment.decode)
        }


writeToServerLog : (Result Http.Error () -> msg) -> LogElement -> Cmd msg
writeToServerLog msg logElement =
    Http.post
        { url = "/log"
        , body =
            logElement
                |> LogElement.encode
                |> Http.jsonBody
        , expect = Http.expectWhatever msg
        }
