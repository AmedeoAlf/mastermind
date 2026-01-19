package mastermind

import "base:intrinsics"
import "core:fmt"
import "core:os"

answer_acceptable :: proc(a: ^Answer, attempts: []Attempt) -> bool {
  valid := true
  for p in attempts {
    if b, w := compare(p.answer, a^); b != p.black || w != p.white {
      valid = false
      break
    }
  }
  if valid do return true

  for answer_next(a) {
    valid := true
    for p in attempts {
      if b, w := compare(p.answer, a^); b != p.black || w != p.white {
        valid = false
        break
      }
    }
    if valid do return true
  }

  return false
}

answer_next_acceptable :: proc(a: ^Answer, attempts: []Attempt) -> bool {
  #unroll for i in 0 ..< ANSWER_LEN {
    for a[i] < Color(len(Color) - 1) {
      a[i] += Color(1)

      valid := true
      for p in attempts {
        if b, w := compare(p.answer, a^); b != p.black || w != p.white {
          valid = false
          break
        }
      }

      if valid do return true
    }
    a[i] = Color(0)
  }
  return false
}

try_everything :: proc() {
  solution: Answer

  by_solutions := make([dynamic]Answer)
  defer delete(by_solutions)

  max_attempts := 0
  for answer_next(&solution) {
    if att := solve(solution); att == max_attempts {
      append(&by_solutions, solution)
    } else if att > max_attempts {
      max_attempts = att
      clear(&by_solutions)
      append(&by_solutions, solution)
    }
  }
  fmt.eprintln("Max attempts:", max_attempts, "By solutions:", by_solutions)
}

usage :: proc() {
  fmt.println("USAGE:")
  fmt.println(os.args[0], "solve abcd: solves 'abcd' using the algorithm")
  fmt.println(
    os.args[0],
    "solve: enters interactive solve mode (to solve mastermind without the solution)",
  )
  fmt.println(
    os.args[0],
    "bench: tries to solve all possible combinations (pipe stdout to /dev/null work faster)",
  )
  fmt.println(os.args[0], "play: guess a random sequence")
  os.exit(0)
}

main :: proc() {
  if (len(os.args) == 1) do usage()

  switch os.args[1] {
  case "solve":
    if len(os.args) >= 3 {
      val: [ANSWER_LEN]byte
      copy(val[:], os.args[1])
      fmt.println("Solved in", solve(str_to_ans(val)), "attempts")
    } else {
      interactive_solve()
    }
  case "bench":
    try_everything()
  case "play":
    play()
  case:
    usage()
  }
}
