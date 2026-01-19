package mastermind

import "core:testing"

@(test)
test_compare :: proc(t: ^testing.T) {
  using testing
  tester :: proc(a, b: [ANSWER_LEN]u8, exp_black, exp_white: u8) -> bool {
    black, white := compare(str_to_ans(a), str_to_ans(b))
    return exp_black == black && exp_white == white
  }
  expect(t, tester("aaaa", "aaaa", 4, 0))
  expect(t, tester("aaab", "aaaa", 3, 0))
  expect(t, tester("aabb", "aaaa", 2, 0))
  expect(t, tester("bcde", "aaaa", 0, 0))
  expect(t, tester("aaab", "bcde", 0, 1))
  expect(t, tester("eaab", "bcde", 0, 2))
  expect(t, tester("bbaa", "dbac", 2, 0))
}

@(test)
test_str_to_ans :: proc(t: ^testing.T) {
  using testing
  expect_value(t, str_to_ans("aaaa"), Answer{.A, .A, .A, .A})
  expect_value(t, str_to_ans("abcd"), Answer{.A, .B, .C, .D})
  expect_value(t, str_to_ans("deca"), Answer{.D, .E, .C, .A})
}

ipow :: proc "contextless" (b, e: int) -> (pow: int = 1) {
  b, e := b, e
  for e > 0 {
    if e & 1 == 1 do pow *= b
    e >>= 1
    b *= b
  }
  return
}

@(test)
test_ipow :: proc(t: ^testing.T) {
  using testing
  expect_value(t, ipow(1, 100), 1)
  expect_value(t, ipow(2, 5), 32)
  expect_value(t, ipow(3, 5), 243)
  expect_value(t, ipow(8, 3), 512)
  expect_value(t, ipow(8, 0), 1)
}

@(test)
test_answer_next :: proc(t: ^testing.T) {
  using testing

  iterations := ipow(len(Color), ANSWER_LEN) - 1
  count := 0
  answer: Answer
  for i in 0 ..< iterations {
    answer_next(&answer) or_break
    count += 1
  }

  expect_value(t, count, iterations)
  last_color := Color(len(Color) - 1)
  expect_value(
    t,
    answer,
    Answer{last_color, last_color, last_color, last_color},
  )
}
