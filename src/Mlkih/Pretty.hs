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
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    bold,
    dim,
    stripAnsi,
    nat,
  )
where

import Numeric.Natural
import Text.PrettyPrint (Doc, brackets, char, int, parens, render, text, zeroWidthText, (<+>))

class PrettyPrint a where
  ppr :: a -> Doc
  toString :: a -> String
  toString = render . ppr

instance PrettyPrint () where
  ppr _ = text "()"

instance PrettyPrint Doc where
  ppr = id

instance PrettyPrint Bool where
  ppr = text . show

instance PrettyPrint Int where
  ppr = int

instance (PrettyPrint a) => PrettyPrint [a] where
  ppr [] = text "[]"
  ppr xs = brackets (hcatWithComma (map ppr xs))

type family NameOf a

type family LevelOf a

braces :: Doc -> Doc
braces doc = char '{' <> doc <> char '}'

hcatWithComma :: [Doc] -> Doc
hcatWithComma [] = text ""
hcatWithComma [doc] = doc
hcatWithComma (doc : docs) = doc <> text ", " <> hcatWithComma docs

withANSI :: String -> Doc -> Doc
withANSI code doc = zeroWidthText ("\ESC[" ++ code ++ "m") <> doc <> zeroWidthText "\ESC[0m"

red, green, yellow, blue, magenta, cyan, bold, dim :: Doc -> Doc
red = withANSI "31"
green = withANSI "32"
yellow = withANSI "33"
blue = withANSI "34"
magenta = withANSI "35"
cyan = withANSI "36"
bold = withANSI "1"
dim = withANSI "2"

stripAnsi :: String -> String
stripAnsi [] = []
stripAnsi ('\ESC' : '[' : rest) = stripAnsi (dropWhile (/= 'm') rest)
stripAnsi ('m' : rest) = stripAnsi rest
stripAnsi (c : rest) = c : stripAnsi rest

nat :: Natural -> Doc
nat = text . show
