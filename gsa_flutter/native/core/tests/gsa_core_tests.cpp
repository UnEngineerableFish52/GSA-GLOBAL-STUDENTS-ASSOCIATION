#include "gsa_core.h"

#include <cassert>
#include <string>
#include <vector>

int main() {
  assert(gsa::is_non_empty("hello"));
  assert(!gsa::is_non_empty("   \n\t"));

  assert(gsa::can_submit_exam(2, 2));
  assert(!gsa::can_submit_exam(1, 2));

  assert(gsa::score_percent(0, 0) == 0);
  assert(gsa::score_percent(1, 2) == 50);
  assert(gsa::score_percent(2, 3) == 67);

  assert(gsa::format_timestamp_hhmm("2026-04-20T12:34:56.000Z") == "12:34");
  assert(gsa::format_timestamp_hhmm("not-a-date") == "not-a-date");

  const auto members = gsa::normalize_members_csv("  a, b, a ,, c  ");
  assert((members == std::vector<std::string>{"a", "b", "c"}));

  return 0;
}
