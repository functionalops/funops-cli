module FunOps.Prelude where

-- | Provides default for case where first argument is Nothing.
-- | We use a symbolic operator almost identical to the Nix expression
-- | language `?` which provides a default for `null` values on the LHS.
--
-- Examples:
--
-- >>> (Just 7777) ? 6379
-- 7777
--
-- >>> Nothing ? 6379
-- 6379
--
-- >>> let port = Just 8080
-- >>> port ? 9292
-- 8080
--
-- >>> let host = Nothing
-- >>> host ? "api.github.com"
-- "api.github.com"
(?) :: Maybe a -> a -> a
Just x ? _ = x
Nothing ? y = y

