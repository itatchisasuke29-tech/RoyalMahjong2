extends Node

# ---------------------------------------------------------------------------
# SoundManager — Procedural audio. No audio files required.
# All sounds are sine waves generated at runtime via AudioStreamGenerator.
# ---------------------------------------------------------------------------

const SAMPLE_RATE: float = 44100.0

func _ready() -> void:
	GameManager.tile_clicked.connect(_on_tile_clicked)
	GameManager.match_made.connect(_on_match_made)
	GameManager.boss_damaged.connect(_on_boss_damaged)
	GameManager.board_cleared.connect(_on_board_cleared)
	GameManager.game_over.connect(_on_game_over)

# ---------------------------------------------------------------------------
# Signal handlers
# ---------------------------------------------------------------------------
func _on_tile_clicked(_tile: Node) -> void:
	_play_tone(680.0, 0.06, 0.22)

func _on_match_made(_t1, _t2) -> void:
	_play_tone(523.0, 0.12, 0.30)
	await get_tree().create_timer(0.10).timeout
	_play_tone(784.0, 0.18, 0.30)

func _on_boss_damaged(_hp: int, _max: int) -> void:
	_play_tone(180.0, 0.10, 0.28)

func _on_board_cleared() -> void:
	# C5 → E5 → G5 → C6 fanfare
	var notes: Array[float] = [523.0, 659.0, 784.0, 1047.0]
	for note in notes:
		_play_tone(note, 0.18, 0.35)
		await get_tree().create_timer(0.15).timeout

func _on_game_over() -> void:
	_play_tone(300.0, 0.15, 0.28)
	await get_tree().create_timer(0.13).timeout
	_play_tone(200.0, 0.35, 0.25)

# ---------------------------------------------------------------------------
# Core tone generator — sine wave with attack + fade-out envelope
# ---------------------------------------------------------------------------
func _play_tone(freq: float, dur: float, vol: float = 0.3) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)

	var gen := AudioStreamGenerator.new()
	gen.mix_rate      = SAMPLE_RATE
	gen.buffer_length = dur + 0.05
	player.stream = gen
	player.play()

	var pb  := player.get_stream_playback() as AudioStreamGeneratorPlayback
	var n   := int(SAMPLE_RATE * dur)
	var atk := int(SAMPLE_RATE * 0.008)  # 8ms attack to avoid click artifacts

	for i in range(n):
		var t:   float = float(i) / SAMPLE_RATE
		var env: float = 1.0 - (t / dur)        # linear fade-out
		if i < atk:
			env *= float(i) / float(atk)         # linear attack
		var s: float = sin(TAU * freq * t) * vol * env
		pb.push_frame(Vector2(s, s))

	# Clean up the node after the sound finishes
	get_tree().create_timer(dur + 0.2).timeout.connect(func(): player.queue_free())
