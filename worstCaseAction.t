#charset "us-ascii"
//
// worstCaseAction.t
//
#include <adv3.h>
#include <en_us.h>

#include "worstCase.h"

#ifdef WORST_CASE

// Display an ASCII art map of the current population distribution.
// Maps are always square grids of zones, where each zone is a square maze.
// Zones increase left to right, bottom to top, so zone 1 is always lower
// left and zone n is always upper right.
// Each room is represented by:
//
//	-A number 0-9, indicating the relative number of actors in that
//	 room (scales depending on the total number of actors in the game)
//	-A "." if the room contains no actors
//	-A "@" indicating the player's position
//	-A "?" indicating an error (should never happen)
//
DefineIAction(WorstCaseMap)
	execAction() {
		local buf, idx, i, j, mapWidth, y, zoneCount, zoneWidth;

		// To hold the ASCII map.
		buf = new StringBuffer();

		// Number of zones.  If there's < 1, nothing to map.
		zoneCount = worstCase.zones.length();
		if(zoneCount < 1) {
			reportFailure('Nothing to map. ');
			return;
		}

		// Zones are always the same size, so we get the width
		// from the first one (which we know we'll have, per the
		// check above).
		mapWidth = worstCase.zones[1].mapWidth;

		// Zone width.  Mostly for convenience.
		zoneWidth = worstCase.zoneWidth;

		// Iterate over all zones, zoneWidth at a time (this will
		// get one row of zones each pass)
		// First zone in last/top row is zoneCount - zoneWidth + 1.
		for(i = zoneCount - zoneWidth + 1; i >= 1; i -= zoneWidth) {

			// Now we iterate over each map y-value for this
			// row, starting at the top.
			for(y = mapWidth - 1; y >= 0; y--) {

				// Finally we iterate over each zone in this
				// row, getting the line of output for this
				// y value.
				for(j = 0; j < zoneWidth; j++) {
					idx = i + j;
					if(idx > zoneCount)
						continue;
					buf.append(getMapLine(idx, y));
				}

				// Add a newline at the end of the y-line.
				buf.append('\n ');
			}
		}

		"\n<<toString(buf)>>\n ";
	}

	getMapLine(idx, y) {
		local x, txt, zone;

		zone = worstCase.zones[idx];
		txt = new StringBuffer();
		for(x = 1; x <= zone.mapWidth; x++) {
			txt.append(getMapTile(x, y, zone));
		}

		return(toString(txt));
	}

	getMapTile(x, y, zone) {
		local d, idx, n, rm;

		idx = (y * zone.mapWidth) + x;

		if((rm = zone._getRoom(idx)) == nil)
			return('?');

		if(rm == gameMain.initialPlayerChar.getOutermostRoom())
			return('@');

		n = rm.contents
			.subset({ x: x.ofKind(WorstCaseActor) }).length();

		if(n == 0)
			return('.');

		d = worstCase.worstCaseActors.length() / 10;
		if(d < 1)
			d = 1;
		n /= d;

		if(n > 9)
			n = 9;

		return(toString(n));
	}
;
VerbRule(ActorMap) 'wcm' : WorstCaseMapAction verbPhrase = 'wcm/wcming';


#endif // WORST_CASE
