@tool
class_name CRTSettings
extends Resource
## Every uniform of the two CRT shader stages, in one inspectable resource.
##
## The parameter table [constant PARAMS] is the single source of truth: the
## inspector rows, the demo sliders, the JSON round-trip and the preset system
## are all generated from it, so adding a uniform only means adding one row here
## (plus the uniform itself in the .gdshader file).
##
## 2つのCRTシェーダーの全uniformを1つのリソースにまとめたものです。
## パラメータ表 [constant PARAMS] が唯一の定義元で、インスペクタ表示・デモのUI・
## JSON入出力・プリセットはすべてこの表から生成されます。

## Which shader stage a parameter belongs to.
enum Stage {
	SIGNAL,  ## crt_signal.gdshader (Stage 1, NTSC/RF signal path)
	DISPLAY, ## crt_display.gdshader (Stage 2, CRT display simulation)
}

## Phosphor mask styles for [code]mask_type[/code].
enum MaskType {
	OFF,      ## No mask.
	SLOT,     ## Slot mask, typical of consumer CRT televisions.
	APERTURE, ## Aperture grille (Trinitron-style vertical stripes).
	SHADOW,   ## Shadow mask (delta triad).
}

## Parameter table. One row per shader uniform.
## Keys: name / stage / type ("float", "int", "bool", "enum") / min / max / step /
## default / group / label (English) / label_ja (Japanese) / items (enum only).
const PARAMS: Array[Dictionary] = [
	# ── Stage 1: NTSC composite signal ────────────────────────────────────────
	{"name": "signal_amount", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 1.0,
		"group": "Signal", "label": "Signal amount", "label_ja": "信号劣化 全体量"},
	{"name": "composite_artifact", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 2.0, "step": 0.001, "default": 0.85,
		"group": "Signal", "label": "Cross-color (false color)", "label_ja": "クロスカラー(偽色)"},
	{"name": "composite_fringing", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 2.0, "step": 0.001, "default": 0.65,
		"group": "Signal", "label": "Cross-luminance (fringing)", "label_ja": "クロスルミナンス(にじみ)"},
	{"name": "subcarrier_phase_px", "stage": Stage.SIGNAL, "type": "float", "min": 0.1, "max": 3.14, "step": 0.001, "default": 1.047,
		"group": "Signal", "label": "Subcarrier phase / px", "label_ja": "サブキャリア位相/px"},
	{"name": "line_phase_amount", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 6.283, "step": 0.001, "default": 2.094,
		"group": "Signal", "label": "Line phase step", "label_ja": "ライン位相差"},
	{"name": "phase_jitter", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 0.25, "step": 0.001, "default": 0.025,
		"group": "Signal", "label": "Phase jitter", "label_ja": "位相ジッター"},
	{"name": "chroma_delay_px", "stage": Stage.SIGNAL, "type": "float", "min": -8.0, "max": 8.0, "step": 0.001, "default": 1.25,
		"group": "Signal", "label": "Chroma delay (px)", "label_ja": "色ずれ[px]"},
	{"name": "y_band_px", "stage": Stage.SIGNAL, "type": "float", "min": 0.5, "max": 5.0, "step": 0.001, "default": 1.25,
		"group": "Signal", "label": "Y bandwidth (px)", "label_ja": "Y帯域(輝度ぼけ)"},
	{"name": "i_band_px", "stage": Stage.SIGNAL, "type": "float", "min": 1.0, "max": 9.0, "step": 0.001, "default": 2.75,
		"group": "Signal", "label": "I bandwidth (px)", "label_ja": "I帯域(色ぼけ1)"},
	{"name": "q_band_px", "stage": Stage.SIGNAL, "type": "float", "min": 1.0, "max": 12.0, "step": 0.001, "default": 4.25,
		"group": "Signal", "label": "Q bandwidth (px)", "label_ja": "Q帯域(色ぼけ2)"},
	{"name": "ghost_strength", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 0.5, "step": 0.001, "default": 0.08,
		"group": "Signal", "label": "Ghost strength", "label_ja": "ゴースト強度"},
	{"name": "ghost_offset_px", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 32.0, "step": 0.001, "default": 6.0,
		"group": "Signal", "label": "Ghost offset (px)", "label_ja": "ゴースト距離[px]"},
	{"name": "noise_luma", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 0.1, "step": 0.0005, "default": 0.012,
		"group": "Signal", "label": "Luma noise", "label_ja": "輝度ノイズ"},
	{"name": "noise_chroma", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 0.1, "step": 0.0005, "default": 0.018,
		"group": "Signal", "label": "Chroma noise", "label_ja": "色ノイズ"},
	{"name": "rgb_bypass_mix", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.0,
		"group": "Signal", "label": "RGB bypass mix", "label_ja": "RGBバイパス率"},
	# ── Stage 1: RF reception ─────────────────────────────────────────────────
	{"name": "rf_amount", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.20,
		"group": "RF", "label": "RF amount", "label_ja": "RF効果 全体量"},
	{"name": "sync_jitter_px", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 4.0, "step": 0.001, "default": 0.18,
		"group": "RF", "label": "H-sync jitter (px)", "label_ja": "水平同期揺れ[px]"},
	{"name": "rf_tuning_error", "stage": Stage.SIGNAL, "type": "float", "min": -1.0, "max": 1.0, "step": 0.001, "default": 0.08,
		"group": "RF", "label": "Tuning error", "label_ja": "RF離調"},
	{"name": "burst_phase_noise", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 0.5, "step": 0.001, "default": 0.03,
		"group": "RF", "label": "Color burst phase noise", "label_ja": "バースト位相揺れ"},
	{"name": "rf_snow", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 0.25, "step": 0.0005, "default": 0.015,
		"group": "RF", "label": "RF snow", "label_ja": "RFスノー"},
	{"name": "rf_gain_wobble", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 0.25, "step": 0.0005, "default": 0.015,
		"group": "RF", "label": "AGC wobble", "label_ja": "AGC揺れ"},
	{"name": "hue_deg", "stage": Stage.SIGNAL, "type": "float", "min": -45.0, "max": 45.0, "step": 0.1, "default": 0.0,
		"group": "RF", "label": "Hue (deg)", "label_ja": "色相補正[度]"},
	{"name": "saturation", "stage": Stage.SIGNAL, "type": "float", "min": 0.0, "max": 2.0, "step": 0.001, "default": 1.0,
		"group": "RF", "label": "Saturation", "label_ja": "彩度"},
	# ── Stage 2: CRT display ──────────────────────────────────────────────────
	{"name": "display_amount", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 1.0,
		"group": "Display", "label": "Display amount", "label_ja": "CRT表示 全体量"},
	{"name": "scanline_strength", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.42,
		"group": "Display", "label": "Scanline strength", "label_ja": "走査線強度"},
	{"name": "scanline_width_dark", "stage": Stage.DISPLAY, "type": "float", "min": 0.05, "max": 1.0, "step": 0.001, "default": 0.18,
		"group": "Display", "label": "Beam width (dark)", "label_ja": "ビーム幅(暗部)"},
	{"name": "scanline_width_bright", "stage": Stage.DISPLAY, "type": "float", "min": 0.05, "max": 1.0, "step": 0.001, "default": 0.42,
		"group": "Display", "label": "Beam width (bright)", "label_ja": "ビーム幅(明部)"},
	{"name": "mask_type", "stage": Stage.DISPLAY, "type": "enum", "default": MaskType.SLOT,
		"items": ["Off", "Slot", "Aperture grille", "Shadow mask"],
		"group": "Display", "label": "Mask type", "label_ja": "マスク方式"},
	{"name": "mask_strength", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.45,
		"group": "Display", "label": "Mask strength", "label_ja": "マスク強度"},
	{"name": "mask_pitch_px", "stage": Stage.DISPLAY, "type": "float", "min": 2.0, "max": 8.0, "step": 0.001, "default": 3.6,
		"group": "Display", "label": "Phosphor pitch (px)", "label_ja": "蛍光体ピッチ[px]"},
	{"name": "mask_dark", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.45,
		"group": "Display", "label": "Mask dark level", "label_ja": "マスク暗部"},
	{"name": "mask_softness", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 2.0, "step": 0.001, "default": 0.35,
		"group": "Display", "label": "Mask softness", "label_ja": "マスクぼかし"},
	{"name": "brightness_compensation", "stage": Stage.DISPLAY, "type": "float", "min": 0.5, "max": 2.0, "step": 0.001, "default": 1.22,
		"group": "Display", "label": "Brightness compensation", "label_ja": "明度補償"},
	{"name": "gamma_in", "stage": Stage.DISPLAY, "type": "float", "min": 1.0, "max": 3.0, "step": 0.001, "default": 2.4,
		"group": "Display", "label": "Gamma in", "label_ja": "入力ガンマ"},
	{"name": "gamma_out", "stage": Stage.DISPLAY, "type": "float", "min": 1.0, "max": 3.0, "step": 0.001, "default": 2.2,
		"group": "Display", "label": "Gamma out", "label_ja": "出力ガンマ"},
	{"name": "curve_amount", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 0.2, "step": 0.001, "default": 0.040,
		"group": "Display", "label": "Screen curvature", "label_ja": "画面カーブ"},
	{"name": "corner_radius", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 0.15, "step": 0.001, "default": 0.045,
		"group": "Display", "label": "Corner radius", "label_ja": "角丸半径"},
	{"name": "vignette_strength", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.18,
		"group": "Display", "label": "Vignette", "label_ja": "外周減光"},
	{"name": "bezel_strength", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.35,
		"group": "Display", "label": "Bezel darkening", "label_ja": "ベゼル暗部"},
	{"name": "interlace_enabled", "stage": Stage.DISPLAY, "type": "bool", "default": false,
		"group": "Display", "label": "480i interlace", "label_ja": "480i風表示"},
	{"name": "interlace_dim", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.72,
		"group": "Display", "label": "480i field dim", "label_ja": "480i減光"},
	{"name": "interlace_bob_px", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.5,
		"group": "Display", "label": "480i bob (px)", "label_ja": "480i上下揺れ[px]"},
	# ── Stage 2: CRT optics ───────────────────────────────────────────────────
	{"name": "horizontal_sharpness", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.5, "step": 0.001, "default": 0.15,
		"group": "Optics", "label": "Horizontal sharpness", "label_ja": "水平シャープネス"},
	{"name": "convergence_x_px", "stage": Stage.DISPLAY, "type": "float", "min": -4.0, "max": 4.0, "step": 0.001, "default": 0.25,
		"group": "Optics", "label": "Convergence X (px)", "label_ja": "RGB横ずれ[px]"},
	{"name": "convergence_y_px", "stage": Stage.DISPLAY, "type": "float", "min": -4.0, "max": 4.0, "step": 0.001, "default": 0.0,
		"group": "Optics", "label": "Convergence Y (px)", "label_ja": "RGB縦ずれ[px]"},
	{"name": "halation_strength", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.12,
		"group": "Optics", "label": "Halation strength", "label_ja": "ハレーション強度"},
	{"name": "halation_radius_px", "stage": Stage.DISPLAY, "type": "float", "min": 0.5, "max": 8.0, "step": 0.001, "default": 1.5,
		"group": "Optics", "label": "Halation radius (px)", "label_ja": "ハレーション半径[px]"},
	{"name": "halation_threshold", "stage": Stage.DISPLAY, "type": "float", "min": 0.0, "max": 1.0, "step": 0.001, "default": 0.65,
		"group": "Optics", "label": "Halation threshold", "label_ja": "ハレーション閾値"},
]

