#pragma once

#include <cstddef>
#include <string>
#include <string_view>
#include <vector>

namespace gsa {

bool is_non_empty(std::string_view input);
bool can_submit_exam(std::size_t answered, std::size_t total);
int score_percent(std::size_t correct, std::size_t total);
std::string format_timestamp_hhmm(std::string_view iso_timestamp);
std::vector<std::string> normalize_members_csv(std::string_view csv);

}  // namespace gsa

extern "C" {

int gsa_is_non_empty(const char* input);
int gsa_can_submit_exam(int answered, int total);
int gsa_score_percent(int correct, int total);
const char* gsa_format_timestamp_hhmm(const char* iso_timestamp);
const char* gsa_normalize_members_csv(const char* csv);
void gsa_free_string(const char* value);

}
