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
The first step is downloading [Godot 4.7](https://godotengine.org/download/archive/4.7.2-stable) if you don't have it already. Games made with other versions of Godot wil probably work, and if not, they can probably be ported. But 4.7 is what we're using.

The next step is cloning the repo, which is not as easy as it sounds. We're using [LFS](https://git-lfs.com/) and a [submodule](https://github.com/JCoMcL/jodot). LFS shouldn't give you much trouble, but make sure you run `git clone --recurse-submodules https://github.com/JCoMcL/phase-arcade` when cloning. Or, if you've already cloned the repo, you can run `git submodule update --init --recursive`. If you downloaded the zip, it will not have the submodule, but you can add it in manually by downloading [the zip of the submodule](https://github.com/JCoMcL/jodot/archive/refs/heads/master.zip) and extracting it into the `addons/jodot` folder.

## Setting up your game
Create a folder for your game in `Arcade Games`, then pick whichever template project suits you most, (either `_Game2D.tscn`, or `_Game3D.tscn`, `_GameUI.tscn`), and create a new inhereted scene from it, which will go in your new game folder.
![](Images/new_game.jpg)
The game root will have a script attached: [`game.gd`](Arcade Games/game.gd). If you right click on it click '*Open Documentation*' it will tell you more about it. There is a lot of existing code in this project, and we've done our best to document the parts that will need to, or might want to use.
You may want to click `*Extend Script*` on your root node to have your own root script without breaking compatibility. We recommend relying on the `Game` class where you can, as it will make it easier for us to fix the inevitable bugs and to ensure compatibility.

## Testing your game
You'll see file called [closet.tscn](closet.tscn) in the repo root. This is where you can run your game on one of the cabinets. Click on the Cabinet node and track your game's tscn into the cabinet's `Game Scene` slot in the inspector panel.
![Yo, if you're blind, that sucks, dude. I'm sorry to hear that](Images/add_game_to_cabinet.jpg)
After that, hit play. It should just work. There's a decent chance it will be cropped incorrectly, see [Setting up your cabinet](##Setting up your cabinet)

## Limitations and Guidelines
Before you start on your game, there are some things you should be aware of about how the arcade cabinet actually embeds your game. Some of these won't present as problems until way later, when your custom cabinet is being added to the Arcade, at which point it will be much harder to fix. The **important parts** will be in bold.
### Input
Redirecting inputs events is fairly easy in Godot. Any [`_input`](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-unhandled-input) or [`_unhandled_input`](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-private-method-unhandled-input) in your game will receive only the input events sent by the cabinet via the player. However, you should **never use the [`Input`](https://docs.godotengine.org/en/stable/classes/class_input.html) singleton** as that will query *all* input, even when your game is not being played. As a substitute, you can call `ArcadeCabinet.get_input_state(self)` from any node in your game, which will return the current state of the cabinet control surface.
### Video
Video redirection is achieved using [SubViewports](https://docs.godotengine.org/en/stable/tutorials/rendering/viewports.html). You may need to learn a little bit about how these work, if you run into any problems, but you'll probably be fine. What's more important to be aware of is **your game should run at around Standard Definition (~480p) or lower**. This will limit the amount of text you can fit on the screen. Note that this is mostly a stylistic decision, and we could make exceptions, but we really encourage you to try to lean into the limitations of the medium.
### Audio
Audio is redirected using [`AudioEffectCapture`](https://docs.godotengine.org/en/stable/classes/class_audioeffectcapture.html), which *should* Just Work™, but it hasn't been thouroughly tested and it has some known shortcomings: It adds an unavoidable 40ms of latency to the audio, and it can very easily choke and crackle in web builds. We may end up having to replace the `AudioEffectCapture` system with some more bone-headed that is more work, but has no such caveats. To make things easier on yourself, **try to avoid having too many AudioPlayer nodes, and try to avoid spawning new ones at runtime**. The cabinet doesn't (currently) have stereo sound, so there's no advantage to spatializing your audio, for now. You can use the `SFXPlayer` node that might have already come with your preset, it's very convenient, and it comes pre-loaded with a bunch of SFX.
 ---
 The work-in-progress line

## Setting up your cabinet
First, creat
![](Images/new_cabinet.jpg)

![](Images/properties.png)

![](Images/cabinet.png)
- Cabinet
- cabinet_model
- SubViewport
- CRTLayer:
- ScreenContainer
- ObservationPoint
- ControlPlane
## Creating your game
## Considerations

We're using Godot 4.7's new AreaLights to illuminate the cabinet from the screen. It's not physicially accurate because doing it physicially accurately would be unbelievably expensive, so you may have to dial in some setting to make the effect look good for your particular game.