# Current value of every parameter, keyed by uniform name.
var _values: Dictionary = {}


func _init() -> void:
	for param in PARAMS:
		_values[param["name"]] = param["default"]


# ── Inspector integration ─────────────────────────────────────────────────────
# Properties are generated from PARAMS instead of being written out one by one,
# so the inspector, .tres storage and the table can never drift apart.

func _get_property_list() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var current_group: String = ""
	for param in PARAMS:
		var group: String = param["group"]
		if group != current_group:
			current_group = group
			list.append({
				"name": group,
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
				"hint_string": "",
			})
		list.append(_property_entry(param))
	return list


func _property_entry(param: Dictionary) -> Dictionary:
	var entry: Dictionary = {"name": param["name"], "usage": PROPERTY_USAGE_DEFAULT}
	match String(param["type"]):
		"bool":
			entry["type"] = TYPE_BOOL
		"enum":
			entry["type"] = TYPE_INT
			entry["hint"] = PROPERTY_HINT_ENUM
			var items: PackedStringArray = PackedStringArray()
			var index: int = 0
			for item in param["items"]:
				items.append("%s:%d" % [item, index])
				index += 1
			entry["hint_string"] = ",".join(items)
		"int":
			entry["type"] = TYPE_INT
			entry["hint"] = PROPERTY_HINT_RANGE
			entry["hint_string"] = "%d,%d,1" % [int(param["min"]), int(param["max"])]
		_:
			entry["type"] = TYPE_FLOAT
			entry["hint"] = PROPERTY_HINT_RANGE
			entry["hint_string"] = "%f,%f,%f" % [param["min"], param["max"], param["step"]]
	return entry


