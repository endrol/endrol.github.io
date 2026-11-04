+++
title = 'Saturday: Giving Claude Code Ears and a Mouth (and Nothing Else)'
date = 2026-11-04T00:00:00+09:00
tags = ["claude-code", "voice", "agent-sdk", "openai-realtime", "python"]
+++

I talk to Claude Code all day. Through a keyboard. Like an animal.

At some point the irony got to me: the thing on the other end is a better listener than most humans I know, and I'm still typing at it. So I built **Saturday**: a hands-free voice assistant that is really just Claude Code with a pair of ears and a mouth attached.

You say "Saturday", ask something, and keep doing whatever your hands were doing. She reads the repo, checks git, hands real changes to a worker inside the right project, and answers in one spoken sentence.

![A developer leaning back with hands behind their head, talking to a glowing orb while a small robot works at the laptop](/images/saturday-voice-claude-code/image-1.png)

---

## Outline

1. What problem are we solving?
2. The key idea: the voice layer never thinks
3. How it works: ears, brain, mouth, workers
4. Try it: an interactive demo
5. Design decisions that mattered
6. Problems we hit (and how we got out)
7. What's next
8. Wrap-up

---

## 1) What problem are we solving?

Most of my questions to Claude Code are small. "Where are we on the roadmap?" "Did the tests pass?" "What changed in the audio code today?" Each one costs a context switch: find the terminal, type, read a paragraph, go back.

What I actually want is a colleague sitting next to me. I ask out loud, they glance at the screen, they answer in one sentence. If the job is bigger, they say "on it" and come back later.

There's a catch, though. A voice assistant that *sounds* smart is easy. One that is actually **right**, about **my** code, with **my** permission rules, is the hard part. Claude Code already does that last part well. So the question became: how little do I need to add?

---

## 2) The key idea: the voice layer never thinks

One rule shapes the whole project:

> **Saturday is Claude Code plus a voice layer, and the core stays small.**

The voice side is only **ears** (speech to text) and a **mouth** (text to speech). It never answers a question on its own, and it never adds a detail Claude didn't say. All the thinking, reading and doing happens in Claude Code, through the **Claude Agent SDK**, which is Claude Code's own harness.

That rule has a useful side effect. Whenever I'm tempted to write a mechanism, the first question is "doesn't Claude Code already have this?" Permission rules, sandbox, hooks, sessions, CLAUDE.md, skills: almost always, yes.

---

## 3) How it works

Here's the whole thing. Hover or tap a box for details; the dots show what flows where.

{{< saturday-architecture >}}

### The voice loop

- **Wake word**: "Saturday" or "Hey Saturday", recognised **on the Mac** with Whisper small (MLX). In standby nothing is streamed anywhere, so nothing is billed.
- **Ears**: `gpt-live-transcribe`. Audio streams while I'm still talking. A local VAD decides I'm done after a 1-second pause, and the text is ready about 1.2 s later.
- **Brain**: one warm Claude Code session at `~/workspace`, Sonnet at low effort, running on my Claude subscription.
- **Mouth**: `gpt-realtime-2.1-mini` reads Claude's answer **word for word**. About $0.002 per reply.

If Claude hasn't answered within 2.5 seconds, she says a short filler ("Let me check.", "One sec.") so the silence doesn't feel like a crash.

### The brain reads; workers write

The brain is the only conversation I talk to. It can read **any** project under `~/workspace` and answer questions about it. It cannot change anything.

Changes go through one tool, `work_in`, to a **worker**: a separate Claude Code session started *inside* that project's folder.

```python
@tool(
    "work_in",
    "Hand work to Saturday's worker inside one of LUO's projects: a Claude Code session "
    "started in that project's folder, so its CLAUDE.md, permission rules and hooks "
    "apply. Use it for any change (editing or writing files, commands with side effects, "
    "commits) and for heavy work (deep investigation, debugging, design). Runs in the "
    "background and returns at once; the result comes back to you as a message.",
    {...},  # project, task, depth: "quick" (Sonnet) | "deep" (Opus)
)
async def work_in(args): ...
```

