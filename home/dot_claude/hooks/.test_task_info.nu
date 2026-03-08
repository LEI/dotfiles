#!/usr/bin/env nu

# Tests and examples for executable_task_info.nu
# Run tests:    nu .test_task_info.nu
# Run examples: EXAMPLES=1 nu .test_task_info.nu

use std assert

$env.HOOK_PATH = ($env.FILE_PWD | path join "executable_task_info.nu")
$env.FAKE_SID = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
$env.CLAUDE_HOOK_DEBUG = "0"

const ICONS = {
  pending: "◻", in_progress: "◼", completed: "✔",
  resume: "▶", complete: "✔", revert: "◁", update: "△", delete: "✕",
  key: "🔑"
}

# Setup temp dir with fake task data
let tmp = (mktemp -d | str trim)
$env.HOME = ($tmp | path join ".home")
let list_dir = ($env.HOME | path join ".claude" "tasks" $env.FAKE_SID)
mkdir $list_dir

for task in [
  {id: "1", subject: "First task", status: "completed", description: "Done thing"}
  {id: "2", subject: "Second task", status: "in_progress", description: "Doing thing"}
  {id: "3", subject: "Third task", status: "pending", description: "Will do thing"}
] {
  $task | to json | save ($list_dir | path join $"($task.id).json")
}

# Cross-session isolation seed
let other_dir = ($env.HOME | path join ".claude" "tasks" "11111111-2222-3333-4444-555555555555")
mkdir $other_dir
{id: "3", subject: "WRONG SESSION TASK", status: "pending", description: "Should never appear"}
  | to json | save ($other_dir | path join "3.json")

# Custom list ID seed
let custom_dir = ($env.HOME | path join ".claude" "tasks" "my-feature")
mkdir $custom_dir
{id: "1", subject: "Feature task", status: "pending", description: "Custom list"}
  | to json | save ($custom_dir | path join "1.json")

# Task with priority metadata
{id: "4", subject: "Priority task", status: "pending", description: "Has priority", metadata: {priority: 1}}
  | to json | save ($list_dir | path join "4.json")

# Helpers

def inp [tool: string, fields: record] {
  {session_id: $env.FAKE_SID, tool_name: $tool, tool_input: $fields} | to json
}

def reason [input: string] {
  let result = ($input | ^nu $env.HOOK_PATH | complete)
  let out = ($result.stdout | str trim)
  if ($out | is-empty) { return "" }
  $out | from json | get hookSpecificOutput.permissionDecisionReason? | default ""
}

def raw [input: string] {
  $input | ^nu $env.HOOK_PATH | complete | get stdout | str trim
}

def run [name: string, body: closure] {
  try {
    do $body
    print $"  ✓ ($name)"
    {pass: 1, fail: 0}
  } catch { |e|
    print $"  ✗ ($name): ($e.msg)"
    {pass: 0, fail: 1}
  }
}

# Examples

def show_examples [] {
  let examples = [
    {action: "CREATE", input: (inp TaskCreate {subject: "Add rate limiting", description: "The /api/v2/users endpoint needs 100 req/min limit", metadata: {priority: 1}, addBlockedBy: ["1"]})}
    {action: "RESUME", input: (inp TaskUpdate {taskId: "3", status: "in_progress"})}
    {action: "UPDATE", input: (inp TaskUpdate {taskId: "2", subject: "Render: split + enum output", description: "Split into render_table and render_detail", metadata: {priority: 2}})}
    {action: "COMPLETE", input: (inp TaskUpdate {taskId: "2", status: "completed"})}
    {action: "DELETE", input: (inp TaskUpdate {taskId: "2", status: "deleted"})}
  ]

  for ex in $examples {
    let out = (reason $ex.input)
    print ([{$ex.action: $out}] | table --expand --width 120)
    print ""
  }
}

if ($env.EXAMPLES? | default "") == "1" {
  show_examples
  rm -rf $tmp
  exit 0
}

print "task_info.nu hook tests"
print ""

