#!/usr/bin/env nu

# Tests for executable_task_info.nu
# Run: nu home/dot_claude/hooks/.test_task_info.nu
#
# Assertions test data values, not format strings,
# so tests survive format changes (separators, layout, icons)

use std assert

$env.HOOK_PATH = ($env.FILE_PWD | path join "executable_task_info.nu")
$env.FAKE_SID = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"

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

print "task_info.nu hook tests"
print ""

let results = [

  # --- Guards ---

  (run "missing session_id returns error" {
    let out = (reason '{"tool_name":"TaskCreate","tool_input":{"subject":"X"}}')
    assert ($out | str contains "no session_id")
  })

  (run "missing session_id returns valid JSON" {
    let json = (raw '{"tool_name":"TaskCreate","tool_input":{"subject":"X"}}')
    let out = ($json | from json)
    assert (($out | get hookSpecificOutput?) != null)
  })

  (run "unknown tool produces no output" {
    let input = ({tool_name: "Read", session_id: "x", tool_input: {}} | to json)
    let out = (raw $input)
    assert ($out | is-empty)
  })

  # --- TaskCreate ---

  (run "create: shows action and subject" {
    let out = (reason (inp TaskCreate {subject: "New task"}))
    assert ($out | str contains "Create")
    assert ($out | str contains "New task")
  })

  (run "create: hides pending status" {
    let out = (reason (inp TaskCreate {subject: "New task"}))
    assert (not ($out | str contains "pending"))
  })

  (run "create: list shows positive delta" {
    let out = (reason (inp TaskCreate {subject: "X"}))
    assert ($out | str contains "(+1)")
  })

  (run "create: list shows per-category delta" {
    let out = (reason (inp TaskCreate {subject: "X"}))
    assert ($out | str contains "done")
    assert ($out =~ 'open')
    assert ($out =~ '\(\+1\)')
  })

  (run "create: shows session short id" {
    let out = (reason (inp TaskCreate {subject: "X"}))
    assert ($out | str contains "aaaaaaaa")
  })

  (run "create: returns ask decision" {
    let json = (raw (inp TaskCreate {subject: "X"}))
    let out = ($json | from json)
    assert ($out.hookSpecificOutput.permissionDecision == "ask")
  })

  # --- TaskUpdate: status change ---

  (run "start: shows action, id, subject" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "in_progress"}))
    assert ($out | str contains "Start")
    assert ($out | str contains "#3")
    assert ($out | str contains "Third task")
  })

  (run "close: shows close action" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "completed"}))
    assert ($out | str contains "Close")
    assert ($out | str contains "#3")
  })

  (run "reopen: shows reopen action" {
    let out = (reason (inp TaskUpdate {taskId: "1", status: "pending"}))
    assert ($out | str contains "Reopen")
    assert ($out | str contains "#1")
  })

  (run "start: shows both old and new status" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "in_progress"}))
    assert ($out | str contains "pending")
    assert ($out | str contains "in_progress")
  })

  (run "start: shows context in diff" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "in_progress"}))
    assert ($out | str contains "Will do thing")
  })

  (run "start: no char diff summary" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "in_progress"}))
    assert (not ($out | str contains "chars total"))
  })

  (run "close: list shows per-category deltas" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "completed"}))
    assert ($out =~ '\(\+1\).*done')
    assert ($out =~ '\(-1\).*open')
  })

  # --- TaskUpdate: description change ---

  (run "update description: shows diff" {
    let out = (reason (inp TaskUpdate {taskId: "2", description: "New desc"}))
    assert ($out | str contains "description")
    assert ($out | str contains "changed")
  })

  (run "update description: shows content diff" {
    let out = (reason (inp TaskUpdate {taskId: "2", description: "New desc"}))
    assert ($out | str contains "Doing thing")
    assert ($out | str contains "New desc")
  })

  # --- TaskUpdate: subject change ---

  (run "update subject: shows old and new" {
    let out = (reason (inp TaskUpdate {taskId: "1", subject: "Renamed"}))
    assert ($out | str contains "subject")
    assert ($out | str contains "Renamed")
    assert ($out | str contains "First task")
  })

  # --- TaskUpdate: delete ---

  (run "delete: shows action and subject" {
    let out = (reason (inp TaskUpdate {taskId: "2", status: "deleted"}))
    assert ($out | str contains "Delete")
    assert ($out | str contains "Second task")
  })

  (run "delete: list shows negative delta" {
    let out = (reason (inp TaskUpdate {taskId: "2", status: "deleted"}))
    assert ($out | str contains "(-1)")
  })

  (run "delete: shows status snapshot" {
    let out = (reason (inp TaskUpdate {taskId: "2", status: "deleted"}))
    assert ($out | str contains "in_progress")
  })

  (run "delete: shows description content" {
    let out = (reason (inp TaskUpdate {taskId: "2", status: "deleted"}))
    assert ($out | str contains "Doing thing")
  })

  (run "delete: shows priority snapshot" {
    let out = (reason (inp TaskUpdate {taskId: "4", status: "deleted"}))
    assert ($out | str contains "P1")
  })

  # --- TaskUpdate: not found ---

  (run "not found: shows error with id" {
    let out = (reason (inp TaskUpdate {taskId: "999", status: "completed"}))
    assert ($out | str contains "not found")
    assert ($out | str contains "#999")
  })

  (run "not found: still shows list" {
    let out = (reason (inp TaskUpdate {taskId: "999", status: "completed"}))
    assert ($out | str contains "tasks")
  })

  # --- Cross-session isolation ---

  (run "isolation: correct session only" {
    let out = (reason (inp TaskUpdate {taskId: "3", status: "completed"}))
    assert ($out | str contains "Third task")
    assert (not ($out | str contains "WRONG SESSION"))
  })

  # --- Debug mode ---

  (run "debug: on by default" {
    let out = (reason (inp TaskUpdate {taskId: "1", status: "completed"}))
    assert ($out | str contains "--- input:")
    assert ($out | str contains "--- on disk:")
  })

  (run "debug: off with env var" {
    $env.CLAUDE_HOOK_DEBUG = "0"
    let out = (reason (inp TaskUpdate {taskId: "1", status: "completed"}))
    assert (not ($out | str contains "--- input:"))
    $env.CLAUDE_HOOK_DEBUG = "1"
  })

  # --- CLAUDE_CODE_TASK_LIST_ID override ---

  (run "list_id override: resolves custom list" {
    $env.CLAUDE_CODE_TASK_LIST_ID = "my-feature"
    let out = (reason (inp TaskUpdate {taskId: "1", status: "in_progress"}))
    assert ($out | str contains "Feature task")
    assert ($out | str contains "my-feature")
  })

  # --- No-op update ---

  (run "noop: no diff shown" {
    let out = (reason (inp TaskUpdate {taskId: "2"}))
    assert (not ($out | str contains "@@"))
  })

  # --- Priority ---

  (run "create: shows no priority warning" {
    let out = (reason (inp TaskCreate {subject: "No prio"}))
    assert ($out | str contains "no priority")
  })

  (run "create: shows priority label" {
    let out = (reason (inp TaskCreate {subject: "With prio", metadata: {priority: 0}}))
    assert ($out | str contains "P0")
    assert ($out | str contains "critical")
  })

  (run "update: shows priority change" {
    let out = (reason (inp TaskUpdate {taskId: "4", metadata: {priority: 3}}))
    assert ($out | str contains "P1")
    assert ($out | str contains "P3")
  })

  (run "update: shows priority added" {
    let out = (reason (inp TaskUpdate {taskId: "3", metadata: {priority: 2}}))
    assert ($out | str contains "P2")
  })

  (run "update: shows context priority" {
    let out = (reason (inp TaskUpdate {taskId: "4", status: "in_progress"}))
    assert ($out | str contains "P1")
  })

  # --- Diffstat ---

  (run "update description: shows diffstat" {
    let out = (reason (inp TaskUpdate {taskId: "2", description: "Short"}))
    assert ($out | str contains "changed")
  })

  (run "update subject: shows diffstat" {
    let out = (reason (inp TaskUpdate {taskId: "1", subject: "Renamed task with longer name"}))
    assert ($out | str contains "changed")
  })

  # --- Create: field display ---

  (run "create: shows description content" {
    let out = (reason (inp TaskCreate {subject: "Task", description: "A detailed description of work"}))
    assert ($out | str contains "description")
    assert ($out | str contains "A detailed description of work")
  })

  (run "create: shows blocks" {
    let out = (reason (inp TaskCreate {subject: "Task", addBlocks: ["5", "6"]}))
    assert ($out | str contains "addBlocks")
    assert ($out | str contains "5")
  })

  (run "create: shows blocked by" {
    let out = (reason (inp TaskCreate {subject: "Task", addBlockedBy: ["1"]}))
    assert ($out | str contains "addBlockedBy")
    assert ($out | str contains "1")
  })

  (run "create: shows owner" {
    let out = (reason (inp TaskCreate {subject: "Task", owner: "agent-1"}))
    assert ($out | str contains "owner")
    assert ($out | str contains "agent-1")
  })

  (run "create: shows extra metadata" {
    let out = (reason (inp TaskCreate {subject: "Task", metadata: {priority: 2, estimate: "30m"}}))
    assert ($out | str contains "P2")
    assert ($out | str contains "estimate")
    assert ($out | str contains "30m")
  })

  # --- Update: structured fields ---

  (run "update: shows blocks field" {
    let out = (reason (inp TaskUpdate {taskId: "2", addBlocks: ["3"]}))
    assert ($out | str contains "addBlocks")
    assert ($out | str contains "3")
  })

  (run "update: shows owner field" {
    let out = (reason (inp TaskUpdate {taskId: "2", owner: "lead"}))
    assert ($out | str contains "owner")
    assert ($out | str contains "lead")
  })

  # --- Context: unchanged fields visible in diff ---

  (run "close: shows context description" {
    let out = (reason (inp TaskUpdate {taskId: "2", status: "completed"}))
    assert ($out | str contains "Doing thing")
  })

  (run "reopen: shows context description" {
    let out = (reason (inp TaskUpdate {taskId: "1", status: "pending"}))
    assert ($out | str contains "Done thing")
  })

]

