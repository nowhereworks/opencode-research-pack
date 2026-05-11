#!/usr/bin/env python3
import argparse
import datetime as _datetime
import re
import shutil
import sys
from pathlib import Path


ROOT = "."


COMMANDS = {
    "init",
    "paths",
    "researcher-files",
    "quality-files",
    "provenance",
    "deliver",
    "verify",
}


STOPWORDS = {
    "a",
    "an",
    "the",
    "and",
    "or",
    "of",
    "for",
    "to",
    "in",
    "on",
    "with",
    "about",
    "into",
    "from",
    "by",
    "is",
    "are",
    "be",
    "as",
    "at",
    "vs",
    "versus",
    "overview",
    "introduction",
    "guide",
    "analysis",
    "research",
    "deep",
    "comprehensive",
    "investigation",
    "report",
    "study",
    "current",
    "latest",
    "what",
    "which",
    "who",
    "whom",
    "whose",
    "when",
    "where",
    "why",
    "how",
    "does",
    "do",
    "did",
    "done",
    "can",
    "could",
    "should",
    "would",
    "will",
    "shall",
    "may",
    "might",
    "must",
    "have",
    "has",
    "had",
    "having",
    "impose",
    "imposes",
    "imposed",
}


def usage() -> None:
    lines = [
        f"Usage: {sys.argv[0]} [--root DIR] <command> [options]",
        "",
        "Commands:",
        "  init              Create deepresearch directories and the plan skeleton only",
        "  paths             Print canonical artifact paths",
        "  researcher-files  Create per-researcher brief skeletons",
        "  quality-files     Create search-log and evidence-matrix skeletons",
        "  provenance        Create a provenance skeleton next to the final artifact",
        "  deliver           Copy the final candidate to <slug>/outputs/ or <slug>/papers/",
        "  verify            Check artifact files only; does not verify research quality",
        "",
        "Common options:",
        "  --topic TEXT      Research topic used to derive a slug",
        "  --slug SLUG       Explicit slug, lowercase hyphenated, max 5 words",
        "  --force           Overwrite generated skeleton files",
        "  --verification S  Provenance status: PASS, PASS WITH NOTES, or BLOCKED",
        "  --allow-pending-artifact-check  Let post-approval verification accept Artifact check: PENDING",
        "",
        "Examples:",
        f"  {sys.argv[0]} init --topic 'Mechanistic interpretability for transformers'",
        f"  {sys.argv[0]} researcher-files --slug mechanistic-interpretability-transformers --count 3",
        f"  {sys.argv[0]} verify --slug mechanistic-interpretability-transformers --phase post-approval",
    ]
    print("\n".join(lines))


