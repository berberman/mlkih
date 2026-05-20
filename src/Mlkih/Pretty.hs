{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeFamilies #-}

module Mlkih.Pretty
  ( Doc,
    PrettyPrint (..),
    NameOf,
    LevelOf,
    (PP.<+>),
    pretty,
    list,
    PP.line,
    PP.viaShow,
    PP.parens,
    render,
    renderWithWidth,
    renderPlain,
    PP.brackets,
    PP.braces,
    hcatWithComma,
    PP.softline,
    PP.group,
    PP.align,
    PP.nest,
    PP.hang,
    PP.sep,
    PP.vsep,
    PP.punctuate,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    bold,
    dim,
  )
where

import qualified Data.Text as T
import Numeric.Natural
import qualified Prettyprinter as PP
import qualified Prettyprinter.Render.String as PP

type Doc = PP.Doc Style

data Style
  = Red
  | Green
  | Yellow
  | Blue
  | Magenta
  | Cyan
  | Bold
  | Dim
  deriving (Eq, Show)

class PrettyPrint a where
  ppr :: a -> Doc
  toString :: a -> String
  toString = render . ppr

instance PrettyPrint Doc where
  ppr = id

instance PrettyPrint () where
  ppr = pretty

instance PrettyPrint Int where
  ppr = pretty

instance PrettyPrint T.Text where
  ppr = pretty

instance PrettyPrint Natural where
  ppr = pretty

instance PrettyPrint Char where
  ppr = pretty

instance {-# OVERLAPPING #-} PrettyPrint String where
  ppr = pretty

instance {-# OVERLAPPING #-} (PrettyPrint a) => PrettyPrint [a] where
  ppr = PP.align . list . map ppr

type family NameOf a

type family LevelOf a

pretty :: (PP.Pretty a) => a -> Doc
pretty = PP.pretty

list :: [Doc] -> Doc
list = PP.list

hcatWithComma :: [Doc] -> Doc
hcatWithComma = PP.group . PP.fillSep . PP.punctuate PP.comma

annotateStyle :: Style -> Doc -> Doc
annotateStyle = PP.annotate

red, green, yellow, blue, magenta, cyan, bold, dim :: Doc -> Doc
red = annotateStyle Red
green = annotateStyle Green
yellow = annotateStyle Yellow
blue = annotateStyle Blue
magenta = annotateStyle Magenta
cyan = annotateStyle Cyan
bold = annotateStyle Bold
dim = annotateStyle Dim

layoutOptions :: Int -> PP.LayoutOptions
layoutOptions width = PP.LayoutOptions {PP.layoutPageWidth = PP.AvailablePerLine width 1.0}

render :: Doc -> String
render = renderWithWidth 80

renderWithWidth :: Int -> Doc -> String
renderWithWidth width = renderAnsi . PP.layoutPretty (layoutOptions width)

renderPlain :: Doc -> String
renderPlain = PP.renderString . PP.layoutPretty (layoutOptions 80)

renderAnsi :: PP.SimpleDocStream Style -> String
renderAnsi = go []
  where
    go _ PP.SFail = ""
    go _ PP.SEmpty = ""
    go stack (PP.SChar c rest) = c : go stack rest
    go stack (PP.SText _ txt rest) = T.unpack txt <> go stack rest
    go stack (PP.SLine indent rest) = '\n' : replicate indent ' ' <> go stack rest
    go stack (PP.SAnnPush style rest) = ansi style <> go (style : stack) rest
    go [] (PP.SAnnPop rest) = ansiReset <> go [] rest
    go (_ : stack) (PP.SAnnPop rest) = ansiReset <> concatMap ansi (reverse stack) <> go stack rest

ansi :: Style -> String
ansi style =
  case style of
    Red -> "\ESC[31m"
    Green -> "\ESC[32m"
    Yellow -> "\ESC[33m"
    Blue -> "\ESC[34m"
    Magenta -> "\ESC[35m"
    Cyan -> "\ESC[36m"
    Bold -> "\ESC[1m"
    Dim -> "\ESC[2m"

ansiReset :: String
ansiReset = "\ESC[0m"
