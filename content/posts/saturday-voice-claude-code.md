+++
title = 'Saturday: Claude Code with Ears and a Mouth'
date = 2026-11-04T00:00:00+09:00
tags = ["claude-code", "voice", "agent-sdk", "openai-realtime", "python"]
+++

**Saturday** is a hands-free voice assistant I built on top of Claude Code. I say "Saturday", ask a question about any of my projects, and get a one-sentence spoken answer four to six seconds later, for roughly $0.002 an exchange. Real changes go to a Claude Code session started inside the right project, and anything risky waits for a key press on screen.

The one design rule: **the voice layer never thinks.** Speech-to-text and text-to-speech are only ears and a mouth. Every answer, every file read, every edit comes from Claude Code. This post covers how that's wired up, why it ended up this way, and what broke along the way.

## Try it

A scripted run of three real behaviours. The orb is cyan while I talk, violet while Claude works, amber while she speaks. In the second scenario you play me, so the permission prompt is yours to answer. Try saying "yes" out loud first.

{{< saturday-demo >}}

## How it's built

{{< saturday-architecture >}}

| Part | What does it | Notes |
| --- | --- | --- |
| Wake word | Whisper small (MLX), on the Mac | 14/14 test clips, ~190 ms. Nothing is streamed or billed in standby. |
| Ears | `gpt-live-transcribe` | Streams while I talk. A 1 s pause ends the sentence; the text is ready ~1.6 s after I stop. |
| Brain | One warm Claude Code session (Agent SDK) at `~/workspace` | Sonnet, low effort, on my Claude subscription. Reads everything, changes nothing. |
| Mouth | `gpt-realtime-2.1-mini` | Reads Claude's sentence word for word, ~$0.002 per reply. |
| Workers | A Claude Code session inside each project | Sonnet for quick changes, Opus for deep work. Started through one tool, `work_in`. |

If Claude hasn't answered after 2.5 s, she says a short filler like "Let me check." After 10 s with nobody talking and no task running, she goes back to standby.

Under the hood, Saturday is a core that publishes events as JSON lines, plus frontends that only render them: the terminal UI, a `--headless` mode, and `--replay` for any recorded session. Every run is recorded to `~/.saturday/sessions/`, so debugging a freeze means replaying it, not asking for screenshots.

## Why the voice layer isn't allowed to think

The first version used **GPT-Live-1**, a full-duplex voice model that hands reasoning to your own backend. It sounded natural, but it had two problems:

- It bills **$0.05 per connected minute**, silence included. That's about $3 an hour.
- It **paraphrases** the backend's answer. In one test, asked for more detail, it invented deadlines ("by Thursday… by Friday…") that Claude never said.

A voice layer that adds facts breaks the whole point. So I replaced it with a plain cascade: transcribe, ask Claude, read the answer aloud verbatim. In tests, four of four scripted answers were read word for word, and one exchange over the laptop speakers cost $0.0036 end to end. GPT-Live stayed around for a few hours as an optional "natural mode", was used once in about 25 runs, and was deleted with roughly 400 lines of code.

## One conversation reads, workers write

I only ever talk to one conversation: the brain, sitting at `~/workspace`. It can read any project and answer questions about it, but it can't edit anything. Changes, commands with side effects and long investigations go through `work_in`:

```python
@tool(
    "work_in",
    "Hand work to Saturday's worker inside one of LUO's projects: a Claude Code session "
    "started in that project's folder, so its CLAUDE.md, permission rules and hooks "
    "apply. Use it for any change (editing or writing files, commands with side effects, "
    "commits) and for heavy work (deep investigation, debugging, design). Runs in the "
    "background and returns at once; the result comes back to you as a message.",
    ...
)
```

The reason for the split is a Claude Code detail: **a session loads a project's CLAUDE.md, `.claude/settings.json` and hooks only from the directory it was launched in.** A brain at `~/workspace` editing my Kaka app would ignore Kaka's rules. In a test workspace, one project's own deny rule stopped that project's worker without even a prompt, and the root-level session would not have been bound by it at all.

So every project gets its own worker: one per project, tasks queued, session resumed across restarts. The brain answers "on it" immediately, the worker runs in the background, and when it finishes she speaks up on her own with the result.

Keeping the brain read-only took configuration, not code:

```python
MAIN_CANNOT = ["Edit", "Write", "NotebookEdit"]
MAIN_SANDBOX = {"enabled": True, "allowUnsandboxedCommands": False}
# plus deny rules passed through settings, e.g. Edit(//<workspace>/**) and Read(**/.env)
```

I first wrote my own shell-command guard. A probe showed Claude Code's sandbox does the job better: `cat alpha/.env` fails with "Operation not permitted" from the OS, however the command is phrased. The guard's parser went away. A later review of everything Claude Code already provides cut about 770 lines of Python.

