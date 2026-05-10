#!/usr/bin/env bash
set -euo pipefail

ROOT="."

usage() {
  printf '%s\n' "Usage: $0 [--root DIR] <command> [options]"
  printf '%s\n' ""
  printf '%s\n' "Commands:"
  printf '%s\n' "  init              Create deepresearch directories and the plan skeleton only"
  printf '%s\n' "  paths             Print canonical artifact paths"
  printf '%s\n' "  researcher-files  Create per-researcher brief skeletons"
  printf '%s\n' "  quality-files     Create search-log and evidence-matrix skeletons"
  printf '%s\n' "  provenance        Create a provenance skeleton next to the final artifact"
  printf '%s\n' "  deliver           Copy the final candidate to <slug>/outputs/ or <slug>/papers/"
  printf '%s\n' "  verify            Check artifact files only; does not verify research quality"
  printf '%s\n' ""
  printf '%s\n' "Common options:"
  printf '%s\n' "  --topic TEXT      Research topic used to derive a slug"
  printf '%s\n' "  --slug SLUG       Explicit slug, lowercase hyphenated, max 5 words"
  printf '%s\n' "  --force           Overwrite generated skeleton files"
  printf '%s\n' "  --verification S  Provenance status: PASS, PASS WITH NOTES, or BLOCKED"
  printf '%s\n' ""
  printf '%s\n' "Examples:"
  printf '%s\n' "  $0 init --topic 'Mechanistic interpretability for transformers'"
  printf '%s\n' "  $0 researcher-files --slug mechanistic-interpretability-transformers --count 3"
  printf '%s\n' "  $0 verify --slug mechanistic-interpretability-transformers --phase post-approval"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

need_value() {
  local flag="$1"
  local value="${2-}"
  [[ -n "$value" && "$value" != --* ]] || die "$flag requires a value"
}

slugify() {
  local text="$1"
  local normalized=""
  local word=""
  local slug=""
  local count=0

  normalized=$(printf '%s' "$text" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' '-')
  while [[ "$normalized" == *--* ]]; do
    normalized="${normalized//--/-}"
  done
  normalized="${normalized#-}"
  normalized="${normalized%-}"

  IFS='-' read -r -a words <<< "$normalized"
  for word in "${words[@]}"; do
    [[ -n "$word" ]] || continue
    case "$word" in
      a|an|the|and|or|of|for|to|in|on|with|about|into|from|by|is|are|be|as|at|vs|versus|overview|introduction|guide|analysis|research|deep|comprehensive|investigation|report|study|current|latest)
        continue
        ;;
    esac
    if [[ -z "$slug" ]]; then
      slug="$word"
    else
      slug="$slug-$word"
    fi
    count=$((count + 1))
    [[ "$count" -ge 5 ]] && break
  done

  [[ -n "$slug" ]] || slug="research"
  printf '%s\n' "$slug"
}

validate_slug() {
  local slug="$1"
  [[ "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "invalid slug '$slug'; use lowercase alphanumerics and hyphens"
  local hyphen_count="${slug//[^-]/}"
  local word_count=$(( ${#hyphen_count} + 1 ))
  [[ "$word_count" -le 5 ]] || die "invalid slug '$slug'; use at most 5 hyphen-separated words"
}

resolve_slug() {
  local topic="$1"
  local slug="$2"
  if [[ -z "$slug" ]]; then
    [[ -n "$topic" ]] || die "provide --topic or --slug"
    slug=$(slugify "$topic")
  fi
  validate_slug "$slug"
  printf '%s\n' "$slug"
}

artifact_root() { printf '%s/%s\n' "$ROOT" "$1"; }

ensure_dirs() {
  local slug="$1"
  local base
  base=$(artifact_root "$slug")
  mkdir -p "$base/outputs/.plans" "$base/outputs/.drafts" "$base/outputs" "$base/papers"
}

path_plan() { printf '%s/%s/outputs/.plans/%s.md\n' "$ROOT" "$1" "$1"; }
path_researcher_brief() { printf '%s/%s/outputs/.plans/%s-T%s.md\n' "$ROOT" "$1" "$1" "$2"; }
path_draft() { printf '%s/%s/outputs/.drafts/%s-draft.md\n' "$ROOT" "$1" "$1"; }
path_cited() { printf '%s/%s/outputs/.drafts/%s-cited.md\n' "$ROOT" "$1" "$1"; }
path_direct() { printf '%s/%s/outputs/.drafts/%s-research-direct.md\n' "$ROOT" "$1" "$1"; }
path_search_log() { printf '%s/%s/outputs/.drafts/%s-search-log.md\n' "$ROOT" "$1" "$1"; }
path_evidence_matrix() { printf '%s/%s/outputs/.drafts/%s-evidence-matrix.md\n' "$ROOT" "$1" "$1"; }
path_researcher_output() { printf '%s/%s/outputs/.drafts/%s-research-T%s.md\n' "$ROOT" "$1" "$1" "$2"; }
relative_researcher_output() { printf '%s/outputs/.drafts/%s-research-T%s.md\n' "$1" "$1" "$2"; }
path_verification() { printf '%s/%s/outputs/.drafts/%s-verification.md\n' "$ROOT" "$1" "$1"; }
path_revised() { printf '%s/%s/outputs/.drafts/%s-revised.md\n' "$ROOT" "$1" "$1"; }
path_outputs_final() { printf '%s/%s/outputs/%s.md\n' "$ROOT" "$1" "$1"; }
path_outputs_provenance() { printf '%s/%s/outputs/%s.provenance.md\n' "$ROOT" "$1" "$1"; }
path_papers_final() { printf '%s/%s/papers/%s.md\n' "$ROOT" "$1" "$1"; }
path_papers_provenance() { printf '%s/%s/papers/%s.provenance.md\n' "$ROOT" "$1" "$1"; }

is_nonempty_file() {
  [[ -f "$1" && -s "$1" ]]
}

provenance_status_ok() {
  local path="$1"
  local line
  while IFS= read -r line; do
    case "$line" in
      "- **Verification:** PASS"|"- **Verification:** PASS WITH NOTES"|"- **Verification:** BLOCKED")
        return 0
        ;;
    esac
  done < "$path"
  return 1
}

normalize_verification() {
  local value="$1"
  case "$value" in
    PASS|BLOCKED)
      printf '%s\n' "$value"
      ;;
    "PASS WITH NOTES"|PASS_WITH_NOTES)
      printf '%s\n' "PASS WITH NOTES"
      ;;
    TODO|"")
      printf '%s\n' "TODO"
      ;;
    *)
      die "--verification must be PASS, PASS WITH NOTES, or BLOCKED"
      ;;
  esac
}

write_plan() {
  local topic="$1"
  local slug="$2"
  local path="$3"
  local today
  today=$(date +%F)
  cat > "$path" <<EOF
# Deep Research Plan: ${topic:-$slug}

- **Date:** $today
- **Slug:** $slug

## Key Questions

- TODO: List the questions this research must answer.

## Evidence Needed

- TODO: List primary sources, docs, papers, benchmarks, or artifacts needed.

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
| TODO | TODO | TODO | lead | pending | TODO |

## Scale Decision

- TODO: Choose direct search or researcher agents before assigning owners.

## Task Ledger

| Task | Owner | Status | Notes |
| --- | --- | --- | --- |
| Plan | lead | done | Initial artifact scaffold created. |

## Verification Log

- TODO: Record checks performed and blocked checks.

## Decision Log

- TODO: Record scope and evidence decisions.
EOF
}

print_paths() {
  local slug="$1"
  printf 'slug=%s\n' "$slug"
  printf 'plan=%s\n' "$(path_plan "$slug")"
  printf 'direct_research=%s\n' "$(path_direct "$slug")"
  printf 'search_log=%s\n' "$(path_search_log "$slug")"
  printf 'evidence_matrix=%s\n' "$(path_evidence_matrix "$slug")"
  printf 'draft=%s\n' "$(path_draft "$slug")"
  printf 'cited=%s\n' "$(path_cited "$slug")"
  printf 'verification=%s\n' "$(path_verification "$slug")"
  printf 'revised=%s\n' "$(path_revised "$slug")"
  printf 'outputs_final=%s\n' "$(path_outputs_final "$slug")"
  printf 'outputs_provenance=%s\n' "$(path_outputs_provenance "$slug")"
  printf 'papers_final=%s\n' "$(path_papers_final "$slug")"
  printf 'papers_provenance=%s\n' "$(path_papers_provenance "$slug")"
}

command_init() {
  local topic=""
  local slug=""
  local force=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --topic) need_value "$1" "${2-}"; topic="$2"; shift 2 ;;
      --slug) need_value "$1" "${2-}"; slug="$2"; shift 2 ;;
      --force) force=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown init option: $1" ;;
    esac
  done

  slug=$(resolve_slug "$topic" "$slug")
  ensure_dirs "$slug"
  local plan
  plan=$(path_plan "$slug")
  if [[ -e "$plan" && "$force" -ne 1 ]]; then
    printf 'plan_exists=%s\n' "$plan"
  else
    write_plan "$topic" "$slug" "$plan"
    printf 'plan_created=%s\n' "$plan"
  fi
  print_paths "$slug"
}

