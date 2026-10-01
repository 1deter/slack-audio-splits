# BO3 Split Audio

This is the BO3 Zombies auto splitter with one thing added: **it can play a sound when a split happens.** You can give each split its own sound, a delay, and a volume.

Splitting and timing work exactly like before.

---

## Setup (about 5 minutes, only once)

### Step 1: Download the file

1. Click **`cbrnn_bo3_asl.asl`** in the file list at the top of this page.
2. Click the **download button** (the arrow pointing down, top right of the file).
3. Move the downloaded file into your **LiveSplit folder**, the one with `LiveSplit.exe` in it, so it doesn't get lost.

### Step 2: Turn off the old auto splitter

*Skip this step if you've never used the "Activate" button for BO3.*

1. Right click LiveSplit → **Edit Splits…**
2. If there's a **Deactivate** button next to the game name, click it.
3. Click **OK**.

### Step 3: Add the new one to your layout

1. Right click LiveSplit → **Edit Layout…**
2. Click the **+** button → **Control** → **Scriptable Auto Splitter**.
3. Double click **Scriptable Auto Splitter** in the list.
4. Click **Browse…** and pick `cbrnn_bo3_asl.asl`.
5. A popup says **"Split audio is set up!"** Click **Yes** to open the `AudioSplits` folder it just made.
6. Click **OK**, then **OK** again.
7. Right click LiveSplit → **Save Layout** so it remembers this next time.

### Step 4: Add your sounds

1. Put your sound files into the **`AudioSplits`** folder. It's inside your LiveSplit folder. `.mp3` and `.wav` both work.
2. Open **`audio_splits.txt`** in that same folder (double click it, it opens in Notepad).
3. Every split is already listed. Type a sound file name after the `=` on any split you want a sound for:

   ```
   Bow            = bow.mp3
   Rocket Test TP =
   First TP       = tp.mp3
   ```

4. Save the file (**Ctrl + S**). Done!

Splits with nothing after the `=` just don't play a sound.

---

## Delay and volume (optional)

Add them after the file name, separated by `|` (Shift + the key above Enter):

```
Split Name = sound file | delay in seconds | volume %
```

| What you type | What happens |
|---|---|
| `Bow = bow.mp3` | Plays right away, full volume |
| `Bow = bow.mp3 \| 3` | Plays 3 seconds after the split |
| `Bow = bow.mp3 \| 0 \| 50` | Plays right away at 50% volume |
| `Bow = bow.mp3 \| 1.5 \| 70` | Plays 1.5 seconds after the split at 70% volume |

You can edit and save `audio_splits.txt` whenever you want, even mid-run. The changes apply on the next split.

---

## Settings

Right click LiveSplit → **Edit Layout…** → **Layout Settings** → the **Scriptable Auto Splitter** tab. Under **Split audio**:

- **Split audio**: untick this to turn all sounds off.
- **Cancel delayed sounds that haven't played yet when the timer resets** (on by default): if you reset while a delayed sound is still waiting to play, it won't play.
- **Stop sounds that are already playing when the timer resets** (off by default): resetting cuts off any sound that's playing.
- **Test: play a sound when you start the timer** (off by default): see *Can't hear anything?* below.

If you untick a split in the auto splitter settings, it won't split and won't play its sound.

---

## Can't hear anything?

Go through these in order.

### 1. Check that Windows isn't muting LiveSplit

This is the most common cause, especially if LiveSplit's own built-in sound feature was silent too.

1. Open LiveSplit.
2. Right click the **speaker icon** in the bottom right of your taskbar → **Open volume mixer**.
3. Find **LiveSplit** in the list of apps:
   - Make sure it isn't **muted** and its volume isn't at **0**.
   - Click the little arrow next to it and check its **Output device**. It should be the same headphones/speakers you hear the game on (or *Default*).

LiveSplit only shows up in that list while it's open. If you use something like Voicemeeter or a separate audio interface for streaming, LiveSplit has to be sent to whatever you're listening on.

### 2. Do a test without the game

1. Right click LiveSplit → **Edit Layout…** → **Layout Settings** → **Scriptable Auto Splitter** tab.
2. Tick **Test: play a sound when you start the timer**. It's under *Split audio*.
3. Click **OK**, then press your **start** hotkey (or right click LiveSplit → **Start**). The game doesn't need to be open.
4. You should hear the first sound from your `audio_splits.txt`, or a Windows chime if you haven't set any yet.
5. Reset the timer, and untick the test option when you're done.

If you hear the test sound, your audio works. Go to step 3 to see what happens during a real split.

### 3. Send the log file

The script writes everything it does to **`split_audio_log.txt`** in the `AudioSplits` folder: every split it sees, whether it found the sound file, and whether the sound actually started playing. Reproduce the problem (do the test, or play until a split that should make a sound), then send that file over. It starts fresh every time LiveSplit opens, so send it before restarting LiveSplit.

---

## Something else not working?

- **No sound:** check that the file name in `audio_splits.txt` matches the real file exactly, including `.mp3` / `.wav`. Windows hides file extensions by default. To see them, turn on *View → Show → File name extensions* in File Explorer.
- **Some sounds play but one doesn't:** that file is probably broken, even if it opens fine elsewhere. Re-record it or re-export it (any audio editor or online converter works) and try again. The log file will say something like *"not a valid wave file"* if this is the problem.
- **No popup and no `AudioSplits` folder:** LiveSplit can't save files where it's installed (usually because it's inside `Program Files`). Move the whole LiveSplit folder to your Desktop or Documents and do setup Step 3 again.
- **It splits but never makes a sound:** make sure you did setup Step 2. Otherwise the old auto splitter is running instead of this one.