## Confirmations are key presses, not words

Workers run in Claude Code's **auto mode**, as in my terminal. Before that, a single Kaka task put five harmless shell reads in a row on screen for approval, which made the assistant tiresome. In auto mode, Claude Code's own classifier approves safe actions and stops risky ones.

Whatever Claude Code still wants to ask about arrives through the SDK's `can_use_tool` callback. Saturday shows it as a panel: a plain-words headline, which of my requests it serves, and the diff or command underneath. I answer with `y` (allow), `a` (always) or `n` (no).

**Saying "yes" doesn't count.** Speech recognition is good, not perfect, and a misheard "yes" in front of `git push` is a bad trade. If I ask about the prompt out loud, she explains it and tells me which key to press.

## Making it fast enough to talk to

The first end-to-end run took **21.6 s** from question to answer. Most of that was a fresh `query()` per question: a new Claude Code process, a ~27k-token system prompt, then several file reads. One long-lived `ClaudeSDKClient`, warmed up at start, brought the same kind of question down to **5.5 s**.

Then I picked the front model with six everyday questions about the repo, each model on its own warm session at low effort:

| Model | Correct | Median time | Median answer |
| --- | --- | --- | --- |
| Haiku | 6/6 | 4.2 s | 61 chars |
| Sonnet | 6/6 | 2.7 s, then 2.1 s | 39, then 34 chars |
| Opus | 6/6 | 2.1 s, then 5.2 s | 28, then 33 chars |

Haiku was slower than Sonnet because it made the most tool calls and said the most. Opus won the first run and lost the rerun. Sonnet was fast both times, so it answers, and Opus does the deep work in the background.

Short answers matter as much as fast ones. The prompt asks for one sentence of conclusion: no code, paths, lists or markdown, no restating the question, no narrating what was checked. Answers went from three or four sentences to a median of about 35 characters. Code and diffs belong on a screen.

Today her first word comes 4–6 s after I stop talking, depending on how much Claude has to read. Claude's own time is now the biggest part of that.

## What broke

**She heard herself.** Over the MacBook speakers, her voice reached the mic 14–16 dB above room noise, enough to be transcribed as me. The fix is macOS voice processing, the echo canceller FaceTime uses, through a small Swift helper running `AVAudioEngine`. It needs about 1.5 s of her speech to adapt and then cancels 30–43 dB, so the helper runs for the whole session, playback goes through the same engine, and the mic is gated until it has adapted. Two surprises on the way: enabling it before touching the output node fails with error `-10875`, and the mic suddenly reports 9 channels.

**Anything interrupted her.** A cough or an "mm-hm" used to stop her mid-sentence. Now, while she speaks, only speech that starts with "Saturday" interrupts. Everything else is held back locally and never sent to be transcribed.

**Pauses split my questions.** The end-of-sentence pause started at 0.8 s and went down to 0.6 s, which cut questions in half whenever I stopped to think. It's 1 s now. On top of that, everything I say before her first word counts as one turn: fragments are merged, and an answer to half a question is dropped.

**Answers came out one behind.** An answer cut off after a second, then the next answer started with the previous one's tail. The archive showed it plainly: 218 characters got 0.9 s of audio, and the next 109 characters got 16.35 s. All readings share one WebSocket, and when the real answer cut a filler short, I cancelled the filler on my side only. The server kept streaming it into the next reading. Now each `response.create` is tagged, only events with our own `response_id` are accepted, and a cut reading is cancelled on the server too. The same 108-character sentence went from 2.2 s of audio to 8.4 s.

**AirPods broke the audio silently.** A device change stops `AVAudioEngine` without an error, and restarting the helper made it worse: starting one voice-processing engine stops any other, so fresh processes looped. The helper now rebuilds its audio graph in place, and Saturday checks the Mac's output device every second. With AirPods it uses plain audio, because voice processing would force them into low-quality call mode. On speakers it turns echo cancellation back on.

## What's next

From the roadmap:

- **Remote servers.** Ask about training runs, GPUs and logs. Either Claude runs commands over SSH from the Mac, or the brain moves to the server and only the voice stays local. Since the event stream is already JSON lines, the second option is mostly a tunnel.
- **A display screen.** Diffs, tables and charts go to a screen, and she says "look at the second file on the left" instead of reading anything out.
- **Checks still open.** A Mac notification when a task needs me, a 20-question eval that the voice layer never answers or embellishes on its own, and a 20-minute continuous run.

The git history runs from late on November 3 to the next afternoon: 79 commits. The decisions that helped most were removals: the duplex voice model, the hand-written guard, and Claude Code's own background tasks, so that workers are the only background system. What's left is deliberately small. It's two ears and a mouth, one conversation that reads everything, and a worker in each project that follows that project's rules.

One more thing: this post was written by one of those workers.
