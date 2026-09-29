@tool
@icon("crt_screen.svg")
class_name CRTScreen
extends Control
## A drop-in CRT television screen: feeds a picture through the NTSC signal
## shader and the CRT display shader, and draws the result inside this Control.
##
## The node owns the whole three-step pipeline:
## [codeblock]
## content (source_texture, or nodes under get_content_root())
##   -> low-res canvas SubViewport      (signal_resolution, letterboxed on black)
##   -> Stage 1 SubViewport             (crt_signal.gdshader)
##   -> display ColorRect               (crt_display.gdshader) -> this Control
## [/codeblock]
##
## Two independent 90-degree rotations are available, which together cover every
## vertical (tate) arrangement:
## [member screen_rotation] turns the whole CRT plane, scanlines and phosphor
## mask included, exactly like physically rotating an arcade monitor.
## [member content_rotation] turns the picture inside the canvas instead, so the
## tube stays upright and the scanlines stay horizontal.

## Quarter-turn steps, clockwise.
enum Rotation {
	DEG_0,   ## No rotation.
	DEG_90,  ## Quarter turn clockwise.
	DEG_180, ## Half turn.
	DEG_270, ## Quarter turn counter-clockwise.
}

## How the CRT plane is fitted into this Control.
enum DisplayFit {
	KEEP_ASPECT, ## Fit the tube's aspect ratio inside the Control, centered.
	STRETCH,     ## Cover the whole Control, whatever its shape.
}

## How [member source_texture] is laid out on the low-resolution canvas.
enum SourceStretch {
	NONE,    ## 1:1 pixels, centered.
	FIT,     ## Scaled to fit, aspect ratio preserved.
	FILL,    ## Stretched to the whole canvas, aspect ratio ignored.
	INTEGER, ## Largest whole-number scale that still fits (never below 1:1).
}

# Relative so the addon keeps working if the folder is moved or renamed.
const SIGNAL_SHADER: Shader = preload("crt_signal.gdshader")
const DISPLAY_SHADER: Shader = preload("crt_display.gdshader")

## Emitted when the drawing area returned by [method get_content_size] changes,
## which happens when [member signal_resolution] or [member content_rotation] is
## set. Resize your content to match.
signal content_size_changed(content_size: Vector2i)

## Shader parameters. Leave empty to use the shipped composite TV defaults;
## assign a [CRTSettings] resource to tune the look in the inspector or at
## runtime. Changes to the resource are applied automatically.
@export var settings: CRTSettings:
	set = set_settings

## Resolution of the simulated video signal, in pixels. 320x240 is a 4:3
## 240p-class picture; the cost of Stage 1 scales with this, not with the
## size of the Control.
@export var signal_resolution: Vector2i = Vector2i(320, 240):
	set = set_signal_resolution

## Picture to display. Any [Texture2D] works, including the
## [ViewportTexture] of a [SubViewport] that renders your game.
@export var source_texture: Texture2D:
	set = set_source_texture

## How [member source_texture] is fitted onto the canvas.
@export var source_stretch: SourceStretch = SourceStretch.FIT:
	set = set_source_stretch

## Quarter-turn rotation of the picture inside the canvas, covering both
## [member source_texture] and the nodes under [method get_content_root]. The
## tube itself stays upright, so scanlines remain horizontal on the display.
## A quarter turn transposes the drawing area: with a 320x240 signal the content
## is authored 240x320 and lands rotated on the canvas.
@export var content_rotation: Rotation = Rotation.DEG_0:
	set = set_content_rotation

## Quarter-turn rotation of the whole CRT plane, as if the television or arcade
## monitor were physically turned. Scanlines and the phosphor mask rotate with
## it, which is what vertical (tate) games need. With [constant Rotation.DEG_90]
## or [constant Rotation.DEG_270] the plane is transposed, so a portrait-shaped
## Control is filled by a landscape CRT lying on its side.
@export var screen_rotation: Rotation = Rotation.DEG_0:
	set = set_screen_rotation

## Whether the CRT plane keeps the tube's shape or covers the whole Control.
@export var display_fit: DisplayFit = DisplayFit.KEEP_ASPECT:
	set = set_display_fit

## Shape of the tube, as width / height. 0 derives it from
## [member signal_resolution], which is right for square pixels; set it
## explicitly for non-square ones, for example 4.0 / 3.0 for a 256x224 picture
## on a 4:3 television. Ignored when [member display_fit] is
## [constant DisplayFit.STRETCH].
@export_range(0.0, 4.0, 0.0001) var screen_aspect: float = 0.0:
	set = set_screen_aspect

## Colour of the canvas area not covered by the picture. Black reads as the
## no-signal border of a real television.
@export var background_color: Color = Color.BLACK:
	set = set_background_color