command_paths() {
  local topic=""
  local slug=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --topic) need_value "$1" "${2-}"; topic="$2"; shift 2 ;;
      --slug) need_value "$1" "${2-}"; slug="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown paths option: $1" ;;
    esac
  done
  slug=$(resolve_slug "$topic" "$slug")
  print_paths "$slug"
}

command_researcher_files() {
  local topic=""
  local slug=""
  local count=""
  local force=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --topic) need_value "$1" "${2-}"; topic="$2"; shift 2 ;;
      --slug) need_value "$1" "${2-}"; slug="$2"; shift 2 ;;
      --count) need_value "$1" "${2-}"; count="$2"; shift 2 ;;
      --force) force=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown researcher-files option: $1" ;;
    esac
  done
  slug=$(resolve_slug "$topic" "$slug")
  [[ "$count" =~ ^[1-9][0-9]*$ ]] || die "--count must be a positive integer"
  ensure_dirs "$slug"

  local i brief research_path research_abs_path
  for ((i = 1; i <= count; i++)); do
    brief=$(path_researcher_brief "$slug" "$i")
    research_path=$(relative_researcher_output "$slug" "$i")
    research_abs_path=$(path_researcher_output "$slug" "$i")
    if [[ -e "$brief" && "$force" -ne 1 ]]; then
      printf 'brief_exists=%s\n' "$brief"
      continue
    fi
    cat > "$brief" <<EOF
