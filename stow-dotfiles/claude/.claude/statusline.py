#!/usr/bin/env python3
import json, sys, os, time
from datetime import date

data = json.load(sys.stdin)


def fmt(n):
    if n is None or n == 0:
        return "0"
    n = float(n)
    if n >= 1_000_000:
        v = f"{n/1_000_000:.1f}"
        return f"{v.rstrip('0').rstrip('.')}M"
    elif n >= 1_000:
        v = f"{n/1_000:.1f}"
        return f"{v.rstrip('0').rstrip('.')}k"
    return str(int(n))


# Current usage from last API call
cu = data.get("context_window", {}).get("current_usage") or {}
cached_cur = (cu.get("cache_read_input_tokens") or 0) + (
    cu.get("cache_creation_input_tokens") or 0
)
in_cur = cu.get("input_tokens") or 0
out_cur = cu.get("output_tokens") or 0

# Cumulative session totals
total_in = data.get("context_window", {}).get("total_input_tokens") or 0
total_out = data.get("context_window", {}).get("total_output_tokens") or 0
total_api_ms = data.get("cost", {}).get("total_api_duration_ms") or 0

speed_str = f" ({total_out / total_api_ms * 1000:.0f} t/s)" if total_api_ms > 0 else ""

print(f"Cached: {fmt(cached_cur)} | In: {fmt(in_cur)} | Out: {fmt(out_cur)}")
print(f"Total in: {fmt(total_in)} | Total out: {fmt(total_out)}{speed_str}")
