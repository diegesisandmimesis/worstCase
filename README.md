# worstCase

A TADS3/adv3 module providing a "worst case" gameworld for performance
testing.

## Description

By default at preinit the ``worstCase`` singleton will generate a
gameworld containing 400 rooms.  The map will consist of four
connected mazes, each containing 100 rooms.

A NPC will be generated for each room.

Each NPC will pick a random NPC other than themselves as their focus.
Each turn every NPC will attempt to move toward their chosen focus.

This is intended as a sort of worst case for performance testing.

## Table of Contents

[Getting Started](#getting-started)
* [Dependencies](#dependencies)
* [Installing](#install)
* [Compiling and Running Demos](#running)

[Basic Usage](#usage)

[Tweaking Map Generation](#tweak)

<a name="getting-started"/></a>
## Getting Started

<a name="dependencies"/></a>
### Dependencies

* TADS 3.1.3
* adv3 3.1.3

  These are the most recent versions of the TADS3 VM and adv3 library.

  Any TADS3 toolkit with these versions should work, although all of the
  [diegesisandmimesis](https://github.com/diegesisandmimesis) modules are
  primarily tested with [frobTADS](https://github.com/realnc/frobtads).

* git

  This module is distributed via github, so you'll need some way of
  cloning a git repo to obtain it.

  The process should be similar on any platform using any tools, but the
  command line examples given below were tested on an Ubuntu linux
  machine.  Other OSes and git tools will have a slightly different usage.

<a name="install"/></a>
### Installing

All of the [diegesisandmimesis](https://github.com/diegesisandmimesis) modules
are designed to be installed and used from a common base install directory.

In this example we'll use ``/home/username/tads`` as the base directory.

* Create the module base directory if it doesn't already exists:

  `mkdir -p /home/username/tads`

* Make it the current directory:

  ``cd /home/username/tads``

* Clone this repo:

  ``git clone https://github.com/diegesisandmimesis/worstCase.git``

After the ``git`` command, the module source will be in
``/home/username/tads/worstCase``.

<a name="running"/></a>
### Compiling and Running Demos

Once the repo has been cloned you should be able to ``cd`` into the
``./demo/`` subdirectory and compile the demonstration/test code that
comes with the module.

All the demos are structured in the expectation that they will be compiled
and run from the ``./demo/`` directory.  Again assuming that the module
is installed in ``/home/username/tads/worstCase/``, enter the directory with:
```
# cd /home/username/tads/worstCase/demo
```
Then make one of the demos, for example:
```
# make -a -f makefile.t3m
```
This should produce a bunch of output from the compiler but no errors.  When
it is done you can run the demo from the same directory with:
```
# frob games/game.t3
```
In general the name of the makefile and the name of the compiled story file
will be the same except for the extensions (``.t3m`` for makefiles and
``.t3`` for story files).

<a name="usage"/></a>
## Basic Usage

To enable the module, compile with the ``-D SIMPLE_RANDOM_MAP`` and
``-D WORST_CASE`` flags.

To move the player to a random room in the generated gameworld use:
```
worstCase.putInRandomRoom(actorInstance);
```
<a name="tweak"/></a>
## Tweaking Map Generation

The generated map consists of a square array of "zones" in which each
zone is a square random maze.  By default there are four zones in a
2x2 grid.  Each zone is a maze containing 100 rooms in a 10x10 square.

These defaults can be changed by setting ``worstCase.zoneWidth`` and
``WorstCaseMapGenerator.mapWidth``.

Example:
```
// Create a 1x1 grid, or a single zone.
modify worstCase zoneWidth = 1;

// Each zone will be a 3x3 maze, or 9 rooms.
modify WorstCaseMapGenerator mapWidth = 3;
```