# Summary
let pass = ($results | get pass | math sum)
let fail = ($results | get fail | math sum)
print ""
print $"($pass)/($pass + $fail) passed"

# Example output (like git showing commit details after tests)
if $fail == 0 {
  # Reset env for clean examples
  $env.CLAUDE_HOOK_DEBUG = "0"
  if ($env.CLAUDE_CODE_TASK_LIST_ID? | default "") != "" { hide-env CLAUDE_CODE_TASK_LIST_ID }

  print ""
  print "--- example output ---"
  print ""

  for example in [
    {label: "CREATE", input: (inp TaskCreate {subject: "Add rate limiting", description: "The /api/v2/users endpoint needs 100 req/min limit", metadata: {priority: 1}, addBlockedBy: ["1"]})}
    {label: "START", input: (inp TaskUpdate {taskId: "3", status: "in_progress"})}
    {label: "UPDATE", input: (inp TaskUpdate {taskId: "2", subject: "Render: split + enum output", description: "Split into render_table and render_detail", metadata: {priority: 2}})}
    {label: "CLOSE", input: (inp TaskUpdate {taskId: "2", status: "completed"})}
    {label: "DELETE", input: (inp TaskUpdate {taskId: "2", status: "deleted"})}
  ] {
    print $"($example.label):"
    print (reason $example.input)
    print ""
  }
}

# Cleanup
rm -rf $tmp

if $fail > 0 { exit 1 }