## Colour painted around the tube when it does not fill the whole Control.
## Use an alpha of 0 to let whatever is behind this node show through.
@export var letterbox_color: Color = Color.BLACK:
	set = set_letterbox_color

## When on, the frame counter advances, which drives dot crawl, noise, sync
## jitter and the 480i field flip. Turn it off to freeze the picture.
@export var animate: bool = true

## How many shader frames pass per real second. 60 matches the NTSC field rate.
@export_range(1.0, 240.0, 0.5) var frames_per_second: float = 60.0

# ── Internal pipeline nodes ───────────────────────────────────────────────────
var _canvas_viewport: SubViewport = null
var _canvas_background: ColorRect = null
var _content_root: Control = null
var _source_view: TextureRect = null
var _signal_viewport: SubViewport = null
var _signal_rect: ColorRect = null
var _signal_material: ShaderMaterial = null
var _display_rect: ColorRect = null
var _display_material: ShaderMaterial = null
var _frame_count: float = 0.0
var _built: bool = false
# Used when no CRTSettings resource is assigned, so the node still has values.
var _fallback_settings: CRTSettings = null


func _ready() -> void:
	_build_pipeline()
	resized.connect(_update_display_layout)
	_apply_all()
	set_process(true)


func _process(delta: float) -> void:
	if not _built:
		return
	if animate:
		_frame_count += delta * frames_per_second
		if _frame_count > 100000.0:
			_frame_count = 0.0
	var frame: float = floor(_frame_count)
	_signal_material.set_shader_parameter("frame_count", frame)
	_display_material.set_shader_parameter("frame_count", frame)


# ═══ Pipeline construction ════════════════════════════════════════════════════

func _build_pipeline() -> void:
	if _built:
		return
	var canvas_size := _canvas_size()

	# Canvas: the low-resolution picture, centred on the background colour.
	_canvas_viewport = SubViewport.new()
	_canvas_viewport.name = "CRTCanvas"
	_canvas_viewport.disable_3d = true
	_canvas_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_canvas_viewport.size = canvas_size
	add_child(_canvas_viewport, false, Node.INTERNAL_MODE_FRONT)

	_canvas_background = ColorRect.new()
	_canvas_background.name = "Background"
	_canvas_background.color = background_color
	_canvas_background.position = Vector2.ZERO
	_canvas_background.size = Vector2(canvas_size)
	_canvas_viewport.add_child(_canvas_background)

	# Everything that is "the picture" hangs off this node, so one rotation on it
	# turns the source texture and any content nodes together.
	_content_root = Control.new()
	_content_root.name = "Content"
	_content_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas_viewport.add_child(_content_root)

	_source_view = TextureRect.new()
	_source_view.name = "Source"
	_source_view.stretch_mode = TextureRect.STRETCH_SCALE
	_source_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_content_root.add_child(_source_view)

	# Stage 1: NTSC/RF signal degradation, rendered at the signal resolution.
	_signal_viewport = SubViewport.new()
	_signal_viewport.name = "CRTSignal"
	_signal_viewport.disable_3d = true
	_signal_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_signal_viewport.size = canvas_size
	add_child(_signal_viewport, false, Node.INTERNAL_MODE_FRONT)

	_signal_material = ShaderMaterial.new()
	_signal_material.shader = SIGNAL_SHADER
	_signal_rect = ColorRect.new()
	_signal_rect.name = "SignalPass"
	_signal_rect.position = Vector2.ZERO
	_signal_rect.size = Vector2(canvas_size)
	_signal_rect.material = _signal_material
	_signal_viewport.add_child(_signal_rect)
	_signal_material.set_shader_parameter("source_texture", _canvas_viewport.get_texture())
	_signal_material.set_shader_parameter("source_size", Vector2(canvas_size))

	# Stage 2: CRT display simulation, rendered at the size of this Control.
	_display_material = ShaderMaterial.new()
	_display_material.shader = DISPLAY_SHADER
	_display_rect = ColorRect.new()
	_display_rect.name = "DisplayPass"
	_display_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_display_rect.material = _display_material
	add_child(_display_rect, false, Node.INTERNAL_MODE_FRONT)
	_display_material.set_shader_parameter("source_texture", _signal_viewport.get_texture())
	_display_material.set_shader_parameter("source_size", Vector2(canvas_size))

	_built = true
	_update_content_layout()
	_update_display_layout()


func _canvas_size() -> Vector2i:
	return Vector2i(maxi(signal_resolution.x, 1), maxi(signal_resolution.y, 1))


