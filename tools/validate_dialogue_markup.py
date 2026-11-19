"""Confirma que a direção artística adicionou somente marcações aos textos."""

import json
import re
import subprocess
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
BASELINE_REF = "ad46fd5"
SCENE_01_BASELINE_REF = "c2c01c2"
DIALOGUE_PATHS = sorted(Path("data/dialogues").rglob("*.json"))
TEXT_FIELDS = {"text", "eng", "es", "esp", "message", "message_en", "message_es"}
PAUSE = re.compile(r"\[pause=\d+\]")
TAGS = re.compile(r"\[/?(?:slow|fast|pop|whisper|impact)\]")
TOKENS = re.compile(
    r"(?<!\\)(\*|~|\[(?:pause=\d+|/?(?:slow|fast|pop|whisper|impact))\])"
)
BRACKET_MARKUP = re.compile(r"(?<!\\)\[[^\]]+\]")


def strip_markup(value: str) -> str:
    value = PAUSE.sub("", value)
    value = TAGS.sub("", value)
    output: list[str] = []
    escaped = False
    for character in value:
        if escaped:
            output.append(character)
            escaped = False
        elif character == "\\":
            escaped = True
        elif character not in "*~":
            output.append(character)
    if escaped:
        output.append("\\")
    return "".join(output)


def validate_markup(value: str, path: str) -> list[str]:
    failures: list[str] = []
    known_brackets = {match.group(0) for match in TOKENS.finditer(value) if match.group(0).startswith("[")}
    for match in BRACKET_MARKUP.finditer(value):
        if match.group(0) not in known_brackets:
            failures.append(f"{path}: marcação desconhecida {match.group(0)!r}")

    stack: list[str] = []
    for match in TOKENS.finditer(value):
        token = match.group(0)
        if token.startswith("[pause="):
            continue
        if token in {"*", "~"}:
            if stack and stack[-1] == token:
                stack.pop()
            else:
                stack.append(token)
            continue
        if token.startswith("[/"):
            effect = token[2:-1]
            if not stack or stack[-1] != effect:
                failures.append(f"{path}: fechamento incompatível {token!r}")
            else:
                stack.pop()
        else:
            stack.append(token[1:-1])
    if stack:
        failures.append(f"{path}: marcações não fechadas {stack!r}")
    return failures


def compare(before, after, path="root") -> list[str]:
    failures: list[str] = []
    if type(before) is not type(after):
        return [f"{path}: tipo alterado"]
    if isinstance(before, dict):
        if before.keys() != after.keys():
            failures.append(f"{path}: chaves alteradas")
        for key in before.keys() & after.keys():
            child_path = f"{path}.{key}"
            if key in TEXT_FIELDS and isinstance(before[key], str):
                if strip_markup(after[key]) != before[key]:
                    failures.append(f"{child_path}: conteúdo original alterado")
                failures.extend(validate_markup(after[key], child_path))
            else:
                failures.extend(compare(before[key], after[key], child_path))
    elif isinstance(before, list):
        if len(before) != len(after):
            failures.append(f"{path}: tamanho da lista alterado")
        for index, (old, new) in enumerate(zip(before, after)):
            failures.extend(compare(old, new, f"{path}[{index}]"))
    elif before != after:
        failures.append(f"{path}: {before!r} != {after!r}")
    return failures


def main() -> int:
    failures: list[str] = []
    for dialogue_path in DIALOGUE_PATHS:
        baseline_ref = (
            SCENE_01_BASELINE_REF
            if dialogue_path.name == "chapter_01_scene_01.json"
            else BASELINE_REF
        )
        baseline = subprocess.run(
            ["git", "show", f"{baseline_ref}:{dialogue_path.as_posix()}"],
            cwd=PROJECT_ROOT,
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
        before = json.loads(baseline.stdout)
        after = json.loads((PROJECT_ROOT / dialogue_path).read_text(encoding="utf-8"))
        failures.extend(compare(before, after, dialogue_path.as_posix()))
    if failures:
        print("VALIDATION FAILED")
        print("\n".join(failures))
        return 1
    print("VALIDATION OK: roteiro e estrutura preservados; somente marcações foram adicionadas.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
