@tool
class_name CRTPresets
extends RefCounted
## Ready-made looks for [CRTScreen], as plain parameter dictionaries.
##
## A preset only lists the parameters it changes; everything else falls back to
## the defaults in [CRTSettings]. Apply one with
## [code]crt_screen.apply_preset(CRTPresets.FAMICOM_RF)[/code], or by name with
## [method get_preset].
##
## プリセットは変更するパラメータだけを持ち、残りは [CRTSettings] の既定値に戻ります。

## The shipped defaults: a composite-video television. Every value equals the
## default in [constant CRTSettings.PARAMS], so this preset is an empty override.
const COMPOSITE_TV: Dictionary = {}

## Clean, sharp CRT monitor. RF instability is off; sharpness, halation and a
## small convergence error carry the CRT character.
const CRT_STUDIO: Dictionary = {
	"signal_amount": 0.92, "composite_artifact": 0.38, "composite_fringing": 0.32,
	"phase_jitter": 0.008, "chroma_delay_px": 0.45, "ghost_strength": 0.025,
	"noise_luma": 0.004, "noise_chroma": 0.005, "rf_amount": 0.0,
	"sync_jitter_px": 0.0, "rf_tuning_error": 0.0, "burst_phase_noise": 0.0,
	"rf_snow": 0.0, "rf_gain_wobble": 0.0, "saturation": 1.0,
	"scanline_strength": 0.38, "mask_strength": 0.52, "brightness_compensation": 1.24,
	"horizontal_sharpness": 0.42, "convergence_x_px": 0.45, "convergence_y_px": 0.12,
	"halation_strength": 0.22, "halation_radius_px": 2.25, "halation_threshold": 0.58,
}

## An 8-bit console plugged into the antenna socket: heavy false colour, bleeding,
## sync instability, tuning error, snow and AGC wobble.
const FAMICOM_RF: Dictionary = {
	"signal_amount": 1.0, "composite_artifact": 1.15, "composite_fringing": 0.92,
	"phase_jitter": 0.055, "chroma_delay_px": 1.85, "ghost_strength": 0.13,
	"noise_luma": 0.018, "noise_chroma": 0.026, "rf_amount": 1.0,
	"sync_jitter_px": 0.85, "rf_tuning_error": 0.32, "burst_phase_noise": 0.16,
	"rf_snow": 0.055, "rf_gain_wobble": 0.075, "saturation": 1.15,
	"scanline_strength": 0.46, "mask_strength": 0.40, "brightness_compensation": 1.27,
	"horizontal_sharpness": 0.08, "convergence_x_px": 0.30, "convergence_y_px": 0.08,
	"halation_strength": 0.16, "halation_radius_px": 1.8, "halation_threshold": 0.62,
}

## An RGB/SCART connection: no composite artefacts at all, but still a CRT.
## Stage 1 is bypassed, so its 17-tap filter never runs.
const RGB_DIRECT: Dictionary = {
	"signal_amount": 0.0, "rgb_bypass_mix": 1.0, "rf_amount": 0.0,
	"scanline_strength": 0.34, "mask_strength": 0.42, "mask_softness": 0.25,
	"brightness_compensation": 1.18, "horizontal_sharpness": 0.30,
	"convergence_x_px": 0.15, "convergence_y_px": 0.0,
	"halation_strength": 0.10, "curve_amount": 0.020, "corner_radius": 0.030,
}

## For weak GPUs. Skips the Stage 1 filter and every extra texture sample,
## keeping only scanlines and the phosphor mask.
const LIGHTWEIGHT: Dictionary = {
	"signal_amount": 0.0, "rgb_bypass_mix": 0.0, "rf_amount": 0.0,
	"horizontal_sharpness": 0.0, "convergence_x_px": 0.0, "convergence_y_px": 0.0,
	"halation_strength": 0.0, "scanline_strength": 0.34, "mask_strength": 0.34,
	"mask_softness": 0.0, "brightness_compensation": 1.16, "display_amount": 1.0,
}

## Preset name to parameter dictionary. Names are stable; use them for save files.
const ALL: Dictionary = {
	"Composite TV": COMPOSITE_TV,
	"CRT Studio": CRT_STUDIO,
	"Famicom RF": FAMICOM_RF,
	"RGB Direct": RGB_DIRECT,
	"Lightweight": LIGHTWEIGHT,
}


## Returns the preset names in display order.
static func get_preset_names() -> PackedStringArray:
	var names := PackedStringArray()
	for key in ALL:
		names.append(key)
	return names


## Returns the parameter dictionary for [param preset_name], or an empty
## dictionary (the defaults) when the name is unknown.
static func get_preset(preset_name: String) -> Dictionary:
	return ALL.get(preset_name, {})


## Builds a fresh [CRTSettings] with [param preset_name] already applied.
static func create_settings(preset_name: String) -> CRTSettings:
	var settings := CRTSettings.new()
	settings.apply_preset(get_preset(preset_name))
	return settings
