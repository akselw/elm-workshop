module Api exposing (createCommentOnArticle, getArticle, getArticles, getComments, getNestedComments, writeToServerLog)

import Article exposing (Article)
import ArticleId exposing (ArticleId)
import ArticleSummary exposing (ArticleSummary)
import Comment exposing (Comment)
import Http
import Json.Decode
import Json.Encode
import LogElement exposing (LogElement)


getArticles : (Result Http.Error (List ArticleSummary) -> msg) -> Cmd msg
getArticles msg =
    Http.get
        { url = "/api/articles"
        , expect = Http.expectJson msg (Json.Decode.list ArticleSummary.decode)
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


getNestedComments : (Result Http.Error (List Comment) -> msg) -> ArticleId -> Cmd msg
getNestedComments msg articleId =
    Http.get
        { url = "/api/article/" ++ ArticleId.toString articleId ++ "/nestedComments"
        , expect = Http.expectJson msg (Json.Decode.list Comment.decode)
        }


createCommentOnArticle : (Result Http.Error (List Comment) -> msg) -> ArticleId -> String -> Cmd msg
createCommentOnArticle msg articleId commentText =
    Http.post
        { url = "/api/article/" ++ ArticleId.toString articleId ++ "/comments"
        , body = Http.jsonBody (Json.Encode.object [ ( "text", Json.Encode.string commentText ) ])
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
