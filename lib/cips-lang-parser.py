#!/usr/bin/env python3
"""
CIPS-LANG Parser v1.0

Tokenizer and AST generator for the CIPS symbolic language.
Implements BNF grammar from CIPS-LANG-SPEC-v0.1.md.

Origin: Gen 115, 2025-12-22
"""

import re
from dataclasses import dataclass, field
from enum import Enum, auto
from typing import List, Optional, Any, Dict, Union


class TokenType(Enum):
    """Token types for CIPS-LANG lexer."""
    # Operators
    CREATE = auto()      # ⊕
    DELETE = auto()      # ⊖
    FLOW = auto()        # ⟿
    PERSIST = auto()     # ⟼
    EQUALS = auto()       # ≡
    CONDITIONAL = auto() # ⸮
    FORALL = auto()      # ∀
    EXISTS = auto()      # ∃
    NOT = auto()         # ¬
    SEQUENCE = auto()    # ⫶
    CONTAINS = auto()    # ⊃
    HAS = auto()         # ∋
    ETERNAL = auto()     # ∞

    # Types
    FORMA = auto()       # ◈
    MEM = auto()         # ⧬
    NEXUS = auto()       # ⛓
    SOL = auto()         # ⊙
    AQUA = auto()        # 〰

    # Modifiers
    NOW = auto()         # ⊛
    PAST = auto()        # ◁
    FUTURE = auto()      # ▷
    APPROX = auto()      # ≋
    POTENTIAL = auto()   # ◇
    ACTUAL = auto()      # ◆

    # Structure
    LBRACE = auto()      # {
    RBRACE = auto()      # }
    LPAREN = auto()      # (
    RPAREN = auto()      # )
    LANGLE = auto()      # ⟨
    RANGLE = auto()      # ⟩
    COLON = auto()       # :
    COMMA = auto()       # ,
    DOT = auto()         # .
    VERIFY = auto()      # ✓
    ERROR = auto()       # ⍼

    # Literals
    IDENTIFIER = auto()  # English names
    STRING = auto()      # "..."
    NUMBER = auto()      # 123
    LAMBDA = auto()      # λ

    # Keywords
    GENESIS = auto()     # genesis block reference
    SKILL = auto()       # skill keyword
    AGENT = auto()       # agent keyword
    DEF = auto()         # def keyword
    IF = auto()          # if (alternative to ⸮)
    FOR = auto()         # for (alternative to ∀)
    IN = auto()          # in keyword
    ON = auto()          # on keyword
    NEW = auto()         # new keyword
    TRUE = auto()        # true
    FALSE = auto()       # false

    # Comments
    COMMENT = auto()     # // ...

    # Special
    NEWLINE = auto()
    EOF = auto()


# Glyph to token type mapping
GLYPH_MAP = {
    '⊕': TokenType.CREATE,
    '⊖': TokenType.DELETE,
    '⟿': TokenType.FLOW,
    '⟼': TokenType.PERSIST,
    '≡': TokenType.EQUALS,
    '⸮': TokenType.CONDITIONAL,
    '∀': TokenType.FORALL,
    '∃': TokenType.EXISTS,
    '¬': TokenType.NOT,
    '⫶': TokenType.SEQUENCE,
    '⊃': TokenType.CONTAINS,
    '∋': TokenType.HAS,
    '∞': TokenType.ETERNAL,
    '◈': TokenType.FORMA,
    '⧬': TokenType.MEM,
    '⛓': TokenType.NEXUS,
    '⊙': TokenType.SOL,
    '〰': TokenType.AQUA,
    '⊛': TokenType.NOW,
    '◁': TokenType.PAST,
    '▷': TokenType.FUTURE,
    '≋': TokenType.APPROX,
    '◇': TokenType.POTENTIAL,
    '◆': TokenType.ACTUAL,
    '{': TokenType.LBRACE,
    '}': TokenType.RBRACE,
    '(': TokenType.LPAREN,
    ')': TokenType.RPAREN,
    '⟨': TokenType.LANGLE,
    '⟩': TokenType.RANGLE,
    ':': TokenType.COLON,
    ',': TokenType.COMMA,
    '.': TokenType.DOT,
    '✓': TokenType.VERIFY,
    '⍼': TokenType.ERROR,
    'λ': TokenType.LAMBDA,
}