func _get(property: StringName):
	var key: String = String(property)
	if _values.has(key):
		return _values[key]
	return null


func _set(property: StringName, value) -> bool:
	var key: String = String(property)
	if not _values.has(key):
		return false
	_values[key] = value
	emit_changed()
	return true


func _property_can_revert(property: StringName) -> bool:
	return _values.has(String(property))


func _property_get_revert(property: StringName):
	return get_default(String(property))


# ── Value access ──────────────────────────────────────────────────────────────

## Returns the current value of [param param_name], or [code]null[/code] when
## the name is not a known parameter.
func get_value(param_name: String):
	return _values.get(param_name)


## Sets one parameter and emits [signal Resource.changed].
func set_value(param_name: String, value) -> void:
	if not _values.has(param_name):
		push_warning("CRTSettings: unknown parameter '%s'" % param_name)
		return
	_values[param_name] = value
	emit_changed()


## Returns the shipped default of [param param_name] (the composite TV look).
func get_default(param_name: String):
	for param in PARAMS:
		if param["name"] == param_name:
			return param["default"]
	return null


## Returns the [enum Stage] a parameter belongs to.
func get_stage(param_name: String) -> Stage:
	for param in PARAMS:
		if param["name"] == param_name:
			return param["stage"]
	return Stage.SIGNAL