def die(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


class Parser(argparse.ArgumentParser):
    def error(self, message: str) -> None:
        if message.startswith("the following arguments are required: "):
            missing = message.removeprefix("the following arguments are required: ")
            if missing == "--count":
                die("--count must be a positive integer")
        die(message)


def build_parser(command: str) -> Parser:
    parser = Parser(add_help=False, allow_abbrev=False)
    parser.add_argument("-h", "--help", action="store_true")
    parser.add_argument("--topic", default="")
    parser.add_argument("--slug", default="")
    if command in {"init", "researcher-files", "quality-files", "provenance", "deliver"}:
        parser.add_argument("--force", action="store_true")
    if command == "researcher-files":
        parser.add_argument("--count", required=True)
    if command in {"provenance", "deliver", "verify"}:
        parser.add_argument("--dest", default="" if command == "verify" else "outputs")
    if command == "provenance":
        parser.add_argument("--verification", default="TODO")
    if command == "verify":
        parser.add_argument("--phase", default="")
        parser.add_argument("--allow-pending-artifact-check", action="store_true")
    return parser


def parse_command(command: str, argv: list[str]) -> argparse.Namespace:
    parser = build_parser(command)
    namespace, extras = parser.parse_known_args(argv)
    if namespace.help:
        usage()
        raise SystemExit(0)
    if extras:
        die(f"unknown {command} option: {extras[0]}")
    return namespace


def today() -> str:
    return _datetime.date.today().isoformat()


def slugify(text: str) -> str:
    lowered = text.lower()
    lowered = lowered.replace("general-purpose ai", "gpai")
    lowered = lowered.replace("general purpose ai", "gpai")
    lowered = lowered.replace("general-purpose artificial intelligence", "gpai")
    lowered = lowered.replace("general purpose artificial intelligence", "gpai")
    normalized = re.sub(r"[^a-z0-9]", "-", lowered)
    normalized = re.sub(r"-+", "-", normalized).strip("-")

    words = []
    for word in normalized.split("-"):
        if not word or word in STOPWORDS:
            continue
        words.append(word)
        if len(words) >= 5:
            break

    slug = "-".join(words) or "research"
    if slug.startswith("obligations-eu-ai-act-gpai"):
        slug = "eu-ai-act-gpai-obligations"
    return slug


def validate_slug(slug: str) -> None:
    if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", slug):
        die(f"invalid slug '{slug}'; use lowercase alphanumerics and hyphens")
    if len(slug.split("-")) > 5:
        die(f"invalid slug '{slug}'; use at most 5 hyphen-separated words")


def resolve_slug(topic: str, slug: str) -> str:
    if not slug:
        if not topic:
            die("provide --topic or --slug")
        slug = slugify(topic)
    validate_slug(slug)
    return slug


def artifact_root(slug: str) -> str:
    return f"{ROOT}/{slug}"


def ensure_dirs(slug: str) -> None:
    base = Path(artifact_root(slug))
    for directory in [
        base / "outputs" / ".plans",
        base / "outputs" / ".drafts",
        base / "outputs",
        base / "papers",
    ]:
        directory.mkdir(parents=True, exist_ok=True)


def path_plan(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/.plans/{slug}.md"


def path_researcher_brief(slug: str, number: int | str) -> str:
    return f"{ROOT}/{slug}/outputs/.plans/{slug}-T{number}.md"


def path_draft(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/.drafts/{slug}-draft.md"


def path_cited(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/.drafts/{slug}-cited.md"


def path_direct(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/.drafts/{slug}-research-direct.md"


def path_search_log(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/.drafts/{slug}-search-log.md"


def path_evidence_matrix(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/.drafts/{slug}-evidence-matrix.md"


def path_researcher_output(slug: str, number: int | str) -> str:
    return f"{ROOT}/{slug}/outputs/.drafts/{slug}-research-T{number}.md"


def relative_researcher_output(slug: str, number: int | str) -> str:
    return f"{slug}/outputs/.drafts/{slug}-research-T{number}.md"


def path_verification(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/.drafts/{slug}-verification.md"


def path_revised(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/.drafts/{slug}-revised.md"


def path_outputs_final(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/{slug}.md"


def path_outputs_provenance(slug: str) -> str:
    return f"{ROOT}/{slug}/outputs/{slug}.provenance.md"


def path_papers_final(slug: str) -> str:
    return f"{ROOT}/{slug}/papers/{slug}.md"


def path_papers_provenance(slug: str) -> str:
    return f"{ROOT}/{slug}/papers/{slug}.provenance.md"


def is_nonempty_file(path: str) -> bool:
    file_path = Path(path)
    return file_path.is_file() and file_path.stat().st_size > 0


def has_unresolved_marker(path: str) -> bool:
    file_path = Path(path)
    if not file_path.is_file():
        return False
    with file_path.open("r", encoding="utf-8") as handle:
        return any("REPLACE_ME" in line for line in handle)


def provenance_status_ok(path: str) -> bool:
    allowed = {
        "- **Verification:** PASS",
        "- **Verification:** PASS WITH NOTES",
        "- **Verification:** BLOCKED",
    }
    with Path(path).open("r", encoding="utf-8") as handle:
        return any(line.rstrip("\n") in allowed for line in handle)


def line_status_ok(path: str, label: str, statuses: tuple[str, ...]) -> bool:
    with Path(path).open("r", encoding="utf-8") as handle:
        for line in handle:
            normalized = line.replace("*", "").rstrip("\n")
            if label in normalized and any(normalized.endswith(status) for status in statuses):
                return True
    return False


def verification_status_ok(path: str) -> bool:
    return line_status_ok(path, "Verification:", ("PASS", "PASS WITH NOTES", "BLOCKED"))


def artifact_check_status_ok(path: str, allow_pending: bool) -> bool:
    statuses = ("PASS", "FAIL", "PENDING") if allow_pending else ("PASS", "FAIL")
    return line_status_ok(path, "Artifact check:", statuses)


def contains_text(path: str, needle: str) -> bool:
    with Path(path).open("r", encoding="utf-8") as handle:
        return any(needle in line for line in handle)


def verification_file_ok(path: str, allow_pending_artifact_check: bool) -> bool:
    failures = 0
    if not verification_status_ok(path):
        print(f"missing_or_invalid_verification_status={path}")
        failures += 1
    if not artifact_check_status_ok(path, allow_pending_artifact_check):
        print(f"missing_or_invalid_artifact_check={path}")
        failures += 1
    for needle in ["Blocked checks:", "FATAL", "MAJOR", "MINOR"]:
        if not contains_text(path, needle):
            print(f"missing_required_verification_field={path}:{needle}")
            failures += 1
    return failures == 0


def normalize_verification(value: str) -> str:
    if value in {"PASS", "BLOCKED"}:
        return value
    if value in {"PASS WITH NOTES", "PASS_WITH_NOTES"}:
        return "PASS WITH NOTES"
    if value in {"TODO", ""}:
        return "TODO"
    die("--verification must be PASS, PASS WITH NOTES, or BLOCKED")


def write_text(path: str, content: str) -> None:
    Path(path).write_text(content, encoding="utf-8")


def write_plan(topic: str, slug: str, path: str) -> None:
    title = topic or slug
    date = today()
    write_text(
        path,
        f"""# Deep Research Plan: {title}

- **Date:** {date}
- **Slug:** {slug}

## Key Questions

- REPLACE_ME: List the questions this research must answer.

## Evidence Needed

- REPLACE_ME: List primary sources, docs, papers, benchmarks, or artifacts needed.

## Scope Defaults

- **Audience:** technically literate generalist unless the topic implies specialist treatment.
- **Time range:** current state plus necessary historical context; prioritize the last 24 months for fast-moving topics.
- **Geography:** global unless jurisdiction-specific; for law, policy, market, tax, healthcare access, or regulation topics, use US/EU/global comparison if unspecified.
- **Source types:** primary sources first, then authoritative secondary analysis.
- **Exclusions:** low-quality SEO pages, unsourced AI-generated content, and social posts unless primary evidence.
- **Depth:** infer from request wording; simple explainers use direct mode, broad/deep/comprehensive requests use multi-agent mode when useful.
- **Destination:** outputs unless the user requests a paper-style artifact.
- **High-stakes topics:** apply higher scrutiny for medical, legal, finance, safety, security, policy, or welfare-impacting topics.

## Search Coverage Matrix

| Question | Search angles | Source types | Owner | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| REPLACE_ME | REPLACE_ME | REPLACE_ME | lead | pending | REPLACE_ME |

## Scale Decision

- REPLACE_ME: Choose direct search or researcher agents before assigning owners.

## Task Ledger

| Task | Owner | Status | Notes |
| --- | --- | --- | --- |
| Plan | lead | done | Initial artifact scaffold created. |

## Verification Log

- REPLACE_ME: Record checks performed and blocked checks.

## Decision Log

- REPLACE_ME: Record scope and evidence decisions.
""",
    )


def print_paths(slug: str) -> None:
    print(f"slug={slug}")
    print(f"plan={path_plan(slug)}")
    print(f"direct_research={path_direct(slug)}")
    print(f"search_log={path_search_log(slug)}")
    print(f"evidence_matrix={path_evidence_matrix(slug)}")
    print(f"draft={path_draft(slug)}")
    print(f"cited={path_cited(slug)}")
    print(f"verification={path_verification(slug)}")
    print(f"revised={path_revised(slug)}")
    print(f"outputs_final={path_outputs_final(slug)}")
    print(f"outputs_provenance={path_outputs_provenance(slug)}")
    print(f"papers_final={path_papers_final(slug)}")
    print(f"papers_provenance={path_papers_provenance(slug)}")


def command_init(args: argparse.Namespace) -> None:
    slug = resolve_slug(args.topic, args.slug)
    ensure_dirs(slug)
    plan = path_plan(slug)
    if Path(plan).exists() and not args.force:
        print(f"plan_exists={plan}")
    else:
        write_plan(args.topic, slug, plan)
        print(f"plan_created={plan}")
    print_paths(slug)


def command_paths(args: argparse.Namespace) -> None:
    slug = resolve_slug(args.topic, args.slug)
    print_paths(slug)


def command_researcher_files(args: argparse.Namespace) -> None:
    slug = resolve_slug(args.topic, args.slug)
    if not re.fullmatch(r"[1-9][0-9]*", args.count or ""):
        die("--count must be a positive integer")
    count = int(args.count)
    ensure_dirs(slug)
    for index in range(1, count + 1):
        brief = path_researcher_brief(slug, index)
        research_path = relative_researcher_output(slug, index)
        research_abs_path = path_researcher_output(slug, index)
        if Path(brief).exists() and not args.force:
            print(f"brief_exists={brief}")
            continue
        title = args.topic or slug
        write_text(
            brief,
            f"""# Researcher Brief T{index}: {title}

- **Slug:** {slug}
- **Assigned output:** {research_path}

## Scope

- REPLACE_ME: Define this researcher's sub-question and boundaries.

## Evidence Targets

- REPLACE_ME: List source types, search angles, inclusion criteria, and exclusion criteria.

## Output Requirements

- Write findings to `{research_path}`.
- Record search terms, accepted sources, rejected sources, and follow-up gaps.
- Include an evidence table with stable source IDs, source type, confidence, and contradiction notes.
- Include source URLs or artifact paths for every critical claim.
- Mark unavailable PDF parsing, dead links, or missing evidence as blocked.
""",
        )
        print(f"brief_created={brief}")
        print(f"research_output_path={research_abs_path}")


def command_quality_files(args: argparse.Namespace) -> None:
    slug = resolve_slug(args.topic, args.slug)
    ensure_dirs(slug)
    date = today()
    title = args.topic or slug
    search_log = path_search_log(slug)
    evidence_matrix = path_evidence_matrix(slug)

    if Path(search_log).exists() and not args.force:
        print(f"search_log_exists={search_log}")
    else:
        write_text(
            search_log,
            f"""# Search Log: {title}

- **Date:** {date}
- **Slug:** {slug}

| # | Date | Tool/source | Query or action | Angle | Result count | Accepted sources | Rejected sources | Follow-up gaps |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | {date} | REPLACE_ME | REPLACE_ME | REPLACE_ME | REPLACE_ME | REPLACE_ME | REPLACE_ME | REPLACE_ME |

## Notes

- REPLACE_ME: Record citation chasing, unavailable tools, blocked PDF/full-text checks, and degraded coverage.
""",
        )
        print(f"search_log_created={search_log}")

    if Path(evidence_matrix).exists() and not args.force:
        print(f"evidence_matrix_exists={evidence_matrix}")
    else:
        write_text(
            evidence_matrix,
            f"""# Evidence Matrix: {title}

- **Date:** {date}
- **Slug:** {slug}

| # | Question/theme | Claim | Quote or locator | Source URL/DOI/path | Source type | Confidence | Contradiction notes | Verification status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | REPLACE_ME | REPLACE_ME | REPLACE_ME | REPLACE_ME | primary / secondary / artifact | low / medium / high | REPLACE_ME | unchecked |

## Coverage Status

- REPLACE_ME: List answered questions, unanswered questions, single-source critical claims, stale sources, and blocked checks.
""",
        )
        print(f"evidence_matrix_created={evidence_matrix}")


def command_provenance(args: argparse.Namespace) -> None:
    if args.dest not in {"outputs", "papers"}:
        die("--dest must be outputs or papers")
    verification = normalize_verification(args.verification)
    slug = resolve_slug(args.topic, args.slug)
    ensure_dirs(slug)
    provenance = path_papers_provenance(slug) if args.dest == "papers" else path_outputs_provenance(slug)
    if Path(provenance).exists() and not args.force:
        print(f"provenance_exists={provenance}")
        return
    title = args.topic or slug
    write_text(
        provenance,
        f"""# Provenance: {title}

- **Date:** {today()}
- **Rounds:** REPLACE_ME
- **Sources consulted:** REPLACE_ME
- **Sources accepted:** REPLACE_ME
- **Sources rejected:** REPLACE_ME
- **Verification:** {verification}
- **Artifact check:** REPLACE_ME
- **Plan:** {slug}/outputs/.plans/{slug}.md
- **Research files:** REPLACE_ME
""",
    )
    print(f"provenance_created={provenance}")


def command_deliver(args: argparse.Namespace) -> None:
    if args.dest not in {"outputs", "papers"}:
        die("--dest must be outputs or papers")
    slug = resolve_slug(args.topic, args.slug)
    ensure_dirs(slug)
    if is_nonempty_file(path_revised(slug)):
        candidate = path_revised(slug)
    elif is_nonempty_file(path_cited(slug)):
        candidate = path_cited(slug)
    else:
        die("no non-empty final candidate found; expected revised or cited draft")

    if args.dest == "papers":
        final = path_papers_final(slug)
        provenance = path_papers_provenance(slug)
    else:
        final = path_outputs_final(slug)
        provenance = path_outputs_provenance(slug)

    if Path(final).exists() and not args.force:
        die(f"final artifact already exists: {final}; use --force to overwrite")
    shutil.copyfile(candidate, final)
    print(f"candidate={candidate}")
    print(f"final={final}")
    if not Path(provenance).exists():
        print(f"warning=provenance_missing:{provenance}")


def command_verify(args: argparse.Namespace) -> None:
    if args.phase not in {"pre-approval", "post-approval"}:
        die("--phase must be pre-approval or post-approval")
    if args.dest and args.dest not in {"outputs", "papers"}:
        die("--dest must be outputs or papers")
    if args.phase != "post-approval" and args.allow_pending_artifact_check:
        die("--allow-pending-artifact-check requires --phase post-approval")
    slug = resolve_slug(args.topic, args.slug)
    failures = 0

    for path in [
        artifact_root(slug),
        f"{artifact_root(slug)}/outputs/.plans",
        f"{artifact_root(slug)}/outputs/.drafts",
        f"{artifact_root(slug)}/outputs",
        f"{artifact_root(slug)}/papers",
    ]:
        if not Path(path).is_dir():
            print(f"missing_dir={path}")
            failures += 1

    plan = path_plan(slug)
    if not is_nonempty_file(plan):
        print(f"missing_or_empty={plan}")
        failures += 1
    elif has_unresolved_marker(plan):
        print(f"unresolved_marker={plan}")
        failures += 1

    if args.phase == "pre-approval":
        for path in [
            path_draft(slug),
            path_cited(slug),
            path_search_log(slug),
            path_evidence_matrix(slug),
            path_outputs_final(slug),
            path_outputs_provenance(slug),
            path_papers_final(slug),
            path_papers_provenance(slug),
        ]:
            if Path(path).exists():
                print(f"unexpected_post_approval_artifact={path}")
                failures += 1
    else:
        for path in [
            path_draft(slug),
            path_cited(slug),
            path_search_log(slug),
            path_evidence_matrix(slug),
            path_verification(slug),
        ]:
            if not is_nonempty_file(path):
                print(f"missing_or_empty={path}")
                failures += 1
            elif has_unresolved_marker(path):
                print(f"unresolved_marker={path}")
                failures += 1

        verification = path_verification(slug)
        if is_nonempty_file(verification) and not has_unresolved_marker(verification):
            if not verification_file_ok(verification, args.allow_pending_artifact_check):
                failures += 1

        final = ""
        provenance = ""
        if args.dest in {"outputs", ""}:
            if is_nonempty_file(path_outputs_final(slug)):
                final = path_outputs_final(slug)
                provenance = path_outputs_provenance(slug)
        if args.dest == "papers" or (not args.dest and not final):
            if is_nonempty_file(path_papers_final(slug)):
                final = path_papers_final(slug)
                provenance = path_papers_provenance(slug)
        if not final:
            print(f"missing_final={slug}/outputs_or_papers/{slug}.md")
            failures += 1
        elif not is_nonempty_file(provenance):
            print(f"missing_or_empty={provenance}")
            failures += 1
        elif has_unresolved_marker(provenance):
            print(f"unresolved_marker={provenance}")
            failures += 1
        elif not provenance_status_ok(provenance):
            print(f"invalid_verification_status={provenance}")
            failures += 1
        elif not artifact_check_status_ok(provenance, False):
            print(f"missing_or_invalid_artifact_check={provenance}")
            failures += 1

    if failures == 0:
        print("artifact_check=PASS")
        print("verification=PASS")
    else:
        print("artifact_check=FAIL")
        print("verification=FAIL")
        raise SystemExit(1)


def main(argv: list[str]) -> int:
    global ROOT
    if not argv:
        usage()
        return 1
    index = 0
    while index < len(argv):
        value = argv[index]
        if value == "--root":
            if index + 1 >= len(argv) or not argv[index + 1] or argv[index + 1].startswith("--"):
                die("--root requires a value")
            ROOT = argv[index + 1]
            index += 2
        elif value in {"-h", "--help"}:
            usage()
            return 0
        elif value in COMMANDS:
            command = value
            args = parse_command(command, argv[index + 1 :])
            globals()[f"command_{command.replace('-', '_')}"](args)
            return 0
        else:
            die(f"unknown command or global option: {value}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