let results = [

  # Guards

  (run "missing session_id returns error" {
    let out = (reason '{"tool_name":"TaskCreate","tool_input":{"subject":"X"}}')
    assert ($out | str contains "no session_id")
  })

  (run "missing session_id returns valid JSON" {
    let json = (raw '{"tool_name":"TaskCreate","tool_input":{"subject":"X"}}')
    let out = ($json | from json)
    assert (($out | get hookSpecificOutput?) != null)
  })

  (run "unknown tool emits diagnostic" {
    let out = (reason ({tool_name: "Read", session_id: "x", tool_input: {}} | to json))
    assert ($out | str contains "unexpected tool")
  })

  (run "empty input emits diagnostic" {
    let out = (reason "")
    assert ($out | str contains "empty stdin")
  })

  (run "non-record input emits diagnostic" {
    let out = (reason "\"just a string\"")
    assert ($out | str contains "expected record")
  })

  # TaskCreate

  (run "create: header with subject" {
    let out = (reason (inp TaskCreate {subject: "New task"}))
    assert ($out | str contains "Create")
    assert ($out | str contains "New task")
  })

  (run "create: fields have + prefix" {
    let out = (reason (inp TaskCreate {subject: "New task", description: "Details"}))
    assert ($out | str contains "+ subject:")
    assert ($out | str contains "+ description:")
  })

  (run "create: hides pending status" {
    let out = (reason (inp TaskCreate {subject: "New task"}))
    assert (not ($out | str contains "pending"))
  })

  (run "create: returns ask decision" {
    let json = (raw (inp TaskCreate {subject: "X"}))
    let out = ($json | from json)
    assert ($out.hookSpecificOutput.permissionDecision == "ask")
  })

  (run "create: positive delta and categories" {
    let out = (reason (inp TaskCreate {subject: "X"}))
    assert ($out | str contains "(+1)")
    assert ($out | str contains "done")
    assert ($out =~ 'open')
  })

  (run "create: session icon and short id in summary" {
    let out = (reason (inp TaskCreate {subject: "X"}))
    assert ($out | str contains $ICONS.key)
    assert ($out | str contains "aaaaaaaa")
  })

  (run "create: description content" {
    let out = (reason (inp TaskCreate {subject: "Task", description: "A detailed description of work"}))
    assert ($out | str contains "A detailed description of work")
  })

  (run "create: blocks and blocked by" {
    let out = (reason (inp TaskCreate {subject: "Task", addBlocks: ["5", "6"], addBlockedBy: ["1"]}))
    assert ($out | str contains "addBlocks")
    assert ($out | str contains "addBlockedBy")
  })

  (run "create: owner" {
    let out = (reason (inp TaskCreate {subject: "Task", owner: "agent-1"}))
    assert ($out | str contains "agent-1")
  })

  (run "create: no priority warning" {
    let out = (reason (inp TaskCreate {subject: "No prio"}))
    assert ($out | str contains "no priority")
  })

  (run "create: priority label" {
    let out = (reason (inp TaskCreate {subject: "With prio", metadata: {priority: 0}}))
    assert ($out | str contains "P0")
    assert ($out | str contains "critical")
  })

  (run "create: extra metadata" {
    let out = (reason (inp TaskCreate {subject: "Task", metadata: {priority: 2, estimate: "30m"}}))
    assert ($out | str contains "P2")
    assert ($out | str contains "30m")
  })

  # TaskUpdate: status transitions

  (run "resume: action, slug, and subject" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "in_progress"}))
    assert ($out | str contains "Resume:")
    assert ($out | str contains $ICONS.resume)
    assert ($out | str contains $"($ICONS.pending) pending")
    assert ($out | str contains "#3")
    assert ($out | str contains "Third task")
  })

  (run "resume: status icons in diffstat" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "in_progress"}))
    assert ($out | str contains $"($ICONS.pending) pending")
    assert ($out | str contains $"($ICONS.in_progress) in_progress")
  })

  (run "resume: no redundant yaml diff for status-only" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "in_progress"}))
    assert (not ($out | str contains "-status:"))
    assert (not ($out | str contains "+status:"))
  })

  (run "complete: action, slug, and id" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "completed"}))
    assert ($out | str contains "Complete:")
    assert ($out | str contains $ICONS.complete)
    assert ($out | str contains $"($ICONS.pending) pending")
    assert ($out | str contains "#3")
  })

  (run "complete: per-category deltas" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "completed"}))
    assert ($out =~ '\(\+1\).*done')
    assert ($out =~ '\(-1\).*open')
  })

  (run "complete: status icons in diffstat" {
    let out = (reason (inp TaskUpdate {taskId: "2", status: "completed"}))
    assert ($out | str contains $"($ICONS.in_progress) in_progress")
    assert ($out | str contains $"($ICONS.completed) completed")
    assert (not ($out | str contains "Doing thing"))
  })

  (run "revert: action, slug, and id" {
    let out = (reason (inp TaskUpdate {taskId: "1", status: "pending"}))
    assert ($out | str contains "Revert:")
    assert ($out | str contains $ICONS.revert)
    assert ($out | str contains $"($ICONS.completed) completed")
    assert ($out | str contains "#1")
  })

  (run "revert: unchanged fields hidden" {
    let out = (reason (inp TaskUpdate {taskId: "1", status: "pending"}))
    assert (not ($out | str contains "Done thing"))
  })

  # TaskUpdate: field changes

  (run "update description: heading with detail" {
    let out = (reason (inp TaskUpdate {taskId: "2", description: "New desc for the task"}))
    assert ($out =~ 'M description:')
    assert ($out | str contains "  - Doing thing")
    assert ($out | str contains "  + New desc for the task")
  })

  (run "update description: full replacement shows unified diff" {
    let long_desc = "This is a completely rewritten description that replaces the old one entirely"
    let out = (reason (inp TaskUpdate {taskId: "2", description: $long_desc}))
    assert ($out =~ 'M description:')
    assert ($out | str contains "  - Doing thing")
    assert ($out | str contains "  + This is a completely rewritten")
  })

  (run "update subject: short field uses inline" {
    let out = (reason (inp TaskUpdate {taskId: "1", subject: "Renamed"}))
    assert ($out =~ 'M subject:')
    assert ($out | str contains "  - First task")
    assert ($out | str contains "  + Renamed")
  })

  (run "update: blocks and owner" {
    let out = (reason (inp TaskUpdate {taskId: "2", addBlocks: ["3"], owner: "lead"}))
    assert ($out | str contains "addBlocks")
    assert ($out | str contains "lead")
  })

  (run "update: multi-field stat lines" {
    let out = (reason (inp TaskUpdate {taskId: "2", subject: "New name", description: "A much longer description for this task"}))
    assert ($out =~ 'M subject:')
    assert ($out | str contains "  - Second task")
    assert ($out | str contains "  + New name")
    assert ($out =~ 'M description:')
    assert ($out | str contains "  - Doing thing")
    assert ($out | str contains "  + A much longer description")
  })

  (run "update: added field shows A prefix" {
    let out = (reason (inp TaskUpdate {taskId: "3", metadata: {priority: 2}}))
    assert ($out =~ 'A priority:')
    assert ($out | str contains "P2")
  })

  # TaskUpdate: priority

  (run "update: priority change shows both" {
    let out = (reason (inp TaskUpdate {taskId: "4", metadata: {priority: 3}}))
    assert ($out | str contains "P1")
    assert ($out | str contains "P3")
  })

  (run "update: priority added" {
    let out = (reason (inp TaskUpdate {taskId: "3", metadata: {priority: 2}}))
    assert ($out | str contains "P2")
  })

  (run "update: unchanged priority hidden" {
    let out = (reason (inp TaskUpdate {taskId: "4", status: "in_progress"}))
    assert (not ($out | str contains "P1"))
  })

  # TaskUpdate: delete

  (run "delete: full snapshot" {
    let out = (reason (inp TaskUpdate {taskId: "2", status: "deleted"}))
    assert ($out | str contains "Delete:")
    assert ($out | str contains $ICONS.delete)
    assert ($out | str contains "Second task")
    assert ($out | str contains "in_progress")
    assert ($out | str contains "Doing thing")
    assert ($out | str contains "(-1)")
  })

  (run "delete: priority snapshot" {
    let out = (reason (inp TaskUpdate {taskId: "4", status: "deleted"}))
    assert ($out | str contains "P1")
  })

  # TaskUpdate: edge cases

  (run "not found: error with id" {
    let out = (reason (inp TaskUpdate {taskId: "999", status: "completed"}))
    assert ($out | str contains "not found")
    assert ($out | str contains "#999")
  })

  (run "update: shows triangle icon" {
    let out = (reason (inp TaskUpdate {taskId: "2", subject: "Renamed"}))
    assert ($out | str contains $ICONS.update)
    assert ($out | str contains "Update:")
  })

  (run "noop: no diff lines" {
    let out = (reason (inp TaskUpdate {taskId: "2"}))
    assert (not ($out | str contains "@@"))
  })

  (run "isolation: correct session only" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "completed"}))
    assert ($out | str contains "Third task")
    assert (not ($out | str contains "WRONG SESSION"))
  })

  # Debug mode

  (run "debug: stderr when enabled" {
    $env.CLAUDE_HOOK_DEBUG = "1"
    let result = ((inp TaskUpdate {taskId: "1", status: "completed"}) | ^nu $env.HOOK_PATH | complete)
    assert ($result.stderr | str contains "tool_name")
    $env.CLAUDE_HOOK_DEBUG = "0"
  })

  (run "debug: no stderr when disabled" {
    let result = ((inp TaskUpdate {taskId: "1", status: "completed"}) | ^nu $env.HOOK_PATH | complete)
    assert ($result.stderr | is-empty)
  })

  # Icons off

  (run "icons off: no unicode symbols" {
    $env.CLAUDE_HOOK_TASK_ICONS = "0"
    let out = (reason (inp TaskUpdate {taskId: "3", status: "in_progress"}))
    assert ($out | str contains "Resume:")
    assert (not ($out | str contains $ICONS.resume))
    assert (not ($out | str contains $ICONS.pending))
    assert (not ($out | str contains $ICONS.key))
    hide-env CLAUDE_HOOK_TASK_ICONS
  })

  # CLAUDE_CODE_TASK_LIST_ID override

  (run "list_id override: resolves custom list" {
    $env.CLAUDE_CODE_TASK_LIST_ID = "my-feature"
    let out = (reason (inp TaskUpdate {taskId: "1", status: "in_progress"}))
    assert ($out | str contains "Feature task")
    assert ($out | str contains "my-feature")
    hide-env CLAUDE_CODE_TASK_LIST_ID
  })

]

# Summary
let pass = ($results | get pass | math sum)
let fail = ($results | get fail | math sum)
print ""
print $"($pass)/($pass + $fail) passed"

if $fail == 0 { show_examples }

# Cleanup
rm -rf $tmp

if $fail > 0 { exit 1 }
