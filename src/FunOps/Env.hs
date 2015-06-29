{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DeriveFunctor #-}

-- | This module aims to provide a smarter way of handling environment
-- | variables for common scripting use cases including:
-- | * a script author expects a set of environment variables to be set already
-- |   and there are no sane defaults for any, so the fail-at-first-unset-var
-- |   semantics should be used in this case.
-- | * a script author may be able to default one or more environment variables
-- |   to sane values for the script to proceed as advertised but in the cases
-- |   where specific env vars are unset the script should halt and error.
-- |
-- | There are also different ways to report errors back:
-- | * with first error returned (`ErrorT`)
-- | * with accumulated errors (unsupported so far, but coming soon)
module FunOps.Env
( EnvVar(..)
, mkEnvVar
, getEnvVar
) where

import Control.Applicative (Applicative, Alternative)
import Control.Monad (MonadPlus, liftM)
import Control.Monad.Trans.Except (runExceptT, ExceptT(..))
import Control.Monad.IO.Class (MonadIO)
import qualified System.Environment

-- Types for smarter environment variable processing
newtype EnvVar e a = EnvVar { unEnvVar :: ExceptT e IO a }
  deriving (Functor, Applicative, Monad, MonadIO, Alternative, MonadPlus)

type EnvVarName = String
data EnvVarError = EnvVarNotFound EnvVarName deriving (Show, Eq)
type EnvVarE a = EnvVar EnvVarError a

mkEnvVar :: Read a => EnvVarName -> EnvVarE a
mkEnvVar name = EnvVar $ ExceptT $ lookupEnv name

getEnvVar :: EnvVarE a -> IO (Either EnvVarError a)
getEnvVar env  = runExceptT $ unEnvVar env

lookupEnv :: Read a => EnvVarName -> IO (Either EnvVarError a)
lookupEnv name = do
  v <- System.Environment.lookupEnv name
  return $ maybe (Left $ EnvVarNotFound name) (Right . read) v