# Places the display plane inside the Control, applying the quarter-turn.
#
# A quarter turn transposes the plane: the ColorRect keeps rendering in its own
# upright pixel space (so scanlines and the mask are computed exactly as before)
# and the whole rect is then rotated, which is what a physically rotated monitor
# does. With KEEP_ASPECT the on-screen footprint is fitted to the tube's shape,
# so a rotated landscape tube shows up as a portrait picture with side bars.
func _update_display_layout() -> void:
	if not _built:
		return
	var control_size := Vector2(maxf(size.x, 1.0), maxf(size.y, 1.0))
	var quarter: int = int(screen_rotation)
	var turned: bool = quarter == Rotation.DEG_90 or quarter == Rotation.DEG_270
	var plane_size := control_size
	if turned:
		plane_size = Vector2(control_size.y, control_size.x)
	if display_fit == DisplayFit.KEEP_ASPECT:
		var canvas := Vector2(_canvas_size())
		var tube_aspect: float = screen_aspect if screen_aspect > 0.0 else canvas.x / canvas.y
		# Aspect of the area the tube covers on screen, after the rotation.
		var footprint_aspect: float = (1.0 / tube_aspect) if turned else tube_aspect
		var footprint := Vector2(control_size.x, control_size.x / footprint_aspect)
		if footprint.y > control_size.y:
			footprint = Vector2(control_size.y * footprint_aspect, control_size.y)
		plane_size = Vector2(footprint.y, footprint.x) if turned else footprint
	_display_rect.size = plane_size
	_display_rect.pivot_offset = plane_size * 0.5
	_display_rect.position = (control_size - plane_size) * 0.5
	_display_rect.rotation = deg_to_rad(90.0 * float(quarter))
	# The mask and the scanlines are measured in the plane's own pixels, which is
	# exactly how a rotated monitor behaves.
	_display_material.set_shader_parameter("output_size", plane_size)
	queue_redraw()


func _draw() -> void:
	# Painted behind the tube; internal children are drawn after this.
	if letterbox_color.a > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), letterbox_color)


# Rotates the whole picture inside the canvas. A quarter turn transposes the
# drawing area, so content authored 240x320 lands rotated on a 320x240 canvas.
func _update_content_layout() -> void:
	if not _built:
		return
	var canvas := Vector2(_canvas_size())
	var quarter: int = int(content_rotation)
	var logical := Vector2(get_content_size())
	_content_root.size = logical
	_content_root.pivot_offset = logical * 0.5
	_content_root.rotation = deg_to_rad(90.0 * float(quarter))
	_content_root.position = (canvas - logical) * 0.5
	_update_source_layout()
	content_size_changed.emit(get_content_size())


# Places the source picture inside the (possibly transposed) drawing area.
func _update_source_layout() -> void:
	if not _built:
		return
	_source_view.texture = source_texture
	_source_view.visible = source_texture != null
	if source_texture == null:
		return

	var area := Vector2(get_content_size())
	var content := Vector2(source_texture.get_size())
	content.x = maxf(content.x, 1.0)
	content.y = maxf(content.y, 1.0)

	var view_size := content
	match source_stretch:
		SourceStretch.NONE:
			view_size = content
		SourceStretch.FILL:
			view_size = area
		SourceStretch.INTEGER:
			var whole := floorf(minf(area.x / content.x, area.y / content.y))
			view_size = content * maxf(whole, 1.0)
		_:
			view_size = content * minf(area.x / content.x, area.y / content.y)

	_source_view.size = view_size
	_source_view.position = (area - view_size) * 0.5
	# Whole-number scaling stays crisp; everything else is filtered.
	_source_view.texture_filter = (
		CanvasItem.TEXTURE_FILTER_NEAREST
		if source_stretch == SourceStretch.INTEGER or source_stretch == SourceStretch.NONE
		else CanvasItem.TEXTURE_FILTER_LINEAR)


# ═══ Settings ═════════════════════════════════════════════════════════════════

## Returns the settings in use: the assigned resource, or the internal defaults
## when [member settings] is empty.
func get_effective_settings() -> CRTSettings:
	if settings != null:
		return settings
	if _fallback_settings == null:
		_fallback_settings = CRTSettings.new()
	return _fallback_settings


## Pushes every parameter to both shaders. Called automatically whenever the
## settings resource changes; call it manually after editing values in bulk.
func apply_settings() -> void:
	if not _built:
		return
	var current := get_effective_settings()
	for param in CRTSettings.PARAMS:
		var param_name: String = param["name"]
		var value = current.get_value(param_name)
		if param["stage"] == CRTSettings.Stage.SIGNAL:
			_signal_material.set_shader_parameter(param_name, value)
		else:
			_display_material.set_shader_parameter(param_name, value)


## Sets a single parameter on the settings resource and on the matching shader.
func set_param(param_name: String, value) -> void:
	var current := get_effective_settings()
	current.set_value(param_name, value)
	if settings == null:
		# The fallback resource has no change signal hooked up, so push directly.
		_push_param(param_name, value)