Why not let the brain edit files directly? Because **Claude Code loads a project's CLAUDE.md, `.claude/settings.json` and hooks only from the directory it was launched in**. A brain sitting at `~/workspace` would happily ignore Kaka's rules while editing Kaka. A worker launched inside `kaka_app/` behaves exactly like me running `claude` there.

One worker per project, tasks queued, session resumed across restarts. When a task finishes, the result goes back to the brain, and she speaks up on her own: "Done: …"

### Permissions go on the screen, never through the mic

Workers run in Claude Code's **auto mode**, same as my terminal: its classifier lets safe actions through and stops risky ones. Whatever Claude Code still wants to ask about arrives through the SDK's `can_use_tool` callback, and Saturday turns it into a panel:

- a plain-words headline ("Kaka's worker wants to run a command: commit the goal change")
- which of my requests it's for
- the `-`/`+` diff or the command underneath
- `y` allow, `a` always, `n` no

**Saying "yes" doesn't count.** Speech recognition is good, not perfect, and a misheard "yes" on `git push` is not a bug I want to debug. If I ask about the prompt out loud, she explains it instead.

### Core and frontends

The last piece is boring, which is the point. Saturday is a **core** that publishes events and takes commands as JSON lines, plus **frontends** that only render them: the terminal UI, a `--headless` mode, and `--replay` for any recorded session. It's the same shape as Claude Code's `stream-json`.

Every run records its events to `~/.saturday/sessions/`, so "what happened when it froze?" is a replay, not a screenshot hunt.

---

## 4) Try it

Three scripted scenarios, with timings taken from the project's research log. Turn on sound if you want your browser to read the lines aloud. In scenario 2 you're LUO, so the permission prompt is yours to answer (try saying yes out loud first).

{{< saturday-demo >}}

---

## 5) Design decisions that mattered

### Route choice: full duplex lost to a boring pipeline

The first version used **GPT-Live-1**, a full-duplex voice model that delegates reasoning to your backend. Natural, but:

- it bills **$0.05 per connected minute** (~$3/hour), silence included
- it **paraphrases** what Claude says

The paraphrasing was the real problem. Asked "tell me more", it once **invented deadlines** ("by Thursday… by Friday…") that Claude never said. A voice layer that makes things up breaks the one rule of the project.

So I split it into a plain cascade: transcribe, Claude, read aloud verbatim. It costs about **$0.002 per exchange**, billed per use. GPT-Live stayed around as a switchable "natural mode" for a few hours, got used once in ~25 runs, and was deleted along with ~400 lines.

### Keep Claude warm

The first end-to-end test took **21.6 seconds** from question to answer. Most of that was a cold `query()` per question: a fresh Claude Code process, a ~27k-token system prompt, then the actual work.

Switching to one long-lived `ClaudeSDKClient`, warmed up at start, brought the same kind of question down to **5.5 s**. (Fun fact: the warm-up message, translated, is "Saturday is starting up, you don't need to do anything, just reply: OK.")

### Sonnet in front, Opus in the back

I benchmarked the front model on six everyday repo questions, all at low effort:

| Model | Correct | Median time | Median answer |
|-------|---------|-------------|---------------|
| Haiku 5.5 | 6/6 | 4.2 s | 61 chars |
| Sonnet 5.5 | 6/6 | 2.1–2.7 s | 34–39 chars |
| Opus 5.5 | 6/6 | 2.1–5.2 s | 28–33 chars |

Haiku, the "fast" model, was slower than Sonnet: it made the most tool calls and talked the most. Opus won one run and lost the rematch. Sonnet was fast both times, so it sits in front, and Opus does the deep work in the background.

### One sentence, no narration

Spoken answers have to be short. The prompt says: one sentence of conclusion, no code, no paths, no lists, don't restate the question, don't narrate what you checked. Answers went from 3–4 sentences to a median of about 35 characters.

Code and diffs belong on a screen, not in my ear. Nobody wants to hear "slash src slash saturday slash economy dot py".

### Let Claude Code do the security

The brain's lockdown is mostly configuration, not code:

```python
MAIN_CANNOT = ["Edit", "Write", "NotebookEdit"]
MAIN_SANDBOX = {"enabled": True, "allowUnsandboxedCommands": False}
# plus deny rules passed through settings: Edit(//<workspace>/**), Read(**/.env), ...
```

