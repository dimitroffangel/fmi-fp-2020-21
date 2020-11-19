{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE TupleSections #-}

data World = World

putStrLn' :: String -> World -> World
putStrLn' = undefined -- тук се случват някакви магии

getLine' :: World -> (String, World)
getLine' = undefined -- още магии

greet :: IO ()
greet = do
  name <- getLine
  putStrLn name

greet' :: World
greet' =
  let w1 = World
      (name, w2) = getLine' w1
   in putStrLn' name w2

-- bad
branch :: World -> (World, World)
branch w =
  ( putStrLn' "I love" w,
    putStrLn' "I hate" w
  )

newtype WorldT a = WorldT (World -> (a, World)) deriving (Functor)

-- show what is Functor
-- newtype Box a = Box a deriving (Functor, Show)

-- a :: Box Integer
-- a = fmap (+ 1) (Box 1)

getLineT :: WorldT String
getLineT = WorldT getLine'

putStrLnT :: String -> WorldT ()
putStrLnT s = WorldT (\w -> ((), putStrLn' s w))

(>>>=) ::
  WorldT a -> -- World -> (a, World)) - света ни дава стойност а
  (a -> WorldT b) -> -- a -> World -> (b, World) - използваме а за да трансформираме света и той ни дава б
  WorldT b -- (World -> (b, World))
(WorldT wt) >>>= wft =
  WorldT
    ( \w ->
        let (a, w2) = wt w
            (WorldT wtb) = wft a
         in wtb w2
    )

greetT :: WorldT ()
greetT =
  getLineT >>>= \name ->
    putStrLnT name >>>= \_ ->
      putStrLnT "End"

instance Applicative WorldT where
  pure x = WorldT (x,)
  wtf <*> wt = wtf >>>= \f -> wt >>>= \a -> pure (f a)

instance Monad WorldT where
  (>>=) = (>>>=)

doGreet :: WorldT ()
doGreet = do
  name <- getLineT
  putStrLnT name