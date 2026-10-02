# ~~Phase 1: Demo to JK (Sep 27)~~
- [x] visibly working arcade machine
- [x] first person exploration
- [x] interesting level
- [x] interactive coins

# ~~Phase 2: Core Functionality (Oct 01)~~
## Arcade Cabinet
- [x] video
- [-] audio
- [x] input
## Player Character
- [x] basic first person controls
- [x] crouching
- [x] interaction
- [-] cabinet lock-on
- [x] tooltips
- [x] inventory
## Level
- [-] collisions on walls and floor
- [x] hidden coins
- [x] switchable lights

# Phase 3: Open For Submissions (Oct 10)
- [ ] documentation
- [ ] an easy way to test the game during development
- [ ] get started on our respective games do know what's needed
- [ ] different places to put games, how accessible?
## Arcade Cabinet
- [ ] screen works for various sizes
- [ ] different control schemes
- [ ] lock-on bugs fixed
- [ ] different cabinet styles with similar UVs
- [ ] insert coins
## API
- [ ] port over FX code, add user-added FX library support
- [ ] port over utils, split into own files, add 3D support of neccesary
- [ ] port unit.gd and shoota.gd and such
- [ ] add documentation comments to everything
- [ ] abstract out useful building blocks such as *lives*
- [ ] add demo recording and demo screen
## Highscore
- [ ] preset highscore screen
- [ ] scorekeeping library
- [ ] online highscores
## Arcade Games
- [ ] verify Invaders still works
- [ ] prototype Sakura Shooter mechanics
## Level
- [ ] proper rigidbody interaction

# Phase 4: Game Jam (Oct 20)
- [ ] help jammers with music
- [ ] help jammers with custom arcade cabinets
- [ ] fix inevitable bugs
- [ ] provide feedback to jammers
## Night of the Invaders
## Sakura Shootout

# Phase 5: Release (Oct 30)
- [ ] impassable areas (perhaps a "too dark" wall)
- [ ] adventure game mechanics
- [ ] fix bugs in the jam games
- [ ] add scares
- [ ] finalize the layout
- [ ] make coins and collectables extra juicy
- [ ] promote
- [ ] hope

# Misc.
## Mood and Story
- [ ] breaking and entering
- [ ] contrast between finished and unfinished areas
- [ ] evidence of the passage of time since construction
- [ ] bringing the arcade back online
- [ ] "puzzles" to unlock new areas
- [ ] something not quite right about this place
## Progression
- [ ] coins hidden deeper in the arcade
- [ ] circuit breakers bring new areas online
- [ ] machines print prize tickets
- [ ] vending machine or claw machine to give out prizes
- [ ] glowing pippa
## Visual
- [ ] transluscent drapecloths
- [ ] player character casts a shadow
- [ ] rigid bodies
- [ ] cabinets illuminate themselves
- [ ] flickering lights
## Gamefeel
- [ ] gradual angle-based transition from cabinet lock-on
## Props
- [ ] wrecked cabinets
- [ ] various light sources which could operate without mains power
- [ ] things that produce environmental audio
- [x] working doors
- [ ] doors that work and aren't weird or clunky
## Scares
- [ ] things that go bump in the night
- [ ] power outages
- [ ] singing fish
- [ ] signs of a struggle
- [ ] rats
- [ ] dizzy phasebear
## Audio
- [-] coins
- [ ] footsteps
- [ ] ambiance
- [ ] arcade machinery
- [ ] good reverb settings
## Convenience
- [ ] aggregate reference material in the repo
### Import script
- [ ] pull assets from a multi-asset export
- [ ] set up collisions
- [ ] bounding box
- [ ] rigidbodies

`[x]`: done, `[-]`: WIP, better than nothing

# See Also:
[` assert (height >= width) #TODO  assert does nothing in tool mode, need a better we to handle this`](./player/first_person_player.gd)
