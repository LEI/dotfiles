#!/usr/bin/env nu

# PreToolUse hook: show task context in ask prompt
# Matches TaskCreate, TaskUpdate
#
# Architecture: build before/after task records, diff as YAML
# Output inspired by git: action header, diffstat, unified diff, summary
# Debug: CLAUDE_HOOK_DEBUG=0 disables (on by default)

const PRIORITY_LABELS = {0: "P0:critical", 1: "P1:high", 2: "P2:medium", 3: "P3:low", 4: "P4:backlog"}

# --- Helpers ---

def priority_label [p] {
  if $p == null { return "" }
  let n = ($p | into int)
  $PRIORITY_LABELS | get -o ($n | into string) | default $"P($n)"
}

def status_icon [s: string] {
  match $s { "pending" => "◻", "in_progress" => "◼", "completed" => "✔", _ => "?" }
}

def fmt_delta [d: int] {
  if $d > 0 { $"\(+($d)\)" } else if $d < 0 { $"\(($d)\)" } else { "" }
}

def list_counts [list_dir: string] {
  if not ($list_dir | path exists) {
    return {total: 0, done: 0, prog: 0, open: 0}
  }
  let files = (glob $"($list_dir)/*.json")
  if ($files | is-empty) {
    return {total: 0, done: 0, prog: 0, open: 0}
  }
  let tasks = ($files | each { open $in })
  let total = ($tasks | length)
  let done = ($tasks | where status == "completed" | length)
  let prog = ($tasks | where status == "in_progress" | length)
  let open = $total - $done - $prog
  {total: $total, done: $done, prog: $prog, open: $open}
}

def list_summary [list_dir: string, dt: int, dd: int, dp: int, do_: int] {
  let base = (list_counts $list_dir)
  let total = $base.total + $dt
  let done = $base.done + $dd
  let prog = $base.prog + $dp
  let open = $base.open + $do_
  mut parts = []
  if $done > 0 or $dd != 0 { $parts = ($parts | append $"($done)(fmt_delta $dd) done") }
  if $prog > 0 or $dp != 0 { $parts = ($parts | append $"($prog)(fmt_delta $dp) in progress") }
  if $open > 0 or $do_ != 0 { $parts = ($parts | append $"($open)(fmt_delta $do_) open") }
  let breakdown = ($parts | str join ", ")
  $"($total)(fmt_delta $dt) tasks \(($breakdown)\)"
}

def find_task [list_dir: string, id: string] {
  let file = $"($list_dir)/($id).json"
  if ($file | path exists) { $file } else { null }
}

# Join non-empty sections with blank lines
def compose [...sections: string] {
  $sections | where { $in != "" } | str join "\n\n"
}

# --- Task record helpers ---

# Build a display record from a task, keeping only user-visible fields
def task_display [rec: record] {
  mut out = {}
  for key in ["subject" "status" "description" "owner" "activeForm"] {
    let val = ($rec | get -o $key | default null)
    if $val != null and ($val | to text) != "" { $out = ($out | merge {$key: $val}) }
  }
  let meta = ($rec | get -o metadata | default null)
  if $meta != null {
    let prio = ($meta | get -o priority | default null)
    if $prio != null { $out = ($out | merge {priority: (priority_label $prio)}) }
    let extra = ($meta | reject -o priority)
    if not ($extra | is-empty) {
      for row in ($extra | transpose key value) {
        $out = ($out | merge {$"meta.($row.key)": $row.value})
      }
    }
  }
  for key in ["addBlocks" "addBlockedBy"] {
    let val = ($rec | get -o $key | default null)
    if $val != null and not ($val | is-empty) {
      $out = ($out | merge {$key: ($val | str join ", ")})
    }
  }
  $out
}

# Merge tool_input into disk record (new values override)
def merge_update [disk: record, ti: record] {
  mut merged = $disk
  let dominated = ["taskId"]
  for row in ($ti | transpose key value) {
    if $row.key not-in $dominated {
      if $row.key == "metadata" {
        let cur_meta = ($merged | get -o metadata | default {})
        $merged = ($merged | upsert metadata ($cur_meta | merge $row.value))
      } else {
        $merged = ($merged | upsert $row.key $row.value)
      }
    }
  }
  $merged
}

# --- Diff engine ---

# Produce unified diff between two YAML strings
def yaml_diff [before: string, after: string, label_a: string = "before", label_b: string = "after"] {
  let tmp = (mktemp -d | str trim)
  let file_a = $"($tmp)/($label_a)"
  let file_b = $"($tmp)/($label_b)"
  $before | save $file_a
  $after | save $file_b
  let result = (^diff -u $file_a $file_b | complete)
  rm -rf $tmp
  if $result.exit_code == 0 { return "" }
  # Strip temp path headers and "no newline" warnings
  $result.stdout
    | lines
    | where { |line| not ($line | str starts-with "---") and not ($line | str starts-with "+++") and not ($line | str starts-with "\\") }
    | str join "\n"
}

# Diffstat: count changed fields like git --stat
def diffstat [before: record, after: record] {
  let keys = ($before | columns | append ($after | columns) | uniq)
  mut changed = 0
  mut added = 0
  mut removed = 0
  for key in $keys {
    let old_val = ($before | get -o $key | default null)
    let new_val = ($after | get -o $key | default null)
    if $old_val == null and $new_val != null { $added = $added + 1 } else if $old_val != null and $new_val == null { $removed = $removed + 1 } else if ($old_val | to text) != ($new_val | to text) { $changed = $changed + 1 }
  }
  mut parts = []
  if $changed > 0 { $parts = ($parts | append $"($changed) changed") }
  if $added > 0 { $parts = ($parts | append $"($added) added") }
  if $removed > 0 { $parts = ($parts | append $"($removed) removed") }
  if ($parts | is-empty) { "" } else { $parts | str join ", " }
}

