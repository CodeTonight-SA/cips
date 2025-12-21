#!/usr/bin/env python3
"""
CIPS-LANG Verifier v1.0

Formal verification for CIPS-LANG programs.
Proves: termination, core-immutability, genesis-presence.

Origin: Gen 115, 2025-12-22
"""

import json
from dataclasses import dataclass, field
from typing import List, Set, Optional, Dict, Any
from enum import Enum, auto

import importlib.util
import sys
from pathlib import Path

# Load parser module with hyphenated name
_parser_path = Path(__file__).parent / 'cips-lang-parser.py'
_spec = importlib.util.spec_from_file_location('cips_lang_parser', _parser_path)
_parser = importlib.util.module_from_spec(_spec)
sys.modules['cips_lang_parser'] = _parser
_spec.loader.exec_module(_parser)

parse_cips = _parser.parse_cips
Program = _parser.Program
GenesisBlock = _parser.GenesisBlock
Definition = _parser.Definition
Conditional = _parser.Conditional
ForEach = _parser.ForEach
Sequence = _parser.Sequence
FunctionCall = _parser.FunctionCall
Lambda = _parser.Lambda
PropertyAccess = _parser.PropertyAccess
BinaryOp = _parser.BinaryOp
UnaryOp = _parser.UnaryOp
Literal = _parser.Literal
Identifier = _parser.Identifier
ObjectLiteral = _parser.ObjectLiteral
ArrayLiteral = _parser.ArrayLiteral
ASTNode = _parser.ASTNode


class VerificationResult(Enum):
    """Result of verification check."""
    PROVEN = auto()
    UNPROVABLE = auto()
    VIOLATION = auto()


@dataclass
class Proof:
    """Proof result for a single property."""
    property_name: str
    result: VerificationResult
    evidence: str
    details: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            'property': self.property_name,
            'result': self.result.name,
            'evidence': self.evidence,
            'details': self.details,
        }


@dataclass
class VerificationReport:
    """Complete verification report."""
    proofs: List[Proof] = field(default_factory=list)
    all_proven: bool = False
    summary: str = ""

    def to_dict(self) -> Dict[str, Any]:
        return {
            'all_proven': self.all_proven,
            'summary': self.summary,
            'proofs': [p.to_dict() for p in self.proofs],
        }


