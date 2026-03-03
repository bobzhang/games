#!/usr/bin/env python3
"""Eliminate thin wrapper functions: remove definitions and rewrite call sites.

Usage:
  python3 tools/eliminate_wrapper.py FUNCNAME REPLACEMENT_PATTERN [--dry-run]

REPLACEMENT_PATTERN is one of:
  method:NAME   -> EXPR.NAME()           e.g. method:sqrt  => (x).sqrt()
  method:NAME:ARGS  -> EXPR.NAME(ARGS)   e.g. method:clamp:min=LO,max=HI

Examples:
  python3 tools/eliminate_wrapper.py sqrtf method:sqrt
  python3 tools/eliminate_wrapper.py absf method:abs
  python3 tools/eliminate_wrapper.py absi method:abs
"""

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

def rewrite_call(s, prefix, func_name, method_name):
    """Rewrite all FUNC(...) and @types.FUNC(...) calls in text.
    For method:NAME pattern, rewrites func(EXPR) -> (EXPR).method()
    """
    result = []
    i = 0
    search = prefix + '('
    while i < len(s):
        idx = s.find(search, i)
        if idx < 0:
            result.append(s[i:])
            break

        # Check if preceded by 'fn ' (function definition) - skip those
        line_start = s.rfind('\n', 0, idx)
        line_start = line_start + 1 if line_start >= 0 else 0
        line_prefix = s[line_start:idx].strip()
        if line_prefix.endswith('fn') or line_prefix.endswith('pub fn'):
            result.append(s[i:idx + len(search)])
            i = idx + len(search)
            continue

        # For bare func names, check not part of a larger identifier
        if prefix == func_name and idx > 0 and (s[idx-1].isalnum() or s[idx-1] == '_'):
            result.append(s[i:idx + len(search)])
            i = idx + len(search)
            continue

        paren_open = idx + len(prefix)
        if paren_open >= len(s) or s[paren_open] != '(':
            result.append(s[i:idx + len(search)])
            i = idx + len(search)
            continue

        paren_close = find_matching_paren(s, paren_open)
        if paren_close < 0:
            result.append(s[i:idx + len(search)])
            i = idx + len(search)
            continue

        inner = s[paren_open + 1:paren_close].strip()

        if is_simple_expr(inner):
            replacement = f"{inner}.{method_name}()"
        else:
            replacement = f"({inner}).{method_name}()"

        result.append(s[i:idx])
        result.append(replacement)
        i = paren_close + 1

    return ''.join(result)

def remove_func_def(text, func_name, ret_type):
    """Remove function definitions (with preceding doc comment)."""
    # Pattern: optional ///| doc comment block, then (pub )fn FUNC(...) -> TYPE { ... }
    patterns = [
        # With doc comment block
        rf'///\|\n(?:///[^\n]*\n)*(?:pub\s+)?fn\s+{re.escape(func_name)}\s*\([^)]*\)\s*->\s*{re.escape(ret_type)}\s*\{{\n[^}}]*\}}\n?',
        # Without doc comment
        rf'(?:pub\s+)?fn\s+{re.escape(func_name)}\s*\([^)]*\)\s*->\s*{re.escape(ret_type)}\s*\{{\n[^}}]*\}}\n?',
    ]
    for pat in patterns:
        text = re.sub(pat, '', text)
    # Clean up triple+ blank lines
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text

def process_file(path, func_name, method_name, ret_type, dry_run=False):
    with open(path) as f:
        original = f.read()

    text = original

    # Remove definitions
    text = remove_func_def(text, func_name, ret_type)

    # Rewrite call sites: @types.func first, then bare func
    text = rewrite_call(text, f'@types.{func_name}', func_name, method_name)
    text = rewrite_call(text, func_name, func_name, method_name)

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
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)

    func_name = sys.argv[1]
    pattern = sys.argv[2]
    dry_run = '--dry-run' in sys.argv

    if not pattern.startswith('method:'):
        print(f"ERROR: unsupported pattern '{pattern}', expected 'method:NAME'")
        sys.exit(1)

    method_name = pattern.split(':')[1]

    # Infer return type from function name
    type_map = {
        'sqrtf': 'Float', 'absf': 'Float', 'sinf': 'Float', 'cosf': 'Float',
        'maxf': 'Float', 'minf': 'Float',
        'absi': 'Int', 'mini': 'Int', 'maxi': 'Int', 'clampi': 'Int',
    }
    ret_type = type_map.get(func_name, 'Float')

    files = sorted(glob.glob('raylib_*/**/*.mbt', recursive=True))
    changed = 0
    for f in files:
        if process_file(f, func_name, method_name, ret_type, dry_run):
            changed += 1
    print(f"\nTotal files changed: {changed}")

if __name__ == '__main__':
    main()
