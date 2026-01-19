package mastermind

Cell :: u8
Color :: enum Cell {
  A,
  B,
  C,
  D,
  E,
  F,
  G,
  H,
}
ANSWER_LEN :: 4
Answer :: [ANSWER_LEN]Color
Attempt :: struct {
  answer:       Answer,
  black, white: u8,
}

compare :: proc(a, b: Answer) -> (black, white: u8) {
  a := transmute([ANSWER_LEN]Cell)a
  b := transmute([ANSWER_LEN]Cell)b
  // Find blacks
  #unroll for i in 0 ..< ANSWER_LEN {
    if (b[i] == a[i]) {
      a[i] = 255
      black += 1
    }
  }
  // Find whites
  #unroll for i in 0 ..< ANSWER_LEN {
    if (a[i] != 255) {
      for &col, j in b {
        (col == a[i] && a[j] != 255) or_continue
        col = 255
        white += 1
        break
      }
    }
  }

  return
}

str_to_ans :: proc(s: [ANSWER_LEN]byte) -> (a: Answer) {
  #unroll for i in 0 ..< ANSWER_LEN {
    a[i] = Color(s[i] - 'a')
  }
  return
}

answer_next :: proc(a: ^Answer) -> bool {
  #unroll for i in 0 ..< ANSWER_LEN {
    if (a[i] < Color(len(Color) - 1)) {
      a[i] += Color(1)
      return true
    }
    a[i] = Color(0)
  }
  return false
}

eval_chances :: proc(solution: Answer) -> f32 {
  REQUIRED_SIZE :: (ANSWER_LEN + 2) * (ANSWER_LEN + 1) / 2
  counters: [REQUIRED_SIZE]int

  // Try all answers
  answer: Answer
  for {
    black, white := compare(answer, solution)
    black_idx := (-black + ANSWER_LEN * 2 + 3) * black / 2
    counters[black_idx + white] += 1
    answer_next(&answer) or_break
  }
  // fmt.println(counters)

  acc := 0
  #unroll for i in 0 ..< len(counters) do acc += counters[i]
  count := 0
  #unroll for i in 0 ..< len(counters) do count += int(counters[i] != 0)

  if acc == count do return f32(10000000)

  return f32(acc) / f32(count)
}
