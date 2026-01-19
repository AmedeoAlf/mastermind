package mastermind

import "core:fmt"

eval_chances_with_previous :: proc(
  solution: Answer,
  attempts: []Attempt,
) -> f32 {
  REQUIRED_SIZE :: (ANSWER_LEN + 2) * (ANSWER_LEN + 1) / 2
  counters: [REQUIRED_SIZE]int

  // Try all answers
  answer: Answer

  for acc := answer_acceptable(&answer, attempts);
      acc;
      acc = answer_next_acceptable(&answer, attempts) {
    black, white := compare(answer, solution)
    black_idx := (-black + ANSWER_LEN * 2 + 3) * black / 2
    counters[black_idx + white] += 1
  }
  // fmt.println(counters)

  acc := 0
  #unroll for i in 0 ..< len(counters) do acc += counters[i]
  count := 0
  #unroll for i in 0 ..< len(counters) do count += int(counters[i] != 0)

  // if acc == count {
  //   fmt.println(acc, count, "from")
  // }

  return f32(acc) / f32(count)
}

find_best :: proc(previous: []Attempt) -> (answer: Answer) {
  if len(previous) == 0 do return {.B, .B, .A, .A}

  solution: Answer
  best_chances := f32(10000000)
  answer_acceptable(&solution, previous)
  for {
    if chance := eval_chances_with_previous(solution, previous);
       chance < best_chances {
      best_chances = chance
      answer = solution
    }
    answer_next_acceptable(&solution, previous) or_break
  }
  fmt.println("Chances", best_chances)
  return
}

solve :: proc(solution: Answer) -> int {
  attempts := make([dynamic]Attempt)
  defer delete(attempts)

  for i in 0 ..< 10 {
    attempt := find_best(attempts[:])
    black, white := compare(attempt, solution)
    append(&attempts, Attempt{attempt, black, white})
    fmt.println(attempt, black, white)
    if black == 4 do break
  }

  return len(attempts)
}
