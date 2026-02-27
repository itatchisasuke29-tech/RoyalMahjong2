extends Node

# ---------------------------------------------------------------------------
# AdManager — Rewarded Ad Controller
# Autoload singleton. Handles ad requests for powerup rewards.
#
# STUB MODE (current): grants reward immediately without showing a real ad.
# This lets you build and test the full reward flow right now.
#
# TO WIRE IN REAL ADS LATER:
#   1. Install the AdMob or AppLovin MAX GDExtension plugin for Godot 4
#   2. Replace the body of _request_admob() or _request_applovin() below
#   3. Connect the plugin's reward callback to _on_reward_earned()
# ---------------------------------------------------------------------------

signal reward_granted(reward_type: String)

# Set to false once a real ad plugin is installed and ready
const STUB_MODE: bool = true

# Ad unit IDs — fill these in when you have a real AdMob / AppLovin account
const ADMOB_REWARDED_ID:    String = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
const APPLOVIN_REWARDED_ID: String = "YOUR_APPLOVIN_ZONE_ID"

var _pending_reward: String = ""

# ---------------------------------------------------------------------------
# Public API — call this when the player wants a rewarded powerup
# ---------------------------------------------------------------------------
func show_rewarded_ad(reward_type: String) -> void:
	_pending_reward = reward_type

	if STUB_MODE:
		# In stub mode: skip the ad and grant the reward after a short delay
		await get_tree().create_timer(0.1).timeout
		_on_reward_earned()
		return

	# TODO: uncomment whichever SDK you install
	# _request_admob()
	# _request_applovin()

# ---------------------------------------------------------------------------
# SDK integration stubs — replace bodies when plugin is installed
# ---------------------------------------------------------------------------
func _request_admob() -> void:
	# TODO: AdMob GDExtension (godot-admob-android / godot-admob-ios)
	# Example:
	#   AdMob.show_rewarded(ADMOB_REWARDED_ID)
	#   AdMob.rewarded_ad_reward.connect(_on_reward_earned, CONNECT_ONE_SHOT)
	pass

func _request_applovin() -> void:
	# TODO: AppLovin MAX GDExtension
	# Example:
	#   AppLovinMAX.show_rewarded_ad(APPLOVIN_REWARDED_ID)
	#   AppLovinMAX.on_rewarded_ad_received.connect(_on_reward_earned, CONNECT_ONE_SHOT)
	pass

# ---------------------------------------------------------------------------
# Called by the SDK callback (or stub) when the player earns the reward
# ---------------------------------------------------------------------------
func _on_reward_earned() -> void:
	if _pending_reward.is_empty():
		return
	reward_granted.emit(_pending_reward)
	_pending_reward = ""
