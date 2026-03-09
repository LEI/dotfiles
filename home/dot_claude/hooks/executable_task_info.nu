#!/usr/bin/env nu

# PreToolUse hook: show task context in ask prompt
# Matches TaskCreate, TaskUpdate
# Debug: CLAUDE_HOOK_DEBUG=1 enables (off by default)

const PRIORITY_LABELS = {P0: "P0:critical", P1: "P1:high", P2: "P2:normal", P3: "P3:low", P4: "P4:someday", "0": "P0:critical", "1": "P1:high", "2": "P2:normal", "3": "P3:low", "4": "P4:someday"}
# Override with CLAUDE_HOOK_TASK_ICONS=0 to disable
const STATUS_ICONS = {pending: "◻", in_progress: "◼", completed: "✔"}
const ACTIONS = {create: "+", resume: "▶ Resume:", complete: "✔ Complete:", revert: "◁ Revert:", update: "△ Update:", delete: "✕ Delete:"}
const DIFFSTAT_BAR_THRESHOLD = 16
const DIFFSTAT_BAR_MAX = 40

def priority_label [p] {
  if $p == null { return "" }
  let key = ($p | into string)
  $PRIORITY_LABELS | get -o $key | default $key
}

def icons_enabled [] {
  ($env.CLAUDE_HOOK_TASK_ICONS? | default "1") != "0"
}

def status_icon [s: string] {
  if not (icons_enabled) { return "" }
  $STATUS_ICONS | get -o $s | default ""
}

def action_label [key: string] {
  if (icons_enabled) {
    $ACTIONS | get -o $key | default $"($key):"
  } else {
    # Plain text fallback: capitalize first letter
    let word = ($key | str capitalize)
    $"($word):"
  }
}

def fmt_delta [d: int] {
  if $d > 0 { $"\(+($d)\)" } else if $d < 0 { $"\(($d)\)" } else { "" }
}

def list_counts [list_dir: string] {
  if not ($list_dir | path exists) { return {total: 0, done: 0, prog: 0, open: 0} }
  let files = (glob $"($list_dir)/*.json")
  if ($files | is-empty) { return {total: 0, done: 0, prog: 0, open: 0} }
  let tasks = ($files | each { open $in })
  let total = ($tasks | length)
  let done = ($tasks | where status == "completed" | length)
  let prog = ($tasks | where status == "in_progress" | length)
  {total: $total, done: $done, prog: $prog, open: ($total - $done - $prog)}
}

def list_summary [list_dir: string, dt: int, dd: int, dp: int, do_: int, label: string] {
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
  $"($total)(fmt_delta $dt) tasks \(($breakdown)\) ($label)"
}

def find_task [list_dir: string, id: string] {
  let file = $"($list_dir)/($id).json"
  if ($file | path exists) { $file } else { null }
}

def compose [...sections: string] {
  $sections | where { $in != "" } | str join "\n\n"
}

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

