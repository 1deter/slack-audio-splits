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

If you untick a split in the auto splitter settings, it won't split and won't play its sound.

---

## Something not working?

- **No sound:** check that the file name in `audio_splits.txt` matches the real file exactly, including `.mp3` / `.wav`. Windows hides file extensions by default. To see them, turn on *View → Show → File name extensions* in File Explorer.
- **No popup and no `AudioSplits` folder:** LiveSplit can't save files where it's installed (usually because it's inside `Program Files`). Move the whole LiveSplit folder to your Desktop or Documents and do Step 3 again.
- **It splits but never makes a sound:** make sure you did Step 2. Otherwise the old auto splitter is running instead of this one.
