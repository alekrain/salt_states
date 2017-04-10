***Engines***
---
**NPI**
---
*Overview*
---
NPI (Nagios Passive Ingest) is an engine that takes specific events off the Nagios minion's Salt bus and loads them into Nagios as Passive check results. Specific events refer to events for which the engine has a parser to process the data of the event. All parsers live in the `npi_parsers` directory. To be made available to the npi.py engine, there needs to be an import statement and as well as an entry in the 'parsers' dict.

*Architecture*
---
Generally, the way this is useful to me is through the use of Salt Beacons. I first write a beacon to check the status of something on a minion. The beacon sends Salt events to the master containing the status of that thing. The master receives the beacon event and through the use of the Salt Reactor, knows to relay this event to the Nagios minion over the event bus. The NPI engine reads the event once it arrives on the Nagios minion's event bus and checks to see if there is a parser available for that type of event.