## Returns the current value of a single parameter.
func get_param(param_name: String):
	return get_effective_settings().get_value(param_name)


## Applies a preset dictionary from [CRTPresets], replacing all parameters.
func apply_preset(preset: Dictionary) -> void:
	get_effective_settings().apply_preset(preset)
	if settings == null:
		apply_settings()


## Restores the shipped composite TV defaults.
func reset_settings() -> void:
	get_effective_settings().reset_to_defaults()
	if settings == null:
		apply_settings()


func _push_param(param_name: String, value) -> void:
	if not _built:
		return
	if get_effective_settings().get_stage(param_name) == CRTSettings.Stage.SIGNAL:
		_signal_material.set_shader_parameter(param_name, value)
	else:
		_display_material.set_shader_parameter(param_name, value)


func _apply_all() -> void:
	_update_content_layout()
	_update_display_layout()
	apply_settings()


# ═══ Content ══════════════════════════════════════════════════════════════════

## Size of the drawing area, in signal pixels. Equal to
## [member signal_resolution], transposed when [member content_rotation] is a
## quarter turn. Lay your content out to this size.
func get_content_size() -> Vector2i:
	var canvas := _canvas_size()
	if content_rotation == Rotation.DEG_90 or content_rotation == Rotation.DEG_270:
		return Vector2i(canvas.y, canvas.x)
	return canvas


## The node your content belongs under. Add a whole scene to it to run your game
## through the CRT instead of a texture:
## [codeblock]
## crt_screen.get_content_root().add_child(my_game_scene)
## [/codeblock]
## Content lives at [method get_content_size] scale and follows
## [member content_rotation]. It is not stored in the scene file, so add it from
## code; to keep content in a saved scene instead, render it in your own
## [SubViewport] and assign that viewport's texture to [member source_texture].
func get_content_root() -> Control:
	if not _built:
		_build_pipeline()
	return _content_root


## The low-resolution [SubViewport] the picture is composed in. Nodes added here
## directly bypass [member content_rotation]; prefer [method get_content_root].
func get_content_viewport() -> SubViewport:
	if not _built:
		_build_pipeline()
	return _canvas_viewport


## Convenience wrapper around [method get_content_root]: reparents [param node]
## into the drawing area.
func set_content_node(node: Node) -> void:
	var root := get_content_root()
	if node.get_parent() == root:
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	root.add_child(node)


## The rendered Stage 1 output, if you need it for a secondary effect.
func get_signal_texture() -> ViewportTexture:
	if not _built:
		_build_pipeline()
	return _signal_viewport.get_texture()


# ═══ Property setters ═════════════════════════════════════════════════════════

func set_settings(value: CRTSettings) -> void:
	if settings != null and settings.changed.is_connected(apply_settings):
		settings.changed.disconnect(apply_settings)
	settings = value
	if settings != null and not settings.changed.is_connected(apply_settings):
		settings.changed.connect(apply_settings)
	apply_settings()


func set_signal_resolution(value: Vector2i) -> void:
	signal_resolution = Vector2i(maxi(value.x, 1), maxi(value.y, 1))
	if not _built:
		return
	var canvas_size := _canvas_size()
	_canvas_viewport.size = canvas_size
	_signal_viewport.size = canvas_size
	_canvas_background.size = Vector2(canvas_size)
	_signal_rect.size = Vector2(canvas_size)
	_signal_material.set_shader_parameter("source_size", Vector2(canvas_size))
	_display_material.set_shader_parameter("source_size", Vector2(canvas_size))
	_update_content_layout()
	_update_display_layout()


func set_source_texture(value: Texture2D) -> void:
	source_texture = value
	_update_source_layout()


func set_source_stretch(value: SourceStretch) -> void:
	source_stretch = value
	_update_source_layout()


func set_content_rotation(value: Rotation) -> void:
	content_rotation = value
	_update_content_layout()


func set_screen_rotation(value: Rotation) -> void:
	screen_rotation = value
	_update_display_layout()


func set_display_fit(value: DisplayFit) -> void:
	display_fit = value
	_update_display_layout()


func set_screen_aspect(value: float) -> void:
	screen_aspect = maxf(value, 0.0)
	_update_display_layout()


func set_background_color(value: Color) -> void:
	background_color = value
	if _built:
		_canvas_background.color = value


func set_letterbox_color(value: Color) -> void:
	letterbox_color = value
	queue_redraw()


## Turns the CRT plane one step clockwise (0 -> 90 -> 180 -> 270 -> 0).
func rotate_screen_clockwise() -> void:
	set_screen_rotation(posmod(int(screen_rotation) + 1, 4))


## Turns the CRT plane one step counter-clockwise.
func rotate_screen_counter_clockwise() -> void:
	set_screen_rotation(posmod(int(screen_rotation) - 1, 4))