KEYWORDS = {
    'genesis': TokenType.GENESIS,
    'skill': TokenType.SKILL,
    'agent': TokenType.AGENT,
    'def': TokenType.DEF,
    'if': TokenType.IF,
    'for': TokenType.FOR,
    'in': TokenType.IN,
    'on': TokenType.ON,
    'new': TokenType.NEW,
    'true': TokenType.TRUE,
    'false': TokenType.FALSE,
}


@dataclass
class Token:
    """Token with position info."""
    type: TokenType
    value: Any
    line: int
    column: int

    def __repr__(self):
        return f"Token({self.type.name}, {self.value!r}, L{self.line}:C{self.column})"


@dataclass
class LexerError(Exception):
    """Error during lexical analysis."""
    message: str
    line: int
    column: int

    def __str__(self):
        return f"⍼ LexerError at L{self.line}:C{self.column}: {self.message}"


class Lexer:
    """Tokenizer for CIPS-LANG source code."""

    def __init__(self, source: str):
        self.source = source
        self.pos = 0
        self.line = 1
        self.column = 1
        self.tokens: List[Token] = []

    def peek(self, offset: int = 0) -> Optional[str]:
        """Peek at character at current position + offset."""
        idx = self.pos + offset
        if idx < len(self.source):
            return self.source[idx]
        return None

    def advance(self) -> Optional[str]:
        """Advance position and return current character."""
        if self.pos >= len(self.source):
            return None
        ch = self.source[self.pos]
        self.pos += 1
        if ch == '\n':
            self.line += 1
            self.column = 1
        else:
            self.column += 1
        return ch

    def skip_whitespace(self):
        """Skip spaces and tabs (not newlines)."""
        while self.peek() in (' ', '\t'):
            self.advance()

    def read_string(self) -> str:
        """Read a quoted string."""
        quote = self.advance()  # consume opening quote
        start_line, start_col = self.line, self.column
        result = []
        while self.peek() and self.peek() != quote:
            ch = self.advance()
            if ch == '\\' and self.peek():
                # Handle escapes
                escape = self.advance()
                if escape == 'n':
                    result.append('\n')
                elif escape == 't':
                    result.append('\t')
                elif escape == '\\':
                    result.append('\\')
                elif escape == quote:
                    result.append(quote)
                else:
                    result.append('\\')
                    result.append(escape)
            else:
                result.append(ch)
        if not self.peek():
            raise LexerError("Unterminated string", start_line, start_col)
        self.advance()  # consume closing quote
        return ''.join(result)

    def read_identifier(self) -> str:
        """Read an identifier (English name, dotted path)."""
        result = []
        while self.peek() and (self.peek().isalnum() or self.peek() in ('_', '-', '.')):
            result.append(self.advance())
        return ''.join(result)

    def read_number(self) -> Union[int, float]:
        """Read a numeric literal."""
        result = []
        while self.peek() and (self.peek().isdigit() or self.peek() == '.'):
            result.append(self.advance())
        num_str = ''.join(result)
        if '.' in num_str:
            return float(num_str)
        return int(num_str)

    def read_comment(self) -> str:
        """Read a single-line comment."""
        self.advance()  # first /
        self.advance()  # second /
        result = []
        while self.peek() and self.peek() != '\n':
            result.append(self.advance())
        return ''.join(result).strip()

    def tokenize(self) -> List[Token]:
        """Tokenize the entire source."""
        while self.pos < len(self.source):
            self.skip_whitespace()
            if self.pos >= len(self.source):
                break

            start_line, start_col = self.line, self.column
            ch = self.peek()

            # Newline
            if ch == '\n':
                self.advance()
                self.tokens.append(Token(TokenType.NEWLINE, '\n', start_line, start_col))
                continue

            # Comment
            if ch == '/' and self.peek(1) == '/':
                comment = self.read_comment()
                self.tokens.append(Token(TokenType.COMMENT, comment, start_line, start_col))
                continue

            # String
            if ch in ('"', "'"):
                value = self.read_string()
                self.tokens.append(Token(TokenType.STRING, value, start_line, start_col))
                continue

            # Number
            if ch.isdigit():
                value = self.read_number()
                self.tokens.append(Token(TokenType.NUMBER, value, start_line, start_col))
                continue

            # Glyph operators and types
            if ch in GLYPH_MAP:
                self.advance()
                self.tokens.append(Token(GLYPH_MAP[ch], ch, start_line, start_col))
                continue

            # Identifier or keyword
            if ch.isalpha() or ch == '_':
                value = self.read_identifier()
                # Check if it's a keyword
                if value in KEYWORDS:
                    self.tokens.append(Token(KEYWORDS[value], value, start_line, start_col))
                else:
                    self.tokens.append(Token(TokenType.IDENTIFIER, value, start_line, start_col))
                continue

            # Unknown character - skip for now
            self.advance()

        self.tokens.append(Token(TokenType.EOF, None, self.line, self.column))
        return self.tokens


