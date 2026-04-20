# Code Versions / Backups

I restored and separated both versions so you can keep them side-by-side:

- `GSA_previous/` → full snapshot from commit `d1e2016` (state before the C++ rewrite merge)
- `GSA_cpp/` → full snapshot from commit `638f12b` (current C++-hybrid main state)

## Notes

- These are commit-based snapshots pulled from git history, so nothing is lost.
- Existing working folders (`backend/`, `gsa_flutter/`) remain untouched.
- You can compare both snapshots directly, for example:
  - `diff -ru GSA_previous GSA_cpp`
  - or open both folders in your IDE.
