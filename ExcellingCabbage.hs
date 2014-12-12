module ExcellingCabbage(
    Expression(..),
    evaluate,
    processParse,
    parseArithmetic
) where


import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Text.Parsec.Error
import Data.Char

-- Expression algebraic structure for representing arithmetic expressions
data Expression = Constant Integer
                | Cell Int Int
                | Add Expression Expression
                | Sub Expression Expression
                | Mult Expression Expression
                | Division Expression Expression
                deriving (Show)


table = [ [op "*" Mult AssocLeft, op "/" Division AssocLeft], [op "+" Add AssocLeft, op "-" Sub AssocLeft]]
        where
            op s f assoc = Infix( do {string s; return f; }) assoc

-- bracket parser
factor = do {char '('; x <- expr ; char ')'; return x}
            <|> number
            <|> cell

-- number parser
number :: Parser Expression
number = do { 
                ds <- many1 digit;
                return (Constant . read $ ds)
            }

-- cell parser
cell :: Parser Expression
cell = do {
         c <- oneOf "abcdef";
         y <- many1 digit;
         return (Cell (ord c - ord 'a') (read y))
       }

-- 

-- Parser for arithmetic expressions
expr :: Parser Expression
expr = buildExpressionParser table factor

-- function for parsing
parseArithmetic :: String -> Either Text.Parsec.Error.ParseError Expression
parseArithmetic = parse expr ""

processParse :: Either Text.Parsec.Error.ParseError Expression -> Expression
processParse (Left _) = Constant 0
processParse (Right a) = a

-- Function for evaluation
evaluate :: Expression -> Integer
evaluate (Add a b) = evaluate a + evaluate b
evaluate (Sub a b) = evaluate a - evaluate b
evaluate (Mult a b) = evaluate a * evaluate b
evaluate (Division a b) = evaluate a `div` evaluate b
evaluate (Constant a) = a
evaluate (Cell x y) = 1000 * toInteger x + toInteger y
