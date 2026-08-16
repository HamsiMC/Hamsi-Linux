#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
from __future__ import annotations

import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print(f"Kullanım: {sys.argv[0]} PROJE_DİZİNİ ÇIKTI_JSON", file=sys.stderr)
        return 2
    root = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2]).resolve()
    records = []
    for path in sorted(root.rglob("*")):
        if not path.is_file() or ".work" in path.parts or "dist" in path.parts:
            continue
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        records.append({"path": path.relative_to(root).as_posix(), "sha256": digest, "bytes": path.stat().st_size})
    payload = {
        "schema": 1,
        "product": "Hamsi Linux",
        "version": "0.1.0",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "files": records,
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
