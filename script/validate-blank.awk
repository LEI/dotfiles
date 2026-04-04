FNR == 1 {
  flush()
  file_failed = 0
  files++
  if (/^$/) {
    fail()
    printf "%s:1: blank line at start of file\n", FILENAME
  }
  blank = 0
  prev = ""
}

/^$/ {
  blank++
  next
}

blank >= 2 {
  fail()
  printf "%s:%d: %d consecutive blank lines\n", FILENAME, FNR - 1, blank
  if (prev != "") printf "  %d | %s\n", FNR - blank - 1, prev
  printf "  %d | \n", FNR - blank
  printf "  ...\n"
  printf "  %d | \n", FNR - 1
  printf "  %d | %s\n", FNR, $0
  printf "\n"
}

{ blank = 0; prev = $0 }

END {
  flush()
  printf "%d passed, %d failed\n", files - failed, failed
  if (failed > 0) exit 1
}

function fail() {
  if (!file_failed) {
    file_failed = 1
    failed++
  }
}

function flush() {
  if (blank >= 2) {
    fail()
    printf "%s:%d: %d consecutive blank lines (at end of file)\n", FILENAME, FNR, blank
    if (prev != "") printf "  %d | %s\n", FNR - blank, prev
    printf "  %d | \n", FNR - blank + 1
    printf "  ...\n"
    printf "  %d | \n", FNR
    printf "\n"
  }
}
