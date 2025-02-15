#charset "us-ascii"
//
// worstCase.t
//
//	A TADS3/adv3 module providing a "worst case" gameworld.
//
//	At preinit the worstCase singleton generates (by default)
//	a 400-room gameworld consisting of four connected 100-room
//	random mazes.  An NPC is generated for each room.
//
//	Each NPC randomly picks an NPC other than themselves and on
//	each turn attempts to move toward them.
//
//	This is intended as a sort of worst case for performance testing.
//
//
// BASIC USAGE
//
//	To enable the module, compile with -D SIMPLE_RANDOM_MAP and
//	-D WORST_CASE.
//
//	To move the player to a random room in the generated gameworld
//	use:
//
//		worstCase.putInRandomRoom(actorInstance);
//
//	...where actorInstance is the player object.  For example, you
//	can add:
//
//		newGame() {
//			worstCase.putInRandomRoom(initialPlayerChar);
//			inherited();
//		}
//
//	...to gameMain.
//
//
// TWEAKING MAP GENERATION
//
//	The generated map consists of a square array of "zones" in
//	which each zone is a square random maze.  By default there
//	are four zones (a 2x2 grid) and each zone is a maze containing
//	100 rooms (a 10x10 square).
//
//	Change worstCase.zoneWidth to change the number of zones.
//
//	Change WorstCaseMapGenerator.mapWidth to change the number
//	of rooms per zone.
//
//	Example:
//
//		// Create a 1x1 grid, or a single zone.
//		modify worstCase zoneWidth = 1;
//
//		// Each zone will be a 3x3 maze, or 9 rooms.
//		modify WorstCaseMapGenerator mapWidth = 3;
//
//
#include <adv3.h>
#include <en_us.h>

#include "worstCase.h"

#ifdef WORST_CASE

