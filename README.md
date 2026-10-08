# Phase Arcade is Open
![](Images/cover.png)
We want *your* games to populate *Phase Arcade*; a mysterious abandoned entertainment venue set as a showcase of jammers' talents, and perhaps something more sinister...?

# When?
Now. [Unofficial Phase Jam 13](https://itch.io/jam/unofficial-phasejam-13) begins on October 9th and ends on October 19th. And We're hoping to finish up the Arcade for its grand opening by Halloween.

# What Type of Game?
The two most important things are that it's an Arcade game, and it's a Phase game.
If there were a third thing, it would be that your game is at least a little bit haunted.

An arcade game is about exchanging quarters for lives, earning points, and getting a high score. An arcade game is also usually *retro*. Having a look at some popular arcade games is a great place to start for inspiration and guidance. Though make sure to coordinate with the other jammers if you do this so we don't up having to make space for six different Phase Pong cabinets.

See also the [Limitations and Guidelines](##Limitations and Guidelines) section for details. Some of those *may* be a dealbreaker. We've done what we can to allow just about any [Godot](https://godotengine.org/) game to run in the arcade, but there are still some unavoidable restrictions.

While the jam is a great opportunity to make a game for the arcade, it's not just Jam games you can submit. Any game you've made, if it's a good fit, and if it can be ported to the arcade, could be added.
Also note, if you wanted to, you could make some other kind of arcade attraction; pinball, or a claw-machine, or something of that sort. We'd be delighted, but you'll have to work with us a little more closely to ensure that your submission will work in the arcade.

# How?
The first step is downloading [Godot 4.7](https://godotengine.org/download/archive/4.7.2-stable) if you don't have it already. Games made with other versions of Godot will probably work, and if not, they can probably be ported. But 4.7 is what we're using.

The next step is cloning the repo, which is not as easy as it sounds. We're using [LFS](https://git-lfs.com/) and a [submodule](https://github.com/JCoMcL/jodot). LFS shouldn't give you much trouble, but make sure you run `git clone --recurse-submodules https://github.com/JCoMcL/phase-arcade` when cloning. Or, if you've already cloned the repo, you can run `git submodule update --init --recursive`. If you downloaded the zip, it will not have the submodule, but you can add it in manually by downloading [the zip of the submodule](https://github.com/JCoMcL/jodot/archive/refs/heads/master.zip) and extracting it into the `addons/jodot` folder.

## Setting up your game
Create a folder for your game in `Arcade Games`, then pick whichever template project suits you most, (either `_Game2D.tscn`, or `_Game3D.tscn`, `_GameUI.tscn`), and create a new inhereted scene from it, which will go in your new game folder.
![](Images/new_game.jpg)
The game root will have a script attached: [`game.gd`](Arcade Games/game.gd). If you right click on it click '*Open Documentation*' it will tell you more about it. There is a lot of existing code in this project, and we've done our best to document the parts that will need to, or might want to use. Be sure to read the documentation, and let us know if there are any issues with it. This guide is specifically for the high-level details that aren't covered in the docs, so it won't suffice on its own.
You may want to click `*Extend Script*` on your root node to have your own root script without breaking compatibility. We recommend relying on the `Game` class where you can, as it will make it easier for us to fix the inevitable bugs and to ensure compatibility.

## Testing your game
You'll see file called [closet.tscn](closet.tscn) in the repo root. This is where you can run your game on one of the cabinets. Click on the Cabinet node and track your game's tscn into the cabinet's `Game Scene` slot in the inspector panel.
![Yo, if you're blind, that sucks, dude. I'm sorry to hear that](Images/add_game_to_cabinet.jpg)
After that, hit play. It should just work. There's a decent chance it will be cropped incorrectly, see [Setting up your cabinet](##Setting up your cabinet)

## Limitations and Guidelines
Before you start on your game, there are some things you should be aware of about how the arcade cabinet actually embeds your game. Some of these won't present as problems until way later, when your custom cabinet is being added to the Arcade, at which point it will be much harder to fix. The **important parts** will be in bold.
### Input
Redirecting inputs events is fairly easy in Godot. Any [`_input`](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-unhandled-input) or [`_unhandled_input`](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-unhandled-input) in your game will receive only the input events sent by the cabinet via the player. However, you should **never use the [`Input`](https://docs.godotengine.org/en/stable/classes/class_input.html) singleton** as that will query *all* input, even when your game is not being played. As a substitute, you can call `ArcadeCabinet.get_input_state(self)` from any node in your game, which will return the current state of the cabinet control surface.
If you have custom UI in your game, make sure that it controls using `ui_` events (`ui_up`, `ui_down`, etc) instead of movement events (`up`, `down` `left`, `right`). Movement 
### Video
Video redirection is achieved using [SubViewports](https://docs.godotengine.org/en/stable/tutorials/rendering/viewports.html). You may need to learn a little bit about how these work if you run into any problems, but you'll probably be fine. What's more important to be aware of is **your game should run at around Standard Definition (~480p) or lower**. This will limit the amount of text you can fit on the screen. Note that this is mostly a stylistic decision, and we could make exceptions, but we really encourage you to try to lean into the limitations of the medium.
### Audio
Audio is redirected using [`AudioEffectCapture`](https://docs.godotengine.org/en/stable/classes/class_audioeffectcapture.html), which *should* Just Work™, but it hasn't been thoroughly tested and it has some known shortcomings: It adds an unavoidable 40ms of latency to the audio, and it can very easily choke and crackle in web builds. We may end up having to replace the `AudioEffectCapture` system with some more bone-headed that is more work, but has no such caveats. To make things easier on yourself, **try to avoid having too many AudioPlayer nodes, and try to avoid spawning new ones at runtime**. The cabinet doesn't (currently) have stereo sound, so there's no advantage to spatializing your audio, for now. You can use the `SFXPlayer` node that might have already come with your preset, it's very convenient, and it comes pre-loaded with a bunch of SFX.
### Getting along with your neighbours
This is a shared Godot project, it's been set up in a somewhat opinionated way. Many of the layers already have names, and many of the good class names have already been taken. If you're used to a very specific kind of workflow that relies on your `project.godot` being set up in a very specific way, you may struggle here. For best results, prefix your class names with the name of your game, and use your game root script for any utility functions. You may be surprised to learn how much of the usecase for `Autoload` can be replaced with `static` functions. Alternatively, if you're used to cowboy-coding, and your gdscript has a lot of `get_parent().get_parent().get_parent().get_child(4)`, you should have absolutely no trouble with this new workflow.

## Setting up your cabinet
Your game is gonna need its own, dedicated cabinet with its own model, and texture, and branding. We're still figuring that part out, but in the meantime this section still applies to the placeholder cabinet in the test closet. You'll want to experiment with the settings; how your game is set up *will impact* the game.
Many aspects of the cabinet will already be documented, you can hover over something to see what it does.
![](Images/tooltip.jpg)
If you find something which isn't documented and should be, let us know.
### Anatomy of the cabinet
![](Images/cabinet.png)
Here are the aspects of the cabinet you'll likely want to modify in descening order of importance
#### Screen Size
the `SubViewport` `size` property controls screen size and synchronizes it with the other components automatically. At higher resolutions like 640x480, you may want to increase `crt downscale` to reduce aretfects, we're working on an automatic fix for this problem. You may still want to increase for it asethetic purposes.
Note: The 3D and UI game should adapt automatically to the new screen size, but **the 2D preset will require manually managing the game size**. In general for 2D games, screen size will have a lot of gameplay consequences so it's worth nailing down early. In general we recommend going with the smallest size you feel like you can get away with.
#### CRT Filter
The `Screen` has a CRT filter on it, we've chosen reasonable defaults but you're welcome to experiment. Many of the settings alter the color and contrast, so be sure to check that your game looks as good on the screen as it does in your editor.
#### Screen Illumination
We're using Godot 4.7's new AreaLights to illuminate the cabinet from the screen. It's not physically accurate because doing it physically accurately would be unbelievably expensive, so you may have to dial in some setting to make the effect look good for your particular game. First, you can set the Energy on the `ScreenLight`, if your game has a lot of darkness it may need to be increased. `Downsample` is the SubViewport which creates the texture for the light's color. Increasing the size can help smooth out flickering caused by a low sample size, but also exponentially costs performance. Increasing the cabinet's `light_update_interval` will also reduce flickering by smoothing the transition over time, but this will make it less responsive.

Increasing `light_update_interval` can also improve performance, however, if recalculating the lighting every frame causes lag, then recalculating it every n frames will still cause lag every n frames, so it's not a real solution. We may implement a smarter sampling method that lets you get away with a smaller sample texture in the future.
#### Controls
`ControlPlane` manages the controls. Set visibility off on the ones you aren't using. Also, feel free to move them and scale them you your liking. For best results, use the transform property editor instead if the gizmo. The gizmo doesn't operate in local space.
![](Images/transform-property.png)
If you want more control, let us know.

### Customizing your cabinet
We're still working on this, but if you're comfortable with 3D modelling or texturing you can have a stab at it yourself. The blender file is in the repo.
