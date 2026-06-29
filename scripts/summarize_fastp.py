#!/usr/bin/env python3
"""
Parse fastp JSON reports and build a summary table.

For every *.json file in the given directory this extracts:
  - sample name (derived from the filename)
  - total q30 bases after filtering
  - gc content after filtering
"""

import argparse
import csv
import json
import os
import sys


def derive_sample_name(filename):
    base = os.path.basename(filename)
    if base.endswith(".json"):
        return base[: -5]
    return base


def parse_report(path):
    with open(path) as fh:
        data = json.load(fh)
    af = data["summary"]["after_filtering"]
    return int(af["q30_bases"]), float(af["gc_content"])


def main():
    ap = argparse.ArgumentParser(
        description="Summarize fastp JSON reports into a TSV table."
    )
    ap.add_argument("directory", help="directory containing fastp .json reports")
    ap.add_argument("-o", "--output", default="data/qc/fastp_summary.txt",
                    help="output TSV path (default: data/qc/fastp_summary.txt)")
    args = ap.parse_args()

    files = sorted(f for f in os.listdir(args.directory) if f.endswith(".json"))
    if not files:
        sys.exit(f"no .json files found in {args.directory}")

    out = open(args.output, "w")
    try:
        writer = csv.writer(out, delimiter="\t")
        writer.writerow(["sample",
                         "q30_bases_after_filtering",
                         "gc_content_after_filtering"])
        for fname in files:
            path = os.path.join(args.directory, fname)
            try:
                q30, gc = parse_report(path)
            except (KeyError, ValueError, OSError) as e:
                print(f"warning: skipping {fname}: {e}", file=sys.stderr)
                continue
            writer.writerow([derive_sample_name(fname), q30, gc])
    finally:
        out.close()


if __name__ == "__main__":
    main()