// Module ID for the library
worstCaseModuleID: ModuleID {
        name = 'Worst Case Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

worstCase: PreinitObject
	// To hold all our randomly milling-about actors.
	worstCaseActors = perInstance(new Vector())

	// Boolean.  If true, the connections between zones are lockable
	// doors.
	useDoors = nil

	// When we add an actor to our list above we keep track of whether
	// they're a isHer or a isHim.  This is entirely to make it
	// easier to randomly assign names.
	_worstCaseActorsIsHer = 0
	_worstCaseActorsIsHim = 0

	// The total map will be this many zones by this many zones.  So
	// with zoneWidth = 2, there will be 2 x 2 zones, or 4 zones total.
	zoneWidth = 2

	// Vector to hold all the map generators we've created.
	zones = perInstance(new Vector())

	// Used to "cache" the most crowded room.  We update this
	// once per turn.
	_crowdedRoom = nil
	_crowdedRoomTimestamp = nil

	// Preinit method.  Builds the map and populates it with entirely
	// too many actors.
	execute() {
		constructMap();
		connectMap();
		addActors();
		summarize();
	}

	log(txt) { aioSay('\n<<toString(txt)>>\n '); }

	// Report on how many rooms and actors we created.
	summarize() {
		local i;

		i = 0;
		zones.forEach({ x: i += x._mapSize });
		log('===worstCase map generation summary start===');
		log('\tgenerated <<toString(zones.length())>> zones');
		log('\tgenerated <<toString(i)>> rooms');
		log('\tgenerated <<toString(worstCaseActors.length())>>
			actors');
		log('===worstCase map generation summary end===');
	}

	// Create and run a bunch of map generators.  This generates
	// the random maze blocks.
	constructMap() {
		local i, z;

		// We always create zoneWidth by zoneWidth zones.
		for(i = 1; i <= (zoneWidth * zoneWidth); i++) {
			z = new WorstCaseMapGenerator();
			z.preinit();
			zones.append(z);
			z.zoneNumber = zones.length();
		}
	}

	// Connect the random mazes we created above.
	// We always add two connections between adjacent zones, in
	// the corners.
	connectMap() {
		local i, j, n, z0, z1;

		for(j = 1; j <= zoneWidth; j++) {
			for(i = 1; i <= zoneWidth; i++) {
				// Get the "base" zone.
				n = i + ((j - 1) * zoneWidth);
				z0 = zones[n];

				// Don't connect east if the zone is
				// on the east edge.
				if(i < zoneWidth) {
					// Zone to the east of the base zone.
					z1 = zones[n + 1];
					_connectZonesEastWest(z0, z1);
				}

				// Don't connect north if the zone is
				// on the north edge.
				if(j < zoneWidth) {
					// Zone to the north of the base zone.
					z1 = zones[n + zoneWidth];
					_connectZonesNorthSouth(z0, z1);
				}
			}
		}
	}

	// Make the connection between rooms a door pair.
	// rm0 and rm1 are the rooms, prop0 and prop1 are the direction
	// properties for each.
	// Example:  _createDoorPair(foo, &north, bar, &south) means going
	// 	north from foo will lead to bar, and south from bar will
	//	lead to foo.
	_createDoorPair(rm0, prop0, rm1, prop1) {
		local d0, d1;

		// Create the door objects.
		d0 = new WorstCaseDoor();
		d1 = new WorstCaseDoor();

		// The second door refers to the first.
		d1.masterObject = d0;

		// Move the door objects into their respective rooms.
		d0.moveInto(rm0);
		d1.moveInto(rm1);

		// IMPORTANT:  Needed for normal adv3 Door stuff.
		d0.initializeThing();
		d1.initializeThing();

		// Start the door off unlocked.
		d0.makeLocked(nil);

		// Make the exit properties in the rooms point to their
		// door objects.
		rm0.(prop0) = d0;
		rm1.(prop1) = d1;
	}

	// Connect the east exit of rm0 and the west exit of rm1.
	_connectRoomEastWest(rm0, rm1) {
		if(useDoors == true) {
			_createDoorPair(rm0, &east, rm1, &west);
		} else {
			rm0.east = rm1;
			rm1.west = rm0;
		}
	}

	// Connect the north exit of rm0 and the south exit of rm1.
	_connectRoomNorthSouth(rm0, rm1) {
		if(useDoors == true) {
			_createDoorPair(rm0, &north, rm1, &south);
		} else {
			rm0.north = rm1;
			rm1.south = rm0;
		}
	}

	// Connect z0 to z1 east to west (z0 will be west of z1).
	_connectZonesEastWest(z0, z1) {
		_connectRoomEastWest(
			z0._getRoom(z0.mapWidth),
			z1._getRoom(1)
		);
		_connectRoomEastWest(
			z0._getRoom(z0._mapSize),
			z1._getRoom(z1._mapSize - z1.mapWidth + 1)
		);
	}

	// Connect z0 to z1 north to south (z0 will be south of z1).
	_connectZonesNorthSouth(z0, z1) {
		_connectRoomNorthSouth(
			z0._getRoom(z0._mapSize - z0.mapWidth + 1),
			z1._getRoom(1)
		);
		_connectRoomNorthSouth(
			z0._getRoom(z0._mapSize),
			z1._getRoom(z1.mapWidth)
		);
	}

	// Have each zone populate itself with actors.
	addActors() {
		zones.forEach({ x: x.addWorstCaseActors() });
	}

	// Returns a random zone instance.
	getRandomZone() { return(zones[wcRand(1, zones.length())]); }

	// Returns a random room instance.
	getRandomRoom() {
		local z;

		if((z = getRandomZone()) == nil) return(nil);
		return(z._getRoom(wcRand(1, z._mapSize)));
	}

	// Add a single actor to our list.
	addWorstCaseActor(a) {
		// Make sure the arg is valid.
		if(!isWorstCaseActor(a)) return(nil);

		// Append it to the list.
		worstCaseActors.appendUnique(a);

		// Keep a running total of the actors' pronouns.  This
		// is entirely to make it easier to assign names.
		if(a.isHer)
			_worstCaseActorsIsHer += 1;
		else
			_worstCaseActorsIsHim += 1;

		return(true);
	}

	// Wrapper for pathfinding.  The actor agendas call this method,
	// the intent being to make it easier to drop in replacements
	// for performance testing.
	findPath(actor, rm0, rm1) {
		return(roomPathFinder.findPath(actor, rm0, rm1));
	}

	// Returns the room containing the most WorstCaseActor instances.
	getMostCrowdedRoom() {
		local maxCount, maxRoom, ts, v;

		// Check the timestamp.  If we computed the most crowded
		// room earlier this turn, use the saved value.
		ts = libGlobal.totalTurns;
		if((_crowdedRoomTimestamp == ts) && (_crowdedRoom != nil))
			return(_crowdedRoom);

		// Remember that we counted everything this turn.
		_crowdedRoomTimestamp = ts;

		// Iterate over all WorstCaseRoom instances.
		maxCount = 0;
		forEachInstance(WorstCaseRoom, function(rm) {
			// Count for this room.
			v = 0;

			// Add up the number of WorstCaseActors in this room.
			rm.contents.forEach(function(o) {
				if(o.ofKind(WorstCaseActor))
					v += 1;
			});

			// If this room's count is higher than the prior
			// max, remember the count and which room it was in.
			if(v > maxCount) {
				maxCount = v;
				maxRoom = rm;
			}
		});

		// Update the cached value.
		_crowdedRoom = maxRoom;

		// Return it.
		return(maxRoom);
	}

	// Put the given object into a random room.
	putInRandomRoom(obj) {
		local rm;

		if((obj == nil) || !obj.ofKind(Thing))
			return(nil);

		if((rm = getRandomRoom()) == nil)
			return(nil);

		obj.moveInto(rm);

		return(true);
	}
;

#else // WORST_CASE

// Stub object.  Provided so the compiler won't complain if a game
// twiddles with worstCase and then is compiled without -D WORST_CASE.
worstCase: object
	useDoors = nil
	zoneWidth = nil

	getRandomRoom() {
		return(gameMain.initialPlayerChar ?
			gameMain.initialPlayerChar.getOutermostRoom()
			: nil);
	}

	findPath(actor, rm0, rm1) {
		return(roomPathFinder.findPath(actor, rm0, rm1));
	}

	putInRandomRoom(obj) { return(nil); }
;

#endif // WORST_CASE