I first wrote my own shell-command guard. Then a probe showed Claude Code's **sandbox** does it better: `cat alpha/.env` gets "Operation not permitted" from the OS itself, whatever the command looks like. The hand-written parser went away, and a round of "does Claude Code already do this?" cleanup removed about 770 lines of Python.

---

## 6) Problems we hit

### She heard herself

Over the MacBook speakers, Saturday's voice reached the mic **14–16 dB above room noise**. In other words, she kept answering herself. Very relatable, but not useful.

![An orb talking into a speaker while the microphone next to it picks up the same words, in an infinite loop](/images/saturday-voice-claude-code/image-2.png)

The fix is the echo canceller FaceTime uses: macOS **voice processing**, through a small Swift helper running `AVAudioEngine`. Gotchas, in order of discovery:

- enabling it before touching the output node fails with `-10875`
- the MacBook mic suddenly shows **9 channels** (the mic array), all carrying the same processed signal
- it needs about **1.5 s** of her speech to adapt, then cancels **30–43 dB**

So the helper stays running for the whole session, playback goes through the same engine (otherwise the canceller has no reference), and the mic is gated for her first second and a half.

### Everything interrupted her

The first barge-in version stopped her for any sound: a cough, an "mm-hm", a colleague walking by. Now, while she's speaking, **only "Saturday, …" interrupts**. Anything else is held back locally and never even sent to be transcribed. The same local wake-word model does the check.

### Pauses split my questions

I pause mid-sentence. Everyone does. A 1-second pause meant "end of sentence", so "Saturday, in Kaka, uh…" became a question, and so did the rest.

The fix: a **turn** is everything I say until she starts answering. If I keep talking before her first word, the fragments are merged and the half-finished answer is dropped.

### Answers came out one behind

This one was spooky. Answers got cut off after a second, then the *next* answer was the previous one's tail, choppy. The archive showed it plainly: a 218-character reply got 0.9 s of audio, the next 109-character reply got 16.35 s.

Cause: all readings share one WebSocket. When Claude's answer arrived while the filler ("One sec.") was still playing, I cancelled the filler **on my side only**. The server kept streaming it, and the next reading swallowed its tail.

Fix: tag every `response.create` with metadata, accept only events with our own `response_id`, and send `response.cancel` with that id when a reading is cut short. The same 108-character sentence went from 2.2 s of audio to 8.4 s. Turns out "one behind" was literally one response behind.

### AirPods broke the audio silently

Connecting AirPods (or plugging in a display) stops `AVAudioEngine` without an error. Restarting the helper process made things worse: starting one voice-processing engine stops any other, so a fresh process kicked off a restart loop.

Now the helper rebuilds its audio graph in place, a watchdog restarts it only if the mic stream stalls, and Saturday follows the Mac's output device at runtime. AirPods in: headphone mode, no echo cancelling (it would force them into low-quality call mode). AirPods out: back to the speakers with echo cancelling on.

---

## 7) What's next

From the roadmap:

- **Remote servers.** Ask about training runs, GPUs and logs on a server. Either Claude runs commands over SSH from the Mac, or the brain moves to the server and only the voice stays local. The event stream is already JSON lines, so the second option is "just" a tunnel.
- **A display screen.** Push diffs, tables and charts to a screen and say "look at the second file on the left" instead of reading anything out.
- **Mac notifications** when a long task finishes or needs a decision and I'm not looking.
- **An honesty eval**: 20 questions to check the voice layer never answers on its own or embellishes.
- **A 20-minute stability run**, the last unchecked box from Phase 1.

---

## 8) Wrap-up

The whole project took two calendar days and 79 commits, and most of the good decisions were *removals*: the fancy duplex voice model, the hand-written guard, Claude Code's own background tasks (Saturday's workers are the one background system now).

What's left is small on purpose:

- ears and a mouth that never think
- one warm Claude Code conversation that reads everything and changes nothing
- workers inside each project that follow that project's rules
- a screen for anything that needs a yes

And yes, this post was drafted by one of Saturday's workers, dispatched with `work_in` from Saturday's main conversation. It did not ask for permission to make jokes. It probably should have.