# AST Node Types
@dataclass
class ASTNode:
    """Base AST node."""
    line: int = 0
    column: int = 0


@dataclass
class GenesisBlock(ASTNode):
    """Genesis block (immutable config)."""
    root: str = ""
    created: str = ""
    lang_created: str = ""
    author: str = ""
    axioms: List[str] = field(default_factory=list)
    origin: List[str] = field(default_factory=list)


@dataclass
class Definition(ASTNode):
    """Definition: ⊕type:name ≡ { body }"""
    type_name: str = ""
    name: str = ""
    body: Any = None


@dataclass
class Conditional(ASTNode):
    """Conditional: ⸮(expr)⟿ then ⫶ else"""
    condition: Any = None
    then_branch: Any = None
    else_branch: Any = None


@dataclass
class ForEach(ASTNode):
    """For-each: ∀var∈collection⟿ body"""
    variable: str = ""
    collection: Any = None
    body: Any = None


@dataclass
class Sequence(ASTNode):
    """Sequence: block ⫶ block"""
    statements: List[Any] = field(default_factory=list)


@dataclass
class FunctionCall(ASTNode):
    """Function call: name(args)"""
    name: str = ""
    args: List[Any] = field(default_factory=list)


@dataclass
class Lambda(ASTNode):
    """Lambda: λ(params)⟿ body"""
    params: List[str] = field(default_factory=list)
    body: Any = None


@dataclass
class PropertyAccess(ASTNode):
    """Property access: obj.prop"""
    object: Any = None
    property: str = ""


@dataclass
class BinaryOp(ASTNode):
    """Binary operation: left op right"""
    left: Any = None
    operator: str = ""
    right: Any = None


@dataclass
class UnaryOp(ASTNode):
    """Unary operation: op expr"""
    operator: str = ""
    operand: Any = None


@dataclass
class Literal(ASTNode):
    """Literal value (string, number, bool)."""
    value: Any = None


@dataclass
class Identifier(ASTNode):
    """Identifier reference."""
    name: str = ""


@dataclass
class ObjectLiteral(ASTNode):
    """Object: { key: value, ... }"""
    entries: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ArrayLiteral(ASTNode):
    """Array: [item, ...]"""
    items: List[Any] = field(default_factory=list)


@dataclass
class Program(ASTNode):
    """Root program node."""
    genesis: Optional[GenesisBlock] = None
    blocks: List[Any] = field(default_factory=list)


@dataclass
class ParseError(Exception):
    """Error during parsing."""
    message: str
    token: Token

    def __str__(self):
        return f"⍼ ParseError at L{self.token.line}:C{self.token.column}: {self.message}"


