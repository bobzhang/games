#!/usr/bin/env python3
"""Eliminate thin absi wrappers: remove definitions and rewrite call sites."""

import glob
import re
import sys

def find_matching_paren(s, start):
    """Find the matching closing paren for the opening paren at `start`."""
    depth = 0
    i = start
    while i < len(s):
        if s[i] == '(':
            depth += 1
        elif s[i] == ')':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1

def is_simple_expr(expr):
    """Check if expression is a simple identifier or field access (no operators)."""
    return bool(re.match(r'^[\w.\[\]]+$', expr.strip()))

def rewrite_absi_call(s, prefix, start_of_call):
    """Rewrite a single absi(...) call starting at start_of_call.
    prefix is '@types.absi' or 'absi'.
    Returns (replacement_string, end_pos) or None if can't parse.
    """
    paren_open = start_of_call + len(prefix)
    if paren_open >= len(s) or s[paren_open] != '(':
        return None
    paren_close = find_matching_paren(s, paren_open)
    if paren_close < 0:
        return None
    inner = s[paren_open + 1:paren_close]
    inner = inner.strip()
    if is_simple_expr(inner):
        replacement = f"{inner}.abs()"
    else:
        replacement = f"({inner}).abs()"
    return replacement, paren_close + 1

def rewrite_calls_in_text(text):
    """Rewrite all absi(...) and @types.absi(...) calls in text."""
    # Process @types.absi first (longer match), then bare absi
    for prefix in ['@types.absi', 'absi']:
        result = []
        i = 0
        while i < len(text):
            idx = text.find(prefix + '(', i)
            if idx < 0:
                result.append(text[i:])
                break
            # Make sure we're not matching inside a function definition
            # Check if this is preceded by 'fn ' or 'pub fn '
            line_start = text.rfind('\n', 0, idx)
            line_start = line_start + 1 if line_start >= 0 else 0
            line_prefix = text[line_start:idx].strip()
            if line_prefix.endswith('fn') or line_prefix.endswith('pub fn'):
                result.append(text[i:idx + len(prefix)])
                i = idx + len(prefix)
                continue
            # Also ensure this is not part of a longer identifier
            if idx > 0 and (text[idx-1].isalnum() or text[idx-1] == '_'):
                if prefix == 'absi':  # skip if part of larger word
                    result.append(text[i:idx + len(prefix)])
                    i = idx + len(prefix)
                    continue

            rewrite = rewrite_absi_call(text, prefix, idx)
            if rewrite:
                replacement, end = rewrite
                result.append(text[i:idx])
                result.append(replacement)
                i = end
            else:
                result.append(text[i:idx + len(prefix)])
                i = idx + len(prefix)
        text = ''.join(result)
    return text

def remove_absi_def(text):
    """Remove absi function definitions (with preceding doc comment)."""
    # Pattern for pub fn absi or fn absi with optional doc comment
    # Match: optional ///| + doc lines, then (pub )fn absi(...) { ... }
    patterns = [
        # With doc comment block
        r'///\|\n(?:///[^\n]*\n)*(?:pub\s+)?fn\s+absi\s*\([^)]*\)\s*->\s*Int\s*\{\n[^}]*\}\n?',
        # Without doc comment
        r'(?:pub\s+)?fn\s+absi\s*\([^)]*\)\s*->\s*Int\s*\{\n[^}]*\}\n?',
    ]
    for pat in patterns:
        text = re.sub(pat, '', text)
    # Clean up double blank lines
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text

def process_file(path, dry_run=False):
    with open(path) as f:
        original = f.read()

    text = original

    # First remove definitions
    text = remove_absi_def(text)

    # Then rewrite call sites
    text = rewrite_calls_in_text(text)

    if text != original:
        if dry_run:
            print(f"WOULD CHANGE: {path}")
        else:
            with open(path, 'w') as f:
                f.write(text)
            print(f"CHANGED: {path}")
        return True
    return False

def main():
    dry_run = '--dry-run' in sys.argv
    files = sorted(glob.glob('raylib_*/**/*.mbt', recursive=True))
    changed = 0
    for f in files:
        if process_file(f, dry_run):
            changed += 1
    print(f"\nTotal files changed: {changed}")

if __name__ == '__main__':
    main()