## Returns the table row for [param param_name], or an empty dictionary.
static func describe(param_name: String) -> Dictionary:
	for param in PARAMS:
		if param["name"] == param_name:
			return param
	return {}


# ── Bulk operations ───────────────────────────────────────────────────────────

## Restores every parameter to its default and emits a single change.
func reset_to_defaults() -> void:
	for param in PARAMS:
		_values[param["name"]] = param["default"]
	emit_changed()


## Resets to defaults, then applies the name/value pairs of [param preset].
## Unknown keys are ignored, so presets can safely omit parameters.
func apply_preset(preset: Dictionary) -> void:
	for param in PARAMS:
		_values[param["name"]] = param["default"]
	for key in preset:
		if _values.has(key):
			_values[key] = preset[key]
		else:
			push_warning("CRTSettings: preset contains unknown parameter '%s'" % key)
	emit_changed()


## Returns all parameters as a plain dictionary, ready for [method JSON.stringify].
func to_dict() -> Dictionary:
	return _values.duplicate()


## Loads values from a dictionary produced by [method to_dict]. Missing keys keep
## their current value, which keeps older saved files loadable.
func from_dict(data: Dictionary) -> void:
	for param in PARAMS:
		var key: String = param["name"]
		if not data.has(key):
			continue
		match String(param["type"]):
			"bool":
				_values[key] = bool(data[key])
			"enum", "int":
				_values[key] = int(data[key])
			_:
				_values[key] = float(data[key])
	emit_changed()


## Serializes the settings as indented JSON.
func to_json() -> String:
	return JSON.stringify(to_dict(), "\t", true)


## Loads settings from JSON produced by [method to_json].
## Returns [code]true[/code] when the text parsed into an object.
func from_json(text: String) -> bool:
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	from_dict(parsed)
	return true


## Returns an independent copy holding the same values.
func copy() -> CRTSettings:
	var clone := CRTSettings.new()
	clone.from_dict(to_dict())
	return clone
