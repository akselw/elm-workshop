# 3-map

title: `map` is for lists, isn't it?

## author: Aksel Wester

You use `map` to traverse a list and apply a function to all of its element. The type signature of `List.map` says that it takes two arguments: a function to use on the elements in a list, and an actual list of elements:

```text
List.map : (a -> b) -> List a -> List b
```

But the `map` function doesn't just exist in the `List` module, there are other `map`s as well. `Array.map` makes sense, `Array`s are basically just lists anyway. Their type signatures are even almost exactly the same:

```text
Array.map : (a -> b) -> Array a -> Array b
```

But what about all these other `map`s? `Maybe.map`, what does that do? A `Maybe` isn't a collection of elements like `List` and `Array`! Well, it _is_ a collection, but it only contains one element, which might not be there. Let's look at the type signature of `Maybe.map`:

```text
Maybe.map : (a -> b) -> Maybe a -> Maybe b
```

Hmm... Strange... That seems awfully familiar. Anyway, let's try to reason about what this function does! We start with the last argument 'Maybe a'. Since the `a` is lower case, we know that it can be whatever type we want, as long as the `a` is the same in the whole type signature. The first argument, `(a -> b)`, is a function that takes an `a` and returns a `b`. In other words a function that we can use on the element that might or might not be present in our `Maybe`. Lastly, the return type is `Maybe b`; a `Maybe` of the same type that the function `(a -> b)` returns.

So what does `Maybe.map` actually do? If the `Maybe` in the last argument is a `Nothing` we can't really do anything, so `map` _has_ to return another `Nothing`. Because the type `b` be any type, the implementation of `Maybe.map` can't possibly know in advance how to construct that type. But what if the argument is a `Just`? Well, then it's a `Just` containing something of type `a`, so what do we do with that? Since the return type of `Maybe.map` is a `Maybe b`, `map` has to use the function `(a -> b)` on the `a` to get a `b`, and then wrap it in a `Just`.

In other words, `Maybe.map` takes a function and a `Maybe` and uses that function on the element in the `Maybe` if the element is present. If we look in the [source code for `Maybe.map`](https://github.com/elm-lang/core/blob/1.0.0/src/Maybe.elm#L74), we see exactly what we expect:

```text
map : (a -> b) -> Maybe a -> Maybe b
map f maybe =
    case maybe of
      Just value -> Just (f value)
      Nothing -> Nothing
```

In fact, if we look at all the other `map` functions on other modules, they all share the same pattern in their type signatures. They all do what we expect, or what we can guess, by examining their _stuctures_.

In summary, a the `map` function of some structure `Structure` looks like this:

```text
Structure.map : (a -> b) -> Structure a -> Structure b
```

And `map` uses the function provided as its first argument on the element or elements the structure contains.

P.S.: What we here call a _structure_ is called a _functor_ in category theory, and being a functor is one of the requirements of a monad.