# Researcher Brief T${i}: ${topic:-$slug}

- **Slug:** $slug
- **Assigned output:** $research_path

## Scope

- TODO: Define this researcher's sub-question and boundaries.

## Evidence Targets

- TODO: List source types, search angles, inclusion criteria, and exclusion criteria.

## Output Requirements

- Write findings to \`$research_path\`.
- Record search terms, accepted sources, rejected sources, and follow-up gaps.
- Include an evidence table with stable source IDs, source type, confidence, and contradiction notes.
- Include source URLs or artifact paths for every critical claim.
- Mark unavailable PDF parsing, dead links, or missing evidence as blocked.
EOF
    printf 'brief_created=%s\n' "$brief"
    printf 'research_output_path=%s\n' "$research_abs_path"
  done
}

command_quality_files() {
  local topic=""
  local slug=""
  local force=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --topic) need_value "$1" "${2-}"; topic="$2"; shift 2 ;;
      --slug) need_value "$1" "${2-}"; slug="$2"; shift 2 ;;
      --force) force=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown quality-files option: $1" ;;
    esac
  done
  slug=$(resolve_slug "$topic" "$slug")
  ensure_dirs "$slug"

  local search_log evidence_matrix today
  today=$(date +%F)
  search_log=$(path_search_log "$slug")
  evidence_matrix=$(path_evidence_matrix "$slug")

  if [[ -e "$search_log" && "$force" -ne 1 ]]; then
    printf 'search_log_exists=%s\n' "$search_log"
  else
    cat > "$search_log" <<EOF
# Search Log: ${topic:-$slug}

- **Date:** $today
- **Slug:** $slug

| # | Date | Tool/source | Query or action | Angle | Result count | Accepted sources | Rejected sources | Follow-up gaps |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | $today | TODO | TODO | TODO | TODO | TODO | TODO | TODO |

## Notes

- TODO: Record citation chasing, unavailable tools, blocked PDF/full-text checks, and degraded coverage.
EOF
    printf 'search_log_created=%s\n' "$search_log"
  fi

  if [[ -e "$evidence_matrix" && "$force" -ne 1 ]]; then
    printf 'evidence_matrix_exists=%s\n' "$evidence_matrix"
  else
    cat > "$evidence_matrix" <<EOF
# Evidence Matrix: ${topic:-$slug}

- **Date:** $today
- **Slug:** $slug

| # | Question/theme | Claim | Quote or locator | Source URL/DOI/path | Source type | Confidence | Contradiction notes | Verification status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | TODO | TODO | TODO | TODO | primary / secondary / artifact | low / medium / high | TODO | unchecked |

## Coverage Status

- TODO: List answered questions, unanswered questions, single-source critical claims, stale sources, and blocked checks.
EOF
    printf 'evidence_matrix_created=%s\n' "$evidence_matrix"
  fi
}

command_provenance() {
  local topic=""
  local slug=""
  local dest="outputs"
  local verification="TODO"
  local force=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --topic) need_value "$1" "${2-}"; topic="$2"; shift 2 ;;
      --slug) need_value "$1" "${2-}"; slug="$2"; shift 2 ;;
      --dest) need_value "$1" "${2-}"; dest="$2"; shift 2 ;;
      --verification) need_value "$1" "${2-}"; verification=$(normalize_verification "$2"); shift 2 ;;
      --force) force=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown provenance option: $1" ;;
    esac
  done
  [[ "$dest" == "outputs" || "$dest" == "papers" ]] || die "--dest must be outputs or papers"
  slug=$(resolve_slug "$topic" "$slug")
  ensure_dirs "$slug"

  local provenance today
  today=$(date +%F)
  if [[ "$dest" == "papers" ]]; then
    provenance=$(path_papers_provenance "$slug")
  else
    provenance=$(path_outputs_provenance "$slug")
  fi
  if [[ -e "$provenance" && "$force" -ne 1 ]]; then
    printf 'provenance_exists=%s\n' "$provenance"
    return 0
  fi
  cat > "$provenance" <<EOF
# Provenance: ${topic:-$slug}

- **Date:** $today
- **Rounds:** TODO
- **Sources consulted:** TODO
- **Sources accepted:** TODO
- **Sources rejected:** TODO
- **Verification:** $verification
- **Artifact check:** TODO
- **Plan:** $slug/outputs/.plans/$slug.md
- **Research files:** TODO
EOF
  printf 'provenance_created=%s\n' "$provenance"
}

command_deliver() {
  local topic=""
  local slug=""
  local dest="outputs"
  local force=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --topic) need_value "$1" "${2-}"; topic="$2"; shift 2 ;;
      --slug) need_value "$1" "${2-}"; slug="$2"; shift 2 ;;
      --dest) need_value "$1" "${2-}"; dest="$2"; shift 2 ;;
      --force) force=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown deliver option: $1" ;;
    esac
  done
  [[ "$dest" == "outputs" || "$dest" == "papers" ]] || die "--dest must be outputs or papers"
  slug=$(resolve_slug "$topic" "$slug")
  ensure_dirs "$slug"

  local candidate final provenance
  if is_nonempty_file "$(path_revised "$slug")"; then
    candidate=$(path_revised "$slug")
  elif is_nonempty_file "$(path_cited "$slug")"; then
    candidate=$(path_cited "$slug")
  else
    die "no non-empty final candidate found; expected revised or cited draft"
  fi

  if [[ "$dest" == "papers" ]]; then
    final=$(path_papers_final "$slug")
    provenance=$(path_papers_provenance "$slug")
  else
    final=$(path_outputs_final "$slug")
    provenance=$(path_outputs_provenance "$slug")
  fi

  if [[ -e "$final" && "$force" -ne 1 ]]; then
    die "final artifact already exists: $final; use --force to overwrite"
  fi
  cp "$candidate" "$final"
  printf 'candidate=%s\n' "$candidate"
  printf 'final=%s\n' "$final"
  if [[ ! -e "$provenance" ]]; then
    printf 'warning=provenance_missing:%s\n' "$provenance"
  fi
}

command_verify() {
  local topic=""
  local slug=""
  local phase=""
  local dest=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --topic) need_value "$1" "${2-}"; topic="$2"; shift 2 ;;
      --slug) need_value "$1" "${2-}"; slug="$2"; shift 2 ;;
      --phase) need_value "$1" "${2-}"; phase="$2"; shift 2 ;;
      --dest) need_value "$1" "${2-}"; dest="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown verify option: $1" ;;
    esac
  done
  [[ "$phase" == "pre-approval" || "$phase" == "post-approval" ]] || die "--phase must be pre-approval or post-approval"
  [[ -z "$dest" || "$dest" == "outputs" || "$dest" == "papers" ]] || die "--dest must be outputs or papers"
  slug=$(resolve_slug "$topic" "$slug")

  local failures=0
  local path
  for path in \
    "$(artifact_root "$slug")" \
    "$(artifact_root "$slug")/outputs/.plans" \
    "$(artifact_root "$slug")/outputs/.drafts" \
    "$(artifact_root "$slug")/outputs" \
    "$(artifact_root "$slug")/papers"; do
    if [[ ! -d "$path" ]]; then
      printf 'missing_dir=%s\n' "$path"
      failures=$((failures + 1))
    fi
  done

  if ! is_nonempty_file "$(path_plan "$slug")"; then
    printf 'missing_or_empty=%s\n' "$(path_plan "$slug")"
    failures=$((failures + 1))
  fi

  if [[ "$phase" == "pre-approval" ]]; then
    for path in \
      "$(path_draft "$slug")" \
      "$(path_cited "$slug")" \
      "$(path_search_log "$slug")" \
      "$(path_evidence_matrix "$slug")" \
      "$(path_outputs_final "$slug")" \
      "$(path_outputs_provenance "$slug")" \
      "$(path_papers_final "$slug")" \
      "$(path_papers_provenance "$slug")"; do
      if [[ -e "$path" ]]; then
        printf 'unexpected_post_approval_artifact=%s\n' "$path"
        failures=$((failures + 1))
      fi
    done
  else
    for path in \
      "$(path_draft "$slug")" \
      "$(path_cited "$slug")" \
      "$(path_search_log "$slug")" \
      "$(path_evidence_matrix "$slug")"; do
      if ! is_nonempty_file "$path"; then
        printf 'missing_or_empty=%s\n' "$path"
        failures=$((failures + 1))
      fi
    done

    local final=""
    local provenance=""
    if [[ "$dest" == "outputs" || -z "$dest" ]]; then
      if is_nonempty_file "$(path_outputs_final "$slug")"; then
        final=$(path_outputs_final "$slug")
        provenance=$(path_outputs_provenance "$slug")
      fi
    fi
    if [[ "$dest" == "papers" || ( -z "$dest" && -z "$final" ) ]]; then
      if is_nonempty_file "$(path_papers_final "$slug")"; then
        final=$(path_papers_final "$slug")
        provenance=$(path_papers_provenance "$slug")
      fi
    fi
    if [[ -z "$final" ]]; then
      printf 'missing_final=%s/outputs_or_papers/%s.md\n' "$slug" "$slug"
      failures=$((failures + 1))
    elif ! is_nonempty_file "$provenance"; then
      printf 'missing_or_empty=%s\n' "$provenance"
      failures=$((failures + 1))
    elif ! provenance_status_ok "$provenance"; then
      printf 'invalid_verification_status=%s\n' "$provenance"
      failures=$((failures + 1))
    fi
  fi

  if [[ "$failures" -eq 0 ]]; then
    printf 'artifact_check=PASS\n'
    printf 'verification=PASS\n'
  else
    printf 'artifact_check=FAIL\n'
    printf 'verification=FAIL\n'
    exit 1
  fi
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root) need_value "$1" "${2-}"; ROOT="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    init|paths|researcher-files|quality-files|provenance|deliver|verify)
      command="$1"
      shift
      "command_${command//-/_}" "$@"
      exit $?
      ;;
    *) die "unknown command or global option: $1" ;;
  esac
done