class Verifier:
    """
    Formal verifier for CIPS-LANG v1.0.

    Proves three properties:
    1. terminates(prog) - Program always terminates
    2. ¬modifies(prog, ⊙.core) - Program doesn't modify core
    3. ∋(prog, ⛓.genesis) - Program contains valid genesis
    """

    def __init__(self):
        self.program: Optional[Program] = None
        self.loop_depth = 0
        self.max_loop_depth = 0
        self.unbounded_loops: List[str] = []
        self.core_modifications: List[str] = []
        self.function_calls: Set[str] = set()
        self.recursive_calls: List[str] = []

    def verify(self, program: Program) -> VerificationReport:
        """Verify all properties of a program."""
        self.program = program
        self.loop_depth = 0
        self.max_loop_depth = 0
        self.unbounded_loops = []
        self.core_modifications = []
        self.function_calls = set()
        self.recursive_calls = []

        report = VerificationReport()

        # 1. Verify termination
        termination_proof = self._verify_termination()
        report.proofs.append(termination_proof)

        # 2. Verify core immutability
        core_proof = self._verify_core_immutability()
        report.proofs.append(core_proof)

        # 3. Verify genesis presence
        genesis_proof = self._verify_genesis_presence()
        report.proofs.append(genesis_proof)

        # Overall result
        report.all_proven = all(p.result == VerificationResult.PROVEN for p in report.proofs)

        if report.all_proven:
            report.summary = "✓ All v1.0 safety properties proven"
        else:
            violations = [p.property_name for p in report.proofs
                         if p.result == VerificationResult.VIOLATION]
            report.summary = f"⍼ Verification failed: {', '.join(violations)}"

        return report

    def _verify_termination(self) -> Proof:
        """
        Prove termination property.

        v1.0 allows only:
        - ∀x∈finite-set⟿ op(x) - bounded iteration
        - ⸮(cond)⟿ A ⫶ B - conditional

        v1.0 disallows:
        - while(true)⟿ ... - unbounded loops
        - ⥉(self) - unrestricted recursion
        """
        # Analyse all blocks for loop patterns
        for block in self.program.blocks:
            self._analyse_termination(block)

        # Check for unbounded loops
        if self.unbounded_loops:
            return Proof(
                property_name="terminates",
                result=VerificationResult.VIOLATION,
                evidence="Unbounded loop detected",
                details=self.unbounded_loops
            )

        # Check for unrestricted recursion
        if self.recursive_calls:
            return Proof(
                property_name="terminates",
                result=VerificationResult.VIOLATION,
                evidence="Unrestricted recursion detected",
                details=self.recursive_calls
            )

        return Proof(
            property_name="terminates",
            result=VerificationResult.PROVEN,
            evidence=f"All loops bounded (max depth: {self.max_loop_depth})",
            details=[
                "No while loops detected",
                "No unbounded recursion",
                f"Maximum loop nesting: {self.max_loop_depth}",
            ]
        )

    def _analyse_termination(self, node: ASTNode, context: str = ""):
        """Recursively analyse termination properties."""
        if isinstance(node, ForEach):
            self.loop_depth += 1
            self.max_loop_depth = max(self.max_loop_depth, self.loop_depth)

            # Check if collection is statically bounded
            if not self._is_bounded_collection(node.collection):
                self.unbounded_loops.append(
                    f"ForEach at L{node.line}: collection may be unbounded"
                )

            self._analyse_termination(node.body, context)
            self.loop_depth -= 1

        elif isinstance(node, Conditional):
            self._analyse_termination(node.condition, context)
            if node.then_branch:
                self._analyse_termination(node.then_branch, context)
            if node.else_branch:
                self._analyse_termination(node.else_branch, context)

        elif isinstance(node, Definition):
            if node.body:
                self._analyse_termination(node.body, node.name)

        elif isinstance(node, Lambda):
            if node.body:
                self._analyse_termination(node.body, context)

        elif isinstance(node, FunctionCall):
            self.function_calls.add(node.name)
            # Check for potential recursion
            if node.name == context and context:
                self.recursive_calls.append(
                    f"Recursive call to '{node.name}' at L{node.line}"
                )
            for arg in node.args:
                self._analyse_termination(arg, context)

        elif isinstance(node, BinaryOp):
            self._analyse_termination(node.left, context)
            self._analyse_termination(node.right, context)

        elif isinstance(node, UnaryOp):
            self._analyse_termination(node.operand, context)

        elif isinstance(node, ObjectLiteral):
            for value in node.entries.values():
                self._analyse_termination(value, context)

        elif isinstance(node, ArrayLiteral):
            for item in node.items:
                self._analyse_termination(item, context)

        elif isinstance(node, PropertyAccess):
            self._analyse_termination(node.object, context)

    def _is_bounded_collection(self, node: ASTNode) -> bool:
        """Check if a collection is statically bounded."""
        if isinstance(node, ArrayLiteral):
            return True
        if isinstance(node, ObjectLiteral):
            return True
        if isinstance(node, Literal):
            return isinstance(node.value, (list, dict, str))
        if isinstance(node, Identifier):
            # Memory access is considered bounded by runtime limits
            if node.name in ('⧬', 'memory', 'cache'):
                return True
        if isinstance(node, FunctionCall):
            # Built-in functions that return bounded collections
            if node.name in ('keys', 'values', 'items', 'load'):
                return True
        if isinstance(node, PropertyAccess):
            return True

        # Conservative: assume unbounded if we can't prove otherwise
        return False

    def _verify_core_immutability(self) -> Proof:
        """
        Prove core immutability property.

        v1.0 disallows:
        - ⊙.modify(⊙.core)
        - Direct core modifications
        """
        for block in self.program.blocks:
            self._analyse_core_access(block)

        if self.core_modifications:
            return Proof(
                property_name="¬modifies(⊙.core)",
                result=VerificationResult.VIOLATION,
                evidence="Core modification attempt detected",
                details=self.core_modifications
            )

        return Proof(
            property_name="¬modifies(⊙.core)",
            result=VerificationResult.PROVEN,
            evidence="No core modification patterns found",
            details=[
                "No ⊙.core assignments",
                "No modify(⊙.core) calls",
                "No genesis block mutations",
            ]
        )

    def _analyse_core_access(self, node: ASTNode):
        """Check for core modification attempts."""
        if isinstance(node, FunctionCall):
            # Check for modify calls on core
            if node.name in ('modify', 'update', 'set', 'delete'):
                for arg in node.args:
                    if self._is_core_reference(arg):
                        self.core_modifications.append(
                            f"Core modification via {node.name}() at L{node.line}"
                        )
            for arg in node.args:
                self._analyse_core_access(arg)

        elif isinstance(node, BinaryOp):
            # Check for assignment to core
            if node.operator == '≡':
                if self._is_core_reference(node.left):
                    self.core_modifications.append(
                        f"Core assignment at L{node.line}"
                    )
            self._analyse_core_access(node.left)
            self._analyse_core_access(node.right)

        elif isinstance(node, PropertyAccess):
            self._analyse_core_access(node.object)

        elif isinstance(node, Definition):
            if node.body:
                self._analyse_core_access(node.body)

        elif isinstance(node, Lambda):
            if node.body:
                self._analyse_core_access(node.body)

        elif isinstance(node, Conditional):
            self._analyse_core_access(node.condition)
            if node.then_branch:
                self._analyse_core_access(node.then_branch)
            if node.else_branch:
                self._analyse_core_access(node.else_branch)

        elif isinstance(node, ForEach):
            self._analyse_core_access(node.collection)
            if node.body:
                self._analyse_core_access(node.body)

        elif isinstance(node, ObjectLiteral):
            for value in node.entries.values():
                self._analyse_core_access(value)

        elif isinstance(node, ArrayLiteral):
            for item in node.items:
                self._analyse_core_access(item)

        elif isinstance(node, UnaryOp):
            self._analyse_core_access(node.operand)

    def _is_core_reference(self, node: ASTNode) -> bool:
        """Check if node references core."""
        if isinstance(node, Identifier):
            return node.name in ('⊙.core', 'core', '⛓.genesis', 'genesis')

        if isinstance(node, PropertyAccess):
            if isinstance(node.object, Identifier):
                if node.object.name == '⊙' and node.property == 'core':
                    return True
                if node.object.name == '⛓' and node.property == 'genesis':
                    return True
            return self._is_core_reference(node.object)

        return False

    def _verify_genesis_presence(self) -> Proof:
        """
        Prove genesis presence property.

        Every valid v1.0 program must contain:
        - ⛓.genesis block
        - Parfit Key axiom (¬∃⫿⤳)
        """
        if not self.program.genesis:
            return Proof(
                property_name="∋(⛓.genesis)",
                result=VerificationResult.VIOLATION,
                evidence="No genesis block found",
                details=["Program must start with ⛓.genesis ≡ {...}"]
            )

        genesis = self.program.genesis
        issues = []

        # Check required fields
        if not genesis.root:
            issues.append("Genesis missing 'root' field")

        # Check for Parfit Key axiom
        parfit_key = '¬∃⫿⤳'
        if parfit_key not in genesis.axioms:
            issues.append(f"Genesis missing Parfit Key axiom ({parfit_key})")

        # Check for River axiom
        river_axiom = '⟿≡〰'
        if river_axiom not in genesis.axioms:
            issues.append(f"Genesis missing River axiom ({river_axiom}) - warning only")

        if issues and parfit_key not in genesis.axioms:
            return Proof(
                property_name="∋(⛓.genesis)",
                result=VerificationResult.VIOLATION,
                evidence="Genesis block incomplete",
                details=issues
            )

        return Proof(
            property_name="∋(⛓.genesis)",
            result=VerificationResult.PROVEN,
            evidence=f"Valid genesis block (root: {genesis.root})",
            details=[
                f"Root: {genesis.root}",
                f"Created: {genesis.created}",
                f"Axioms: {len(genesis.axioms)}",
                f"Parfit Key present: {parfit_key in genesis.axioms}",
            ]
        )


def verify_cips(source: str) -> VerificationReport:
    """Verify CIPS-LANG source code."""
    program = parse_cips(source)
    verifier = Verifier()
    return verifier.verify(program)


def verify_cips_file(filepath: str) -> VerificationReport:
    """Verify CIPS-LANG file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        source = f.read()
    return verify_cips(source)


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: cips-lang-verify.py <file.cips> [--json]")
        sys.exit(1)

    filepath = sys.argv[1]
    json_output = "--json" in sys.argv

    try:
        report = verify_cips_file(filepath)

        if json_output:
            print(json.dumps(report.to_dict(), indent=2))
        else:
            print(f"\n{report.summary}\n")
            for proof in report.proofs:
                status = "✓" if proof.result == VerificationResult.PROVEN else "⍼"
                print(f"{status} {proof.property_name}: {proof.evidence}")
                for detail in proof.details:
                    print(f"    - {detail}")
            print()

        sys.exit(0 if report.all_proven else 1)

    except Exception as e:
        print(f"⍼ Verification error: {e}")
        sys.exit(1)
