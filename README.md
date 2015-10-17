This script makes use of the MIST library for DCS: World.

Wrote a custom Lua script to allow for dropping units off from the recently released UH-1H Huey helicopter and then picking them up again after a set amount of time. This script also controls an automated process for asset verification via two AI UH-60 Blackhawk helicopters should no players slot into UH-1H Huey positions.

* Group dynamically spawns at User's location
* Group spawns on the side of the Huey closest to the objective that they're moving towards
* Group dynamically navigates to set point (friendly asset in this case)
* Group waits for set amount of time while other objectives are managed
* Group checks to see if User is on the ground, if not they call in for pick-up
* Group dynamically navigates back to User's aircraft location (in case they've moved)
* Group sets trigger and deactivates to simulate being picked up
* Group does not spawn or move to extraction until helicopter has touched down and stopped moving

* Works for multiple aircraft (in Multiplayer, one user can drop off units and another can pick them up upon mission completion if necessary [first player dead, occupied, RTB, etc])

Currently the units must spawn pretty far away from the drop off helicopter since the hit boxes are so large on the UH-1H any closer and the units get "stuck" and cannot navigate until the helicopter is airborne again but hopefully in the future that will be optimized and units will look even more realistic in their spawn and deactivation distances.

This has been incorporated into my mission "Asset Extraction" v1.1 for DCS: World v1.2.4.
