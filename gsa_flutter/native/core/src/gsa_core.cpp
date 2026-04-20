#include "gsa_core.h"

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstring>
#include <memory>
#include <sstream>
#include <unordered_set>

namespace {

std::string trim(std::string_view value) {
  std::size_t start = 0;
  std::size_t end = value.size();

  while (start < end && std::isspace(static_cast<unsigned char>(value[start])) != 0) {
    ++start;
  }

  while (end > start && std::isspace(static_cast<unsigned char>(value[end - 1])) != 0) {
    --end;
  }

  return std::string(value.substr(start, end - start));
}

char* clone_to_cstr(const std::string& value) {
  auto result = std::make_unique<char[]>(value.size() + 1);
  std::memcpy(result.get(), value.c_str(), value.size() + 1);
  return result.release();
}

std::string join_csv(const std::vector<std::string>& values) {
  std::ostringstream stream;
  for (std::size_t i = 0; i < values.size(); ++i) {
    if (i != 0) {
      stream << ',';
    }
    stream << values[i];
  }
  return stream.str();
}

}  // namespace

namespace gsa {

bool is_non_empty(std::string_view input) {
  return !trim(input).empty();
}

bool can_submit_exam(std::size_t answered, std::size_t total) {
  return total > 0 && answered == total;
}

int score_percent(std::size_t correct, std::size_t total) {
  if (total == 0) {
    return 0;
  }
  const auto ratio = static_cast<double>(correct) / static_cast<double>(total);
  return static_cast<int>(std::lround(ratio * 100.0));
}

std::string format_timestamp_hhmm(std::string_view iso_timestamp) {
  // Expected format: YYYY-MM-DDTHH:MM:SS(.sss)Z
  const auto t_pos = iso_timestamp.find('T');
  if (t_pos == std::string_view::npos || (t_pos + 5) >= iso_timestamp.size()) {
    return std::string(iso_timestamp);
  }

  const auto hour = iso_timestamp.substr(t_pos + 1, 2);
  const auto minute = iso_timestamp.substr(t_pos + 4, 2);

  const bool valid = std::all_of(hour.begin(), hour.end(), [](char c) {
                       return std::isdigit(static_cast<unsigned char>(c)) != 0;
                     }) &&
                     std::all_of(minute.begin(), minute.end(), [](char c) {
                       return std::isdigit(static_cast<unsigned char>(c)) != 0;
                     });

  if (!valid) {
    return std::string(iso_timestamp);
  }

  return std::string(hour) + ":" + std::string(minute);
}

std::vector<std::string> normalize_members_csv(std::string_view csv) {
  std::vector<std::string> members;
  std::unordered_set<std::string> seen;

  std::size_t start = 0;
  while (start <= csv.size()) {
    const auto comma = csv.find(',', start);
    const auto token_end = (comma == std::string_view::npos) ? csv.size() : comma;
    const auto token = trim(csv.substr(start, token_end - start));

    if (!token.empty() && seen.insert(token).second) {
      members.push_back(token);
    }

    if (comma == std::string_view::npos) {
      break;
    }

    start = comma + 1;
  }

  return members;
}

}  // namespace gsa

extern "C" {

int gsa_is_non_empty(const char* input) {
  if (input == nullptr) {
    return 0;
  }
  return gsa::is_non_empty(input) ? 1 : 0;
}

int gsa_can_submit_exam(int answered, int total) {
  if (answered < 0 || total < 0) {
    return 0;
  }
  return gsa::can_submit_exam(static_cast<std::size_t>(answered), static_cast<std::size_t>(total)) ? 1 : 0;
}

int gsa_score_percent(int correct, int total) {
  if (correct < 0 || total < 0) {
    return 0;
  }
  return gsa::score_percent(static_cast<std::size_t>(correct), static_cast<std::size_t>(total));
}

const char* gsa_format_timestamp_hhmm(const char* iso_timestamp) {
  if (iso_timestamp == nullptr) {
    return clone_to_cstr("");
  }
  return clone_to_cstr(gsa::format_timestamp_hhmm(iso_timestamp));
}

const char* gsa_normalize_members_csv(const char* csv) {
  if (csv == nullptr) {
    return clone_to_cstr("");
  }
  const auto normalized = gsa::normalize_members_csv(csv);
  return clone_to_cstr(join_csv(normalized));
}

void gsa_free_string(const char* value) {
  delete[] value;
}

}  // extern "C"
