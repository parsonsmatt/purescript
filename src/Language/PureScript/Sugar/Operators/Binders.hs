module Language.PureScript.Sugar.Operators.Binders where

import Prelude.Compat

import Language.PureScript.AST
import Language.PureScript.Names
import Language.PureScript.Sugar.Operators.Common

matchBinderOperators :: [[(Qualified (OpName 'ValueOpName), Associativity)]] -> Binder -> Binder
matchBinderOperators = matchOperators isBinOp extractOp fromOp reapply id
  where

  isBinOp :: Binder -> Bool
  isBinOp BinaryNoParensBinder{} = True
  isBinOp _ = False

  extractOp :: Binder -> Maybe (Binder, Binder, Binder)
  extractOp (BinaryNoParensBinder op l r) = Just (op, l, r)
  extractOp _ = Nothing

  fromOp :: Binder -> Maybe (SourceSpan, Qualified (OpName 'ValueOpName))
  fromOp (OpBinder ss q@(Qualified _ (OpName _))) = Just (ss, q)
  fromOp _ = Nothing

  reapply :: SourceSpan -> Qualified (OpName 'ValueOpName) -> Binder -> Binder -> Binder
  reapply ss = BinaryNoParensBinder . OpBinder ss