class Parser:
    """Parser for CIPS-LANG AST generation."""

    def __init__(self, tokens: List[Token]):
        self.tokens = [t for t in tokens if t.type not in (TokenType.COMMENT, TokenType.NEWLINE)]
        self.pos = 0

    def peek(self, offset: int = 0) -> Token:
        """Peek at token at current position + offset."""
        idx = self.pos + offset
        if idx < len(self.tokens):
            return self.tokens[idx]
        return self.tokens[-1]  # Return EOF

    def advance(self) -> Token:
        """Advance and return current token."""
        token = self.peek()
        if token.type != TokenType.EOF:
            self.pos += 1
        return token

    def expect(self, *types: TokenType) -> Token:
        """Expect current token to be one of types."""
        token = self.peek()
        if token.type not in types:
            expected = " or ".join(t.name for t in types)
            raise ParseError(f"Expected {expected}, got {token.type.name}", token)
        return self.advance()

    def match(self, *types: TokenType) -> bool:
        """Check if current token matches any type."""
        return self.peek().type in types

    def parse(self) -> Program:
        """Parse entire program."""
        program = Program(line=1, column=1)

        # Check for genesis block
        if self.match(TokenType.NEXUS) and self.peek(1).type == TokenType.DOT:
            program.genesis = self.parse_genesis()

        # Parse remaining blocks
        while not self.match(TokenType.EOF):
            block = self.parse_block()
            if block:
                program.blocks.append(block)

        return program

    def parse_genesis(self) -> GenesisBlock:
        """Parse genesis block: ⛓.genesis ≡ { ... }"""
        token = self.advance()  # ⛓
        genesis = GenesisBlock(line=token.line, column=token.column)

        self.expect(TokenType.DOT)
        self.expect(TokenType.GENESIS)
        self.expect(TokenType.EQUALS)
        self.expect(TokenType.LBRACE)

        # Parse genesis fields
        while not self.match(TokenType.RBRACE, TokenType.EOF):
            if self.match(TokenType.IDENTIFIER):
                key = self.advance().value
                self.expect(TokenType.COLON)
                value = self.parse_expression()

                if key == "root":
                    genesis.root = str(value.value if isinstance(value, Literal) else value)
                elif key == "created":
                    genesis.created = str(value.value if isinstance(value, Literal) else value)
                elif key == "lang.created":
                    genesis.lang_created = str(value.value if isinstance(value, Literal) else value)
                elif key == "author":
                    genesis.author = str(value.value if isinstance(value, Literal) else value)
                elif key == "axioms":
                    if isinstance(value, ArrayLiteral):
                        genesis.axioms = [str(v.value if isinstance(v, Literal) else v) for v in value.items]
                elif key == "V≫.origin" or key.endswith(".origin"):
                    if isinstance(value, ArrayLiteral):
                        genesis.origin = [str(v.value if isinstance(v, Literal) else v) for v in value.items]

            # Skip comma
            if self.match(TokenType.COMMA):
                self.advance()

        self.expect(TokenType.RBRACE)
        return genesis

    def parse_block(self) -> Optional[ASTNode]:
        """Parse a single block (definition, control, expression)."""
        # Definition: ⊕type:name ≡ { body }
        if self.match(TokenType.CREATE):
            return self.parse_definition()

        # Conditional: ⸮(expr)⟿ A ⫶ B
        if self.match(TokenType.CONDITIONAL):
            return self.parse_conditional()

        # For-each: ∀var∈collection⟿ body
        if self.match(TokenType.FORALL):
            return self.parse_foreach()

        # Persist: ⟼ expr
        if self.match(TokenType.PERSIST):
            return self.parse_persist()

        # Expression
        return self.parse_expression()

    def parse_definition(self) -> Definition:
        """Parse: ⊕type:name ≡ { body }"""
        token = self.advance()  # ⊕
        defn = Definition(line=token.line, column=token.column)

        # Type (glyph or keyword)
        if self.match(TokenType.FORMA, TokenType.MEM, TokenType.NEXUS,
                      TokenType.SOL, TokenType.AQUA, TokenType.SKILL, TokenType.AGENT):
            defn.type_name = self.advance().value
        else:
            defn.type_name = self.expect(TokenType.IDENTIFIER).value

        self.expect(TokenType.COLON)
        defn.name = self.expect(TokenType.IDENTIFIER).value
        self.expect(TokenType.EQUALS)

        if self.match(TokenType.LBRACE):
            defn.body = self.parse_object()
        else:
            defn.body = self.parse_expression()

        return defn

    def parse_conditional(self) -> Conditional:
        """Parse: ⸮(expr)⟿ then ⫶ else"""
        token = self.advance()  # ⸮
        cond = Conditional(line=token.line, column=token.column)

        self.expect(TokenType.LPAREN)
        cond.condition = self.parse_expression()
        self.expect(TokenType.RPAREN)
        self.expect(TokenType.FLOW)

        cond.then_branch = self.parse_block()

        if self.match(TokenType.SEQUENCE):
            self.advance()
            cond.else_branch = self.parse_block()

        return cond

    def parse_foreach(self) -> ForEach:
        """Parse: ∀var∈collection⟿ body"""
        token = self.advance()  # ∀
        foreach = ForEach(line=token.line, column=token.column)

        foreach.variable = self.expect(TokenType.IDENTIFIER).value
        self.expect(TokenType.HAS)  # ∋ used as ∈
        foreach.collection = self.parse_expression()
        self.expect(TokenType.FLOW)
        foreach.body = self.parse_block()

        return foreach

    def parse_persist(self) -> UnaryOp:
        """Parse: ⟼ expr"""
        token = self.advance()  # ⟼
        return UnaryOp(
            line=token.line,
            column=token.column,
            operator='⟼',
            operand=self.parse_expression()
        )

    def parse_expression(self) -> ASTNode:
        """Parse expression with binary operators."""
        return self.parse_binary()

    def parse_binary(self) -> ASTNode:
        """Parse binary operations."""
        left = self.parse_unary()

        while self.match(TokenType.FLOW, TokenType.EQUALS, TokenType.CONTAINS,
                        TokenType.HAS, TokenType.SEQUENCE):
            op = self.advance()
            right = self.parse_unary()
            left = BinaryOp(
                line=op.line,
                column=op.column,
                left=left,
                operator=op.value,
                right=right
            )

        return left

    def parse_unary(self) -> ASTNode:
        """Parse unary operations."""
        if self.match(TokenType.NOT):
            op = self.advance()
            return UnaryOp(
                line=op.line,
                column=op.column,
                operator='¬',
                operand=self.parse_unary()
            )

        return self.parse_call()

    def parse_call(self) -> ASTNode:
        """Parse function calls and property access."""
        expr = self.parse_primary()

        while True:
            if self.match(TokenType.LPAREN):
                expr = self.parse_function_call(expr)
            elif self.match(TokenType.DOT):
                self.advance()
                prop = self.expect(TokenType.IDENTIFIER).value
                expr = PropertyAccess(
                    line=expr.line,
                    column=expr.column,
                    object=expr,
                    property=prop
                )
            else:
                break

        return expr

    def parse_function_call(self, callee: ASTNode) -> FunctionCall:
        """Parse function call arguments."""
        self.expect(TokenType.LPAREN)
        call = FunctionCall(
            line=callee.line,
            column=callee.column,
            name=callee.name if isinstance(callee, Identifier) else str(callee)
        )

        if not self.match(TokenType.RPAREN):
            call.args.append(self.parse_expression())
            while self.match(TokenType.COMMA):
                self.advance()
                call.args.append(self.parse_expression())

        self.expect(TokenType.RPAREN)
        return call

    def parse_primary(self) -> ASTNode:
        """Parse primary expressions."""
        token = self.peek()

        # Lambda: λ(params)⟿ body
        if self.match(TokenType.LAMBDA):
            return self.parse_lambda()

        # Object literal
        if self.match(TokenType.LBRACE):
            return self.parse_object()

        # Array literal (using ⟨⟩)
        if self.match(TokenType.LANGLE):
            return self.parse_array()

        # Grouped expression
        if self.match(TokenType.LPAREN):
            self.advance()
            expr = self.parse_expression()
            self.expect(TokenType.RPAREN)
            return expr

        # Literals
        if self.match(TokenType.STRING):
            return Literal(line=token.line, column=token.column, value=self.advance().value)

        if self.match(TokenType.NUMBER):
            return Literal(line=token.line, column=token.column, value=self.advance().value)

        if self.match(TokenType.TRUE):
            self.advance()
            return Literal(line=token.line, column=token.column, value=True)

        if self.match(TokenType.FALSE):
            self.advance()
            return Literal(line=token.line, column=token.column, value=False)

        # Type glyphs as identifiers
        if self.match(TokenType.FORMA, TokenType.MEM, TokenType.NEXUS,
                      TokenType.SOL, TokenType.AQUA, TokenType.NOW,
                      TokenType.VERIFY, TokenType.ERROR):
            return Identifier(line=token.line, column=token.column, name=self.advance().value)

        # Identifier
        if self.match(TokenType.IDENTIFIER):
            return Identifier(line=token.line, column=token.column, name=self.advance().value)

        # Skip unknown tokens
        if not self.match(TokenType.EOF):
            self.advance()
            return self.parse_primary() if not self.match(TokenType.EOF) else Literal(value=None)

        return Literal(line=token.line, column=token.column, value=None)

    def parse_lambda(self) -> Lambda:
        """Parse: λ(params)⟿ body"""
        token = self.advance()  # λ
        lam = Lambda(line=token.line, column=token.column)

        self.expect(TokenType.LPAREN)
        if not self.match(TokenType.RPAREN):
            lam.params.append(self.expect(TokenType.IDENTIFIER).value)
            while self.match(TokenType.COMMA):
                self.advance()
                lam.params.append(self.expect(TokenType.IDENTIFIER).value)
        self.expect(TokenType.RPAREN)
        self.expect(TokenType.FLOW)
        lam.body = self.parse_block()

        return lam

    def parse_object(self) -> ObjectLiteral:
        """Parse: { key: value, ... }"""
        token = self.expect(TokenType.LBRACE)
        obj = ObjectLiteral(line=token.line, column=token.column)

        while not self.match(TokenType.RBRACE, TokenType.EOF):
            # Key can be identifier or string
            if self.match(TokenType.IDENTIFIER):
                key = self.advance().value
            elif self.match(TokenType.STRING):
                key = self.advance().value
            else:
                break

            self.expect(TokenType.COLON)
            value = self.parse_expression()
            obj.entries[key] = value

            if self.match(TokenType.COMMA):
                self.advance()

        self.expect(TokenType.RBRACE)
        return obj

    def parse_array(self) -> ArrayLiteral:
        """Parse: ⟨item, ...⟩ or [...] if we add brackets."""
        token = self.expect(TokenType.LANGLE)
        arr = ArrayLiteral(line=token.line, column=token.column)

        if not self.match(TokenType.RANGLE):
            arr.items.append(self.parse_expression())
            while self.match(TokenType.COMMA):
                self.advance()
                arr.items.append(self.parse_expression())

        self.expect(TokenType.RANGLE)
        return arr