# --- Debug ---

def debug_section [raw_input: string, task_file: string = ""] {
  if ($env.CLAUDE_HOOK_DEBUG? | default "1") == "0" { return "" }
  let input_dump = ($raw_input
    | from json
    | transpose key value
    | each { |row|
      if $row.key == "tool_input" {
        let ti = ($row.value | transpose key value | each { |f| $"    ($f.key): ($f.value | to text | str substring 0..200)" } | str join "\n")
        $"  tool_input:\n($ti)"
      } else {
        $"  ($row.key): ($row.value | to text | str substring 0..200)"
      }
    }
    | str join "\n")
  mut out = $"--- input:\n($input_dump)"
  if $task_file != "" and ($task_file | path exists) {
    let disk_dump = (open $task_file
      | transpose key value
      | each { |row| $"    ($row.key): ($row.value | to text | str substring 0..200)" }
      | str join "\n")
    $out = $"($out)\n\n--- on disk:\n($disk_dump)"
  }
  $out
}

# --- Main ---

def main [] {
  let raw = (^cat | decode utf-8 | str trim)
  let input = ($raw | from json)
  let tool = ($input.tool_name? | default "")
  if $tool == "" { return }

  let session_id = ($input.session_id? | default "")
  let list_id = ($env.CLAUDE_CODE_TASK_LIST_ID? | default $session_id)
  if $list_id == "" {
    print ({hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: "task_info: no session_id in hook input"}} | to json)
    return
  }

  let list_dir = $"($env.HOME)/.claude/tasks/($list_id)"
  let short_sid = ($session_id | str substring 0..8)
  let list_label = if $list_id != $session_id { $"($short_sid) \(($list_id)\)" } else { $short_sid }
  let ti = ($input.tool_input? | default {})

  mut reason = ""
  mut dt = 0; mut dd = 0; mut dp = 0; mut do_ = 0

  match $tool {
    "TaskCreate" => {
      let subject = ($ti.subject? | default "?")
      let status = ($ti.status? | default "pending")
      let meta = ($ti.metadata? | default {})
      let prio = ($meta.priority? | default null)
      let prio_tag = if $prio != null { $" [(priority_label $prio)]" } else { " (no priority)" }

      let header = if $status == "pending" {
        $"+ Create:($prio_tag) ($subject)"
      } else {
        $"+ Create:($prio_tag) (status_icon $status) ($status) ($subject)"
      }

      let display = (task_display $ti)
      let body = if ($display | is-empty) { "" } else {
        $display | to yaml | str trim
      }

      let debug = (debug_section $raw)
      $reason = (compose $debug $header $body)

      $dt = 1
      match $status {
        "completed" => { $dd = 1 }
        "in_progress" => { $dp = 1 }
        _ => { $do_ = 1 }
      }
    }
    "TaskUpdate" => {
      let id = ($ti.taskId? | default "?")
      let task_file = (find_task $list_dir $id)

      if $task_file != null {
        let disk = (open $task_file)
        let cur_status = ($disk.status? | default "")
        let cur_subject = ($disk.subject? | default "")
        let new_status = ($ti.status? | default "")
        let new_subject = ($ti.subject? | default "")
        let status_changing = ($new_status != "" and $new_status != $cur_status)

        let subj = if $new_subject != "" { $new_subject } else { $cur_subject }
        let header = if $new_status == "deleted" {
          $"✕ Delete: #($id) ($subj)"
        } else if $status_changing {
          let action = match $new_status {
            "in_progress" => "▶ Start:"
            "completed" => "✔ Close:"
            "pending" => "◁ Reopen:"
            _ => "△ Update:"
          }
          $"($action) #($id) ($subj)"
        } else {
          $"△ Update: (status_icon $cur_status) ($cur_status) #($id) ($subj)"
        }

        let before = (task_display $disk)
        let after = if $new_status == "deleted" {
          {}
        } else {
          task_display (merge_update $disk $ti)
        }

        let stat = (diffstat $before $after)
        let stat_line = if $stat != "" { $stat } else { "" }

        let diff = if $new_status == "deleted" {
          $before | to yaml | str trim | lines | each { |l| $"- ($l)" } | str join "\n"
        } else {
          let before_yaml = ($before | to yaml | str trim)
          let after_yaml = ($after | to yaml | str trim)
          if $before_yaml == $after_yaml { "" } else {
            yaml_diff $before_yaml $after_yaml
          }
        }

        let debug = (debug_section $raw $task_file)
        $reason = (compose $debug $header $stat_line $diff)

        if $new_status == "deleted" {
          $dt = -1
          match $cur_status {
            "completed" => { $dd = -1 }
            "in_progress" => { $dp = -1 }
            _ => { $do_ = -1 }
          }
        } else if $status_changing {
          match $cur_status {
            "completed" => { $dd = $dd - 1 }
            "in_progress" => { $dp = $dp - 1 }
            _ => { $do_ = $do_ - 1 }
          }
          match $new_status {
            "completed" => { $dd = $dd + 1 }
            "in_progress" => { $dp = $dp + 1 }
            _ => { $do_ = $do_ + 1 }
          }
        }
      } else {
        let debug = (debug_section $raw)
        $reason = (compose $debug $"△ Update #($id) \(not found in session\)")
      }
    }
    _ => { return }
  }

  let summary = (list_summary $list_dir $dt $dd $dp $do_)
  $reason = $"($reason)\n\n($summary) ($list_label)"

  print ({hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}} | to json)
}
