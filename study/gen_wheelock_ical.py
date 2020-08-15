#!/usr/bin/env python3
"""

Generate an ICS calendar for Wheelock Latin study group

"""

import datetime
import re
import sys
import argparse
import logging
from ics import Calendar, Event, DisplayAlarm

try:                            # nice-to-have but not critical
    import colorlogger
except ImportError:
    pass


__version__ = "1.0"


def main(args):
    "Main entry point."

    rx_hw = re.compile(r'^\s*([A-Z][a-z]+)\s*\.?\s+(\d+)\s*:\s*(\S.*\S)\s*$')
    rx_year = re.compile(r'^\s*(\d{4})\s*:?\s*$')
    calendar = Calendar()

    year = datetime.date.today().year

    with open("schedule.in") as fin:
        for line in fin:
            match = rx_year.search(line)

            if match:
                year = int(match.group(1))
                continue

            match = rx_hw.search(line)

            if match:
                (month_abbr, day, assignment) = (match.group(1),
                                                 match.group(2),
                                                 match.group(3))

                if month_abbr == "Sept":
                    month_abbr = "Sep"

                date_str = "%s %s, %d" % (month_abbr, day, year)
                date = None

                try:
                    date = datetime.datetime.strptime(date_str, "%b %d, %Y")
                except ValueError:
                    pass

                if not date:
                    try:
                        date = datetime.datetime.strptime(date_str, "%B %d, %Y")
                    except ValueError:
                        pass

                if not date:
                    logging.error("Bad date spec: %s", line)
                    continue


                event = Event()
                event.name = "%s (%s)" % (args.group, assignment)
                event.begin = date.strftime("%Y-%m-%d 00:00:00")
                alarm_time = date + datetime.timedelta(hours=-1)
                alarm = DisplayAlarm(trigger=alarm_time,
                                     #datetime.timedelta(days=-1),
                                     display_text="Wheelock assignment due in 1 day")
                event.alarms.append(alarm)
                #date_end = date + datetime.timedelta(days=1)
                #e.end = date_end.strftime("%Y-%m-%d 00:00:00")
                event.make_all_day()
                calendar.events.add(event)


    with open("wheelock.ics", "wt") as fout:
        fout.writelines(calendar)



def _parse_args():
    "Parse command line args."

    parser = argparse.ArgumentParser(
        description=globals()["__doc__"],
        formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("-D", "--debug", action="store_true",
                        dest="debug_mode", default=False,
                        help="debug mode")
    parser.add_argument("-g", "--group", metavar="NAME", dest="group",
                        default="Wheelock Davenport", help="Study group name")
    parser.add_argument("-v", "--verbose", action="store_true",
                        dest="verbose_mode", default=False,
                        help="verbose mode")
    parser.add_argument("--version", action="version",
                        version="%(prog)s {version}".format(version=
                                                            __version__))
    parser.add_argument("args", type=str, nargs="*",
                        help="Arguments to the program")
    return parser.parse_args()


if __name__ == "__main__":
    OPTIONS = _parse_args()

    if OPTIONS.debug_mode:
        logging.basicConfig(level=logging.DEBUG,
                            format="%(levelname)s: %(message)s")
    else:
        logging.basicConfig(format="%(levelname)s: %(message)s")

    try:
        main(OPTIONS)
        sys.exit(0)

    except KeyboardInterrupt as exc:  # Ctrl-C
        raise exc


# Local Variables:
# compile-command: "pylint -r n gen_wheelock_ical.py"
# end:
