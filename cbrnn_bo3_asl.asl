state("blackops3")
{
    byte round_counter : 0xA55BDEC;
    int level_time : 0xA6424FC;
    string13 map_name : 0x179DF840;
    int split : 0x17B3C3C8; // 0x17B3C3A8;
}

startup
{
    vars.time_offset = 0;
    timer.CurrentTimingMethod = TimingMethod.GameTime;

    vars.split_names = new Dictionary<string, Dictionary<int, string>>()
    {
        {
            "zm_zod", new Dictionary<int, string>()
            {
                {0, "Rift"},
                {1, "Sword"},
                {2, "Flag"},
                {3, "SOE Egg End"}
            }
        },
	{
            "zm_factory", new Dictionary<int, string>()
            {
                {0, "The Giant Egg End"}
            }
        },
        {
            "zm_castle", new Dictionary<int, string>()
            {
                {0, "Bow"},
                {1, "Rocket Test TP"},
                {2, "First TP"},
                {3, "Key Place"},
                {4, "DE Boss Enter"},
                {5, "DE Egg End"}
            }
        },
        {
            "zm_island", new Dictionary<int, string>()
            {
                {0, "Bunker"},
                {1, "Skull"},
                {2, "KT-4"},
                {3, "ZNS Boss Enter"},
                {4, "ZNS Egg End"}
            }
        },
        {
            "zm_stalingrad", new Dictionary<int, string>()
            {
                {0, "Fly 1"},
                {1, "Fly 2"},
                {2, "Challenge Start"},
                {3, "Keycard Lockdown"},
                {4, "Button Press"},
                {5, "GK Egg End"}
            }
        },
        {
            "zm_genesis", new Dictionary<int, string>()
            {
                {0, "Keeper Start"},
                {1, "Squid Leave"},
                {2, "House"},
                {3, "Boss 1"},
                {4, "Basketball"},
                {5, "Boss 2"},
                {6, "Rev Egg End"}
            }
        },
        {
            "zm_tomb", new Dictionary<int, string>()
            {
                {0, "Ice Craft"},
                {1, "Fire Enter"},
		{2, "Lightning Enter"},
                {3, "Lightning Craft"},
                {4, "Ice Leave"},
                {5, "Upgrade"},
                {6, "Fists"},
                {7, "Origins Egg End"}
            }
        },
	{
            "zm_moon", new Dictionary<int, string>()
            {
                {0, "Samantha Says"},
                {1, "Hack Complete"},
                {2, "Ball"},
                {3, "Canister 1"},
                {4, "Canister 2"},
                {5, "Moon Egg End"}
            }
        }
    };

	foreach(var map in vars.split_names.Keys) {
		settings.Add(map, true, map);
        var splitDict = vars.split_names[map];
        // Cant get for loops to work when logic is sound here. Going with this instead
        for (var i=0;i<splitDict.Count;i++) {
            settings.Add(splitDict[i], true, splitDict[i], map);
        }

    };

    // =====================================================================
    // Split audio
    //
    // Plays a sound when a split triggers. Which sound goes with which split
    // (plus an optional delay and volume) is set in:
    //     <LiveSplit folder>\AudioSplits\audio_splits.txt
    // That file is created automatically the first time this script loads.
    //
    // Note: LiveSplit rewrites every "return;" in a script to "return null;"
    // before compiling, so the helpers below avoid early returns on purpose.
    // =====================================================================
    settings.Add("split_audio", true, "Split audio");
    settings.SetToolTip("split_audio", "Play a sound when a split triggers.\nSounds are picked in LiveSplit\\AudioSplits\\audio_splits.txt");
    settings.Add("split_audio_cancel_on_reset", true, "Cancel delayed sounds that haven't played yet when the timer resets", "split_audio");
    settings.Add("split_audio_stop_on_reset", false, "Stop sounds that are already playing when the timer resets", "split_audio");

    vars.audio_cancel_on_reset = true;
    vars.audio_stop_on_reset = false;

    Dictionary<string, Dictionary<int, string>> split_names = vars.split_names;
    var map_titles = new Dictionary<string, string>()
    {
        {"zm_zod", "Shadows of Evil"},
        {"zm_factory", "The Giant"},
        {"zm_castle", "Der Eisendrache"},
        {"zm_island", "Zetsubou No Shima"},
        {"zm_stalingrad", "Gorod Krovi"},
        {"zm_genesis", "Revelations"},
        {"zm_tomb", "Origins"},
        {"zm_moon", "Moon"}
    };

    string audio_dir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "AudioSplits");
    string audio_config = Path.Combine(audio_dir, "audio_splits.txt");

    // First run: write a config listing every split so it just needs filling in.
    if (!File.Exists(audio_config))
    {
        try
        {
            Directory.CreateDirectory(audio_dir);
            var sb = new StringBuilder();
            sb.AppendLine("# =======================================================================");
            sb.AppendLine("#  BO3 Split Audio");
            sb.AppendLine("# =======================================================================");
            sb.AppendLine("#  Put a sound next to any split you want. Format:");
            sb.AppendLine("#");
            sb.AppendLine("#      Split Name = sound file | delay in seconds | volume %");
            sb.AppendLine("#");
            sb.AppendLine("#  Only the sound file is required. Examples:");
            sb.AppendLine("#");
            sb.AppendLine("#      Bow        = bow.mp3                  (plays instantly, full volume)");
            sb.AppendLine("#      First TP   = tp.wav | 2.5             (plays 2.5 seconds after the split)");
            sb.AppendLine("#      DE Egg End = C:\\Sounds\\gg.mp3 | 0 | 60  (instant, 60% volume)");
            sb.AppendLine("#");
            sb.AppendLine("#  - .wav, .mp3, .wma, .m4a etc. all work.");
            sb.AppendLine("#  - A plain file name means the file is in this folder (AudioSplits).");
            sb.AppendLine("#    You can also use a full path to a file anywhere.");
            sb.AppendLine("#  - Leave the right side empty for no sound on that split.");
            sb.AppendLine("#  - Save this file and the changes apply on the next split, no restart needed.");
            sb.AppendLine("#  - Sounds only play when the split actually triggers, so a split that is");
            sb.AppendLine("#    unticked in the auto splitter settings won't play its sound either.");
            sb.AppendLine("#  - Anything after a # is ignored.");
            sb.AppendLine("# =======================================================================");
            sb.AppendLine();
            foreach (var map in split_names.Keys)
            {
                string title;
                sb.AppendLine("# --- " + (map_titles.TryGetValue(map, out title) ? title + " (" + map + ")" : map) + " ---");
                var map_splits = split_names[map];
                int width = map_splits.Values.Max(n => n.Length);
                for (int i = 0; i < map_splits.Count; i++)
                    sb.AppendLine(map_splits[i].PadRight(width) + " = ");
                sb.AppendLine();
            }
            File.WriteAllText(audio_config, sb.ToString());
            print("[Split audio] Created " + audio_config);

            var answer = System.Windows.Forms.MessageBox.Show(
                "Split audio is set up!\n\n" +
                "Pick a sound for each split in:\n" + audio_config + "\n\n" +
                "Open the AudioSplits folder now?",
                "BO3 Split Audio", System.Windows.Forms.MessageBoxButtons.YesNo, System.Windows.Forms.MessageBoxIcon.Information);
            if (answer == System.Windows.Forms.DialogResult.Yes)
                Process.Start(audio_dir);
        }
        catch (Exception ex)
        {
            print("[Split audio] Couldn't create " + audio_config + ": " + ex.Message);
        }
    }

    // ---- config -----------------------------------------------------------
    // split name -> (full path, delay in seconds, volume 0..1)
    var audio_sounds = new Dictionary<string, Tuple<string, double, double>>(StringComparer.OrdinalIgnoreCase);
    DateTime audio_config_time = DateTime.MinValue;

    Func<string, double, double> parse_number = (text, fallback) =>
    {
        text = text.Trim().TrimEnd('s', 'S', '%').Trim().Replace(',', '.');
        double value;
        return double.TryParse(text, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out value) ? value : fallback;
    };

    // Re-reads the config whenever the file has been saved since the last read.
    Action audio_reload = () =>
    {
        try
        {
            DateTime stamp = File.GetLastWriteTimeUtc(audio_config);
            if (stamp != audio_config_time)
            {
                var sounds = new Dictionary<string, Tuple<string, double, double>>(StringComparer.OrdinalIgnoreCase);
                if (File.Exists(audio_config))
                {
                    foreach (string raw in File.ReadAllLines(audio_config))
                    {
                        string line = raw;
                        int hash = line.IndexOf('#');
                        if (hash >= 0)
                            line = line.Substring(0, hash);
                        int eq = line.IndexOf('=');
                        if (eq < 0)
                            continue;

                        string name = line.Substring(0, eq).Trim();
                        string[] parts = line.Substring(eq + 1).Split('|');
                        string file = parts[0].Trim().Trim('"').Trim();
                        if (name.Length == 0 || file.Length == 0)
                            continue;

                        double delay = parts.Length > 1 ? parse_number(parts[1], 0) : 0;
                        double volume = parts.Length > 2 ? parse_number(parts[2], 100) : 100;
                        if (!Path.IsPathRooted(file))
                            file = Path.Combine(audio_dir, file);
                        sounds[name] = Tuple.Create(file, Math.Max(0, delay), Math.Max(0, Math.Min(100, volume)) / 100.0);
                    }
                }

                audio_sounds = sounds;
                audio_config_time = stamp;
                print("[Split audio] Loaded " + sounds.Count + " sound(s) from " + audio_config);
            }
        }
        catch (Exception ex)
        {
            // Most likely the file is mid-save; it gets retried on the next split.
            print("[Split audio] Couldn't read " + audio_config + ": " + ex.Message);
        }
    };

    // ---- playback ---------------------------------------------------------
    // Sounds play through WPF's MediaPlayer (handles mp3/wav/wma/..., volume, and
    // overlapping sounds) on its own thread. ASL doesn't reference the WPF
    // assemblies, so everything goes through reflection/dynamic. If that can't be
    // loaded for some reason it falls back to SoundPlayer, which only does .wav.
    Type audio_player_type = null;
    Type dispatcher_type = null;
    object audio_dispatcher = null;
    System.Reflection.MethodInfo audio_begin_invoke = null;
    var audio_players = new List<object>();
    int audio_generation = 0;

    // Attaches a handler to an event without having to name the event's delegate type.
    Func<object, string, Delegate, Delegate> hook_event = (target, name, handler) =>
    {
        var evt = target.GetType().GetEvent(name);
        var typed = Delegate.CreateDelegate(evt.EventHandlerType, handler.Target, handler.Method);
        evt.AddEventHandler(target, typed);
        return typed;
    };

    // Runs work on the audio thread. Exceptions are caught here because an
    // unhandled one on that thread would take LiveSplit down with it.
    Action<Action> audio_post = (work) =>
    {
        Action safe = () =>
        {
            try { work(); }
            catch (Exception ex) { print("[Split audio] " + ex.Message); }
        };
        if (audio_dispatcher != null)
            audio_begin_invoke.Invoke(audio_dispatcher, new object[] { safe, new object[0] });
        else
            safe();
    };

    try
    {
        var presentation_core = System.Reflection.Assembly.Load("PresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35");
        var windows_base = System.Reflection.Assembly.Load("WindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35");
        audio_player_type = presentation_core.GetType("System.Windows.Media.MediaPlayer", true);
        dispatcher_type = windows_base.GetType("System.Windows.Threading.Dispatcher", true);
        audio_begin_invoke = dispatcher_type.GetMethod("BeginInvoke", new[] { typeof(Delegate), typeof(object[]) });

        var ready = new System.Threading.ManualResetEvent(false);
        var thread = new System.Threading.Thread(() =>
        {
            try
            {
                audio_dispatcher = dispatcher_type.GetProperty("CurrentDispatcher").GetValue(null, null);
                ready.Set();
                dispatcher_type.GetMethod("Run", Type.EmptyTypes).Invoke(null, null);
            }
            catch (Exception ex)
            {
                print("[Split audio] Audio thread stopped: " + ex.Message);
            }
        });
        thread.Name = "BO3 split audio";
        thread.IsBackground = true;
        thread.SetApartmentState(System.Threading.ApartmentState.STA);
        thread.Start();
        ready.WaitOne(3000);
    }
    catch (Exception ex)
    {
        print("[Split audio] MediaPlayer unavailable, only .wav files will play: " + ex.Message);
    }
    if (audio_dispatcher == null)
        audio_player_type = null;

    // Must run on the audio thread (via audio_post).
    Action<string, double> audio_play = (path, volume) =>
    {
        if (audio_player_type == null)
        {
            new System.Media.SoundPlayer(path).Play();
        }
        else
        {
            object player = Activator.CreateInstance(audio_player_type);
            hook_event(player, "MediaEnded", (Action<object, EventArgs>)((s, e) =>
            {
                try
                {
                    audio_players.Remove(player);
                    ((dynamic)player).Close();
                }
                catch { }
            }));
            hook_event(player, "MediaFailed", (Action<object, EventArgs>)((s, e) =>
            {
                try
                {
                    audio_players.Remove(player);
                    print("[Split audio] Couldn't play " + path + ": " + ((dynamic)e).ErrorException.Message);
                }
                catch { }
            }));

            dynamic p = player;
            p.Volume = volume;
            p.Open(new Uri(path));
            p.Play();
            audio_players.Add(player);
        }
    };

    // Must run on the audio thread (via audio_post).
    Action audio_stop_all = () =>
    {
        if (audio_player_type == null)
        {
            new System.Media.SoundPlayer().Stop();
        }
        else
        {
            foreach (dynamic p in audio_players.ToArray())
            {
                p.Stop();
                p.Close();
            }
            audio_players.Clear();
        }
    };

    // Called from the split block with the name of the split that just happened.
    vars.QueueSplitAudio = (Action<string>)(split_name =>
    {
        audio_reload();
        Tuple<string, double, double> sound;
        if (audio_sounds.TryGetValue(split_name, out sound))
        {
            string path = sound.Item1;
            double delay = sound.Item2;
            double volume = sound.Item3;
            if (!File.Exists(path))
            {
                print("[Split audio] Sound file for \"" + split_name + "\" not found: " + path);
            }
            else if (delay <= 0)
            {
                print("[Split audio] " + split_name + " -> " + Path.GetFileName(path));
                audio_post(() => audio_play(path, volume));
            }
            else
            {
                print("[Split audio] " + split_name + " -> " + Path.GetFileName(path) + " in " + delay + "s");
                int generation = System.Threading.Interlocked.CompareExchange(ref audio_generation, 0, 0);
                System.Threading.Tasks.Task.Delay(TimeSpan.FromSeconds(delay)).ContinueWith(t =>
                {
                    // A reset since this was queued bumps the generation, which cancels it.
                    if (System.Threading.Interlocked.CompareExchange(ref audio_generation, 0, 0) == generation)
                        audio_post(() => audio_play(path, volume));
                });
            }
        }
    });

    Delegate reset_handler = null;
    try
    {
        reset_handler = hook_event(timer, "OnReset", (Action<object, TimerPhase>)((s, phase) =>
        {
            if (vars.audio_cancel_on_reset)
                System.Threading.Interlocked.Increment(ref audio_generation);
            if (vars.audio_stop_on_reset)
                audio_post(audio_stop_all);
        }));
    }
    catch (Exception ex)
    {
        print("[Split audio] Couldn't watch for resets: " + ex.Message);
    }

    vars.ShutdownAudio = (Action)(() =>
    {
        if (reset_handler != null)
            timer.GetType().GetEvent("OnReset").RemoveEventHandler(timer, reset_handler);
        if (audio_dispatcher != null)
        {
            audio_post(() =>
            {
                audio_stop_all();
                dispatcher_type.GetMethod("InvokeShutdown").Invoke(audio_dispatcher, null);
            });
        }
    });

    audio_reload();
}

update
{
    // The reset handler can't read settings itself, so keep a copy for it.
    vars.audio_cancel_on_reset = settings["split_audio_cancel_on_reset"];
    vars.audio_stop_on_reset = settings["split_audio_stop_on_reset"];
}

start
{
	if(current.round_counter == 1 && current.round_counter > old.round_counter)
    {
        vars.time_offset = current.level_time;
        return true;
    }
}

split
{
    if (current.map_name == null || !vars.split_names.ContainsKey(current.map_name))
        return false;
    var split_map = vars.split_names[current.map_name];
    if (!split_map.ContainsKey(old.split))
        return false;
    var current_split_name = split_map[old.split];
    if (settings[current_split_name] && current.split > old.split) {
        if (settings["split_audio"])
            vars.QueueSplitAudio(current_split_name);
        return true;
    }
    return false;
}

gameTime
{
    return new TimeSpan(0, 0, 0, 0, current.level_time - vars.time_offset);
}

reset
{
    return (current.round_counter == 0 && old.round_counter != 0 || current.split == 0 && old.split != 0 || current.map_name.Equals("core_frontend"));
}

isLoading
{
    return true;
}

shutdown
{
    vars.ShutdownAudio();
}