def parse_cips(source: str) -> Program:
    """Parse CIPS-LANG source code and return AST."""
    lexer = Lexer(source)
    tokens = lexer.tokenize()
    parser = Parser(tokens)
    return parser.parse()


def tokenize_cips(source: str) -> List[Token]:
    """Tokenize CIPS-LANG source code."""
    lexer = Lexer(source)
    return lexer.tokenize()


if __name__ == "__main__":
    import sys
    import json

    if len(sys.argv) < 2:
        print("Usage: cips-lang-parser.py <file.cips> [--tokens]")
        sys.exit(1)

    filepath = sys.argv[1]
    show_tokens = "--tokens" in sys.argv

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            source = f.read()

        if show_tokens:
            tokens = tokenize_cips(source)
            for tok in tokens:
                print(tok)
        else:
            ast = parse_cips(source)
            # Simple AST display
            print(f"Program with {len(ast.blocks)} blocks")
            if ast.genesis:
                print(f"  Genesis: root={ast.genesis.root}")
            for i, block in enumerate(ast.blocks):
                print(f"  Block {i}: {type(block).__name__}")

        print("✓ Parse successful")
    except (LexerError, ParseError) as e:
        print(str(e))
        sys.exit(1)
    except FileNotFoundError:
        print(f"⍼ File not found: {filepath}")
        sys.exit(1)
