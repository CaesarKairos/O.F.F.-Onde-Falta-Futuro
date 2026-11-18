"""Confirma que a direção artística adicionou somente marcações aos textos."""

import json
import re
import subprocess
from pathlib import Path


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DIALOGUE_PATH = Path("data/dialogues/chapter_01/chapter_01_scene_01.json")
TEXT_FIELDS = {"text", "eng", "es", "esp", "message", "message_en", "message_es"}
PAUSE = re.compile(r"\[pause=\d+\]")
TAGS = re.compile(r"\[/?(?:slow|fast|pop|whisper|impact)\]")


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
    baseline = subprocess.run(
        ["git", "show", f"refactor/project-structure:{DIALOGUE_PATH.as_posix()}"],
        cwd=PROJECT_ROOT,
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    before = json.loads(baseline.stdout)
    after = json.loads((PROJECT_ROOT / DIALOGUE_PATH).read_text(encoding="utf-8"))
    failures = compare(before, after)
    if failures:
        print("VALIDATION FAILED")
        print("\n".join(failures))
        return 1
    print("VALIDATION OK: roteiro e estrutura preservados; somente marcações foram adicionadas.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
