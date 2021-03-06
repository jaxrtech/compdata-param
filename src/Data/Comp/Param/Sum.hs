{-# LANGUAGE TypeOperators, MultiParamTypeClasses, IncoherentInstances,
  FlexibleInstances, FlexibleContexts, GADTs, TypeSynonymInstances,
  ScopedTypeVariables, TemplateHaskell, Rank2Types #-}
--------------------------------------------------------------------------------
-- |
-- Module      :  Data.Comp.Param.Sum
-- Copyright   :  (c) 2011 Patrick Bahr, Tom Hvitved
-- License     :  BSD3
-- Maintainer  :  Tom Hvitved <hvitved@diku.dk>
-- Stability   :  experimental
-- Portability :  non-portable (GHC Extensions)
--
-- This module provides the infrastructure to extend signatures.
--
--------------------------------------------------------------------------------

module Data.Comp.Param.Sum
    (
     (:<:),
     (:+:),
     caseD,

     -- * Projections for Signatures and Terms
     proj,
     proj2,
     proj3,
     proj4,
     proj5,
     proj6,
     proj7,
     proj8,
     proj9,
     proj10,
     project,
     project2,
     project3,
     project4,
     project5,
     project6,
     project7,
     project8,
     project9,
     project10,
     deepProject,
     deepProject2,
     deepProject3,
     deepProject4,
     deepProject5,
     deepProject6,
     deepProject7,
     deepProject8,
     deepProject9,
     deepProject10,

     -- * Injections for Signatures and Terms
     inj,
     inj2,
     inj3,
     inj4,
     inj5,
     inj6,
     inj7,
     inj8,
     inj9,
     inj10,
     inject,
     inject',
     inject2,
     inject3,
     inject4,
     inject5,
     inject6,
     inject7,
     inject8,
     inject9,
     inject10,
     deepInject,
     deepInject2,
     deepInject3,
     deepInject4,
     deepInject5,
     deepInject6,
     deepInject7,
     deepInject8,
     deepInject9,
     deepInject10,

     injectCxt,
     liftCxt
    ) where

import Prelude hiding (sequence)
import Control.Monad hiding (sequence)
import Data.Comp.Param.Term
import Data.Comp.Param.Algebra
import Data.Comp.Param.Ops
import Data.Comp.Param.Derive.Projections
import Data.Comp.Param.Derive.Injections
import Data.Comp.Param.Difunctor
import Data.Comp.Param.Ditraversable

$(liftM concat $ mapM projn [2..10])

-- |Project the outermost layer of a term to a sub signature. If the signature
-- @g@ is compound of /n/ atomic signatures, use @project@/n/ instead.
project :: (g :<: f) => Cxt h f a b -> Maybe (g a (Cxt h f a b))
project (In t) = proj t
project (Hole _) = Nothing
project (Var _) = Nothing

$(liftM concat $ mapM projectn [2..10])

-- | Tries to coerce a term/context to a term/context over a sub-signature. If
-- the signature @g@ is compound of /n/ atomic signatures, use
-- @deepProject@/n/ instead.
deepProject :: (Ditraversable g, g :<: f) => Term f -> Maybe (Term g)
{-# INLINE deepProject #-}
deepProject = appTSigFunM' proj

$(liftM concat $ mapM deepProjectn [2..10])
{-# INLINE deepProject2 #-}
{-# INLINE deepProject3 #-}
{-# INLINE deepProject4 #-}
{-# INLINE deepProject5 #-}
{-# INLINE deepProject6 #-}
{-# INLINE deepProject7 #-}
{-# INLINE deepProject8 #-}
{-# INLINE deepProject9 #-}
{-# INLINE deepProject10 #-}

$(liftM concat $ mapM injn [2..10])

-- |Inject a term where the outermost layer is a sub signature. If the signature
-- @g@ is compound of /n/ atomic signatures, use @inject@/n/ instead.
inject :: (g :<: f) => g a (Cxt h f a b) -> Cxt h f a b
inject = In . inj

-- |Inject a term where the outermost layer is a sub signature. If the signature
-- @g@ is compound of /n/ atomic signatures, use @inject@/n/ instead.
inject' :: (Difunctor g, g :<: f) => g (Cxt h f a b) (Cxt h f a b) -> Cxt h f a b
inject' = inject . dimap Var id

$(liftM concat $ mapM injectn [2..10])

-- |Inject a term over a sub signature to a term over larger signature. If the
-- signature @g@ is compound of /n/ atomic signatures, use @deepInject@/n/
-- instead.
deepInject :: (Difunctor g, g :<: f) => Term g -> Term f
{-# INLINE deepInject #-}
deepInject (Term t) = Term (appSigFun inj t)

$(liftM concat $ mapM deepInjectn [2..10])
{-# INLINE deepInject2 #-}
{-# INLINE deepInject3 #-}
{-# INLINE deepInject4 #-}
{-# INLINE deepInject5 #-}
{-# INLINE deepInject6 #-}
{-# INLINE deepInject7 #-}
{-# INLINE deepInject8 #-}
{-# INLINE deepInject9 #-}
{-# INLINE deepInject10 #-}

{-| This function injects a whole context into another context. -}
injectCxt :: (Difunctor g, g :<: f) => Cxt h g a (Cxt h f a b) -> Cxt h f a b
injectCxt (In t) = inject $ difmap injectCxt t
injectCxt (Hole x) = x
injectCxt (Var p) = Var p

{-| This function lifts the given functor to a context. -}
liftCxt :: (Difunctor f, g :<: f) => g a b -> Cxt Hole f a b
liftCxt g = simpCxt $ inj g

instance (Show (f a b), Show (g a b)) => Show ((f :+: g) a b) where
    show (Inl v) = show v
    show (Inr v) = show v

instance (Ord (f a b), Ord (g a b)) => Ord ((f :+: g) a b) where
    compare (Inl _) (Inr _) = LT
    compare (Inr _) (Inl _) = GT
    compare (Inl x) (Inl y) = compare x y
    compare (Inr x) (Inr y) = compare x y

instance (Eq (f a b), Eq (g a b)) => Eq ((f :+: g) a b) where
    (Inl x) == (Inl y) = x == y
    (Inr x) == (Inr y) = x == y                   
    _ == _ = False