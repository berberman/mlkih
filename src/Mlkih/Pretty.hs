{-# LANGUAGE TypeFamilies #-}

module Mlkih.Pretty
  ( Doc,
    PrettyPrint (..),
    NameOf,
    LevelOf,
    (<+>),
    parens,
    text,
    int,
    render,
    brackets,
    braces,
    hcatWithComma,
    char,
  )
where

import Text.PrettyPrint (Doc, brackets, char, int, parens, render, text, (<+>))

class PrettyPrint a where
  ppr :: a -> Doc
  toString :: a -> String
  toString = render . ppr

type family NameOf a

type family LevelOf a

braces :: Doc -> Doc
braces doc = char '{' <> doc <> char '}'

hcatWithComma :: [Doc] -> Doc
hcatWithComma [] = text ""
hcatWithComma [doc] = doc
hcatWithComma (doc : docs) = doc <> text ", " <> hcatWithComma docs
