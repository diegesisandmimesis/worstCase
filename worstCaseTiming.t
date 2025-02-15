#charset "us-ascii"
//
// worstCaseTiming.t
//
#include <adv3.h>
#include <en_us.h>

#include <date.h>
#include <bignum.h>

#include "worstCase.h"

#ifdef WORST_CASE

modify Person
	executeTurn() {
		inherited();
		if(isPlayerChar())
			worstCaseAfter.saveTimestamp();
	}
;

worstCaseAfter: Schedulable
	scheduleOrder = 999
	ts = nil
	nextRunTime = (libGlobal.totalTurns)

	saveTimestamp() { ts = new Date(); }
	getInterval(d) {
		if((d == nil) || !d.ofKind(Date)) return(0);
		return(((new Date() - d) * 86400).roundToDecimal(5));
	}
	executeTurn() {
		if(ts != nil) {
			"\n<.P>Turn took <<toString(getInterval(ts))>>
				seconds.\n ";
		}
		incNextRunTime(1);
		return(nil);
	}
;

#endif // WORST_CASE
