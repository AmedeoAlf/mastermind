package mastermind

import "core:fmt"
import "core:math/rand"
import "core:os"

read_bw :: proc() -> (black: u8, white: u8) {
  fmt.print("<b> <w>: ")

  buf: [100]byte
  read, err := os.read(os.stdin, buf[:])
  assert(err == nil)

  reading_white := false
  read_loop: for c in buf[:read] {
    switch c {
    case ' ':
      if !reading_white do reading_white = true
      continue
    case '\n':
      break read_loop
    }

    if reading_white {
      white = white * 10 + u8(c - '0')
    } else {
      black = black * 10 + u8(c - '0')
    }
  }

  fmt.println(black, white)
  return
}


interactive_solve :: proc() {
  attempts := make([dynamic]Attempt)
  defer delete(attempts)
  for {
    attempt := find_best(attempts[:])
    fmt.println("Try", attempt)
    black, white := read_bw()
    append(&attempts, Attempt{attempt, black, white})
    if black == 4 do break
  }
}

read_answer :: proc() -> (ans: Answer, ok: bool) {
  fmt.print("> ")

  buf: [ANSWER_LEN + 10]byte
  read, err := os.read(os.stdin, buf[:])
  if err != nil do return

  (read >= ANSWER_LEN) or_return

  subbuf: [ANSWER_LEN]byte
  copy(subbuf[:], buf[:])

  return str_to_ans(subbuf), true
}

play :: proc() {
  fmt.println(
    "Guess the sequence of",
    ANSWER_LEN,
    "letters, between",
    Color(0),
    "and",
    Color(len(Color) - 1),
  )
  solution := Answer {
    Color(rand.int_max(len(Color))),
    Color(rand.int_max(len(Color))),
    Color(rand.int_max(len(Color))),
    Color(rand.int_max(len(Color))),
  }

  attempts := 0
  for {
    ans := read_answer() or_continue
    attempts += 1
    black, white := compare(ans, solution)
    if black == 4 do break
    fmt.println(
      black,
      "letters in the correct position,",
      white,
      "in the wrong one",
    )
  }

  fmt.println("You guessed in", attempts, "attempts")
}