def merge_update [disk: record, ti: record] {
  mut merged = $disk
  for row in ($ti | transpose key value) {
    if $row.key != "taskId" {
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

# Diff engine

def diffstat_bar [new_len: int, old_len: int] {
  let total = $new_len + $old_len
  if $total <= $DIFFSTAT_BAR_MAX {
    let plus = ("" | fill -c "+" -w $new_len)
    let minus = ("" | fill -c "-" -w $old_len)
    $"($total) ($plus)($minus)"
  } else {
    let scale = ($DIFFSTAT_BAR_MAX / $total)
    let s_new = [1 ($new_len * $scale | math round | into int)] | math max
    let s_old = [1 ($old_len * $scale | math round | into int)] | math max
    let plus = ("" | fill -c "+" -w $s_new)
    let minus = ("" | fill -c "-" -w $s_old)
    $"($total) ($plus)($minus)"
  }
}

const DIFF_LINE_MAX = 100

def truncate_line [line: string] {
  if ($line | str length) > $DIFF_LINE_MAX {
    $"($line | str substring 0..$DIFF_LINE_MAX)..."
  } else {
    $line
  }
}

def field_diff [before: record, after: record] {
  let keys = ($before | columns | append ($after | columns) | uniq)
  mut lines = []
  for key in $keys {
    let old_val = ($before | get -o $key | default null)
    let new_val = ($after | get -o $key | default null)
    if $old_val == null and $new_val != null {
      $lines = ($lines | append (truncate_line $"A ($key): ($new_val | to text)"))
    } else if $old_val != null and $new_val == null {
      $lines = ($lines | append (truncate_line $"D ($key): ($old_val | to text)"))
    } else if ($old_val | to text) != ($new_val | to text) {
      let old_str = ($old_val | to text)
      let new_str = ($new_val | to text)
      if $key == "status" {
        let oi = (status_icon $old_str)
        let ni = (status_icon $new_str)
        let old_display = if $oi == "" { $old_str } else { $"($oi) ($old_str)" }
        let new_display = if $ni == "" { $new_str } else { $"($ni) ($new_str)" }
        $lines = ($lines | append $"M ($key): ($old_display) -> ($new_display)")
      } else {
        $lines = ($lines | append $"M ($key):")
        $lines = ($lines | append (truncate_line $"  - ($old_str)"))
        $lines = ($lines | append (truncate_line $"  + ($new_str)"))
      }
    }
  }
  $lines | str join "\n"
}

# Output

def emit [reason: string] {
  print ({hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}} | to json)
}

def debug [msg: string] {
  if ($env.CLAUDE_HOOK_DEBUG? | default "0") == "1" { print -e $msg }
}

def log_event [input: record] {
  if ($env.CLAUDE_HOOK_TASK_LOG? | default "0") != "1" { return }
  let log_dir = $"($env.XDG_STATE_HOME? | default ($env.HOME | path join ".local" "state"))/claude"
  mkdir $log_dir
  let tool = ($input.tool_name? | default "")
  let ti = ($input.tool_input? | default {})
  let entry = {
    ts: (date now | date to-timezone UTC | format date "%Y-%m-%dT%H:%M:%SZ")
    event: $tool
    session: ($input.session_id? | default "")
    source: "task_info"
    task_id: (if $tool == "TaskCreate" { null } else { $ti.taskId? | default null })
    subject: ($ti.subject? | default null)
    status: ($ti.status? | default null)
    metadata: ($ti.metadata? | default null)
  }
  let null_cols = ($entry | transpose key val | where val == null | get key)
  let clean = if ($null_cols | is-empty) { $entry } else { $entry | reject ...$null_cols }
  $clean | to json --raw | save --append $"($log_dir)/hooks.jsonl"
}

# Main

def main [] {
  let raw = (^cat | decode utf-8 | str trim)
  if ($raw | is-empty) {
    emit "task_info: empty stdin"
    return
  }
  let input = try { $raw | from json } catch {
    emit $"task_info: invalid JSON\n($raw | str substring 0..200)"
    return
  }
  if ($input | describe | str starts-with "record") == false {
    emit $"task_info: expected record, got ($input | describe)\n($raw | str substring 0..200)"
    return
  }
  let tool = ($input.tool_name? | default "")
  if $tool == "" {
    emit $"task_info: no tool_name\n($raw | str substring 0..200)"
    return
  }

  try { process $input } catch { |e|
    let ctx = try { $input | to json --indent 2 } catch { $raw }
    emit $"task_info error: ($e.msg)\n\n($ctx)"
  }
}

def process [input: record] {
  let tool = ($input.tool_name? | default "")
  let session_id = ($input.session_id? | default "")
  let list_id = ($env.CLAUDE_CODE_TASK_LIST_ID? | default $session_id)
  if $list_id == "" {
    emit "task_info: no session_id in hook input"
    return
  }

  let list_dir = $"($env.HOME)/.claude/tasks/($list_id)"
  let short_sid = ($session_id | str substring 0..7)
  let key_icon = if (icons_enabled) { "🔑 " } else { "" }
  let list_label = if $list_id != $session_id { $"│ ($key_icon)($short_sid) \(($list_id)\)" } else { $"│ ($key_icon)($short_sid)" }
  let ti = ($input.tool_input? | default {})

  debug ($input | to json --indent 2)

  mut reason = ""
  mut dt = 0; mut dd = 0; mut dp = 0; mut do_ = 0

  match $tool {
    "TaskCreate" => {
      let subject = ($ti.subject? | default "?")
      let status = ($ti.status? | default "pending")
      let meta = ($ti.metadata? | default {})
      let prio = ($meta.priority? | default null)
      let prio_tag = if $prio != null { $" [(priority_label $prio)]" } else { " (no priority)" }

      let si = (status_icon $status)
      let header = if $status == "pending" {
        $"+ Create($prio_tag) ($subject)"
      } else {
        $"+ Create($prio_tag) ($si) ($subject)"
      }

      let display = (task_display $ti)
      let body = if ($display | is-empty) { "" } else {
        $display | to yaml | str trim | lines | each { |l| $"+ ($l)" } | str join "\n"
      }

      $reason = (compose $header $body)
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
        debug ($disk | to json --indent 2)
        let cur_status = ($disk.status? | default "")
        let cur_subject = ($disk.subject? | default "")
        let new_status = ($ti.status? | default "")
        let new_subject = ($ti.subject? | default "")
        let status_changing = ($new_status != "" and $new_status != $cur_status)

        let subj = if $new_subject != "" { $new_subject } else { $cur_subject }
        let cur_icon = (status_icon $cur_status)
        let action = if $new_status == "deleted" {
          action_label "delete"
        } else if $status_changing {
          match $new_status {
            "in_progress" => (action_label "resume")
            "completed" => (action_label "complete")
            "pending" => (action_label "revert")
            _ => (action_label "update")
          }
        } else {
          action_label "update"
        }
        let cur_tag = if $cur_icon == "" { "" } else { $"($cur_icon) ($cur_status) " }
        let header = $"($action) ($cur_tag)#($id) ($subj)"

        let before = (task_display $disk)
        let after = if $new_status == "deleted" { {} } else { task_display (merge_update $disk $ti) }
        let diff = (field_diff $before $after)

        $reason = (compose $header $diff)

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
        $reason = $"(action_label "update") #($id) \(not found in session\)"
      }
    }
    _ => {
      emit $"task_info: unexpected tool ($tool)"
      return
    }
  }

  let summary = (list_summary $list_dir $dt $dd $dp $do_ $list_label)
  $reason = $"($reason)\n\n($summary)"
  log_event $input
  emit $reason
}
