**Violation Points System for FiveM (QBCore)**
Overview
The Violation Points System is a customizable QBCore script for FiveM roleplay servers. It provides a mechanism for tracking and managing player violations through a points-based system. The script allows staff to add or remove points from players, track the reasons for the points, and logs points removals for accountability.

This system supports staff commands to manage points, a player menu to check their own violation points, and a detailed log of all points-related actions, including removals.

**Features**

**Add Violation Points**: Staff can add violation points to players with a configurable reason.
**Remove Violation Points**: Staff can remove violation points from players and record the reason for removal.
**Player Points View**: Players can check their own violation points and associated reasons.
**Staff Points Check**: Staff can check any player's violation points and view removal logs.
**Logs**: Detailed logs of point additions and removals, including the staff member's name and timestamp, are stored in JSON files.
**Configurable**: Easy-to-edit configuration for adding/removing points, player identification, and reason input.

**Installation**
Download or Clone the repository to your server.
Place the script folder in your resources directory.
Add ensure <script_name> in your server.cfg to ensure the script is loaded.

**Configuration**
**Points Data Storage**
File Path: resources/[your_script]/violation_points.json
This JSON file stores each player's violation points and their corresponding reasons.

**Removal Logs**
Log File Path: resources/[your_script]/violation_logs.json
This JSON file logs the details of points removals, including the staff member's name and the reason for removal.

**Staff Commands**
/addpoints <playerID> <points> <reason>: Adds violation points to a player.
/removepoints <playerID> <points> <reason>: Removes violation points from a player.
/scheckpoints <playerID or Partial Name>: Allows staff to check another player's violation points, including removal logs.

**Usage**
**For Players**:
Players can use the /checkpoints command to view their own violation points and reasons.
**For Staff**:
Staff can use the /addpoints command to add violation points to players, specifying the number of points and the reason for the violation.
Staff can also use the /removepoints command to remove points from a player, with a reason for removal.
Staff members can check a player's violation points and removal history using the /scheckpoints command.

**Commands**
Command	Description	Usage Example
/addpoints	Add violation points to a player.	/addpoints 1 10 "Speeding"
/removepoints	Remove violation points from a player.	/removepoints 1 5 "Cleared by staff"
/checkpoints	Check your own violation points.	/checkpoints
/scheckpoints	Check another player's violation points and removal logs.	/scheckpoints 1 Good behavior


**The following data is logged for each action**:
**Added Points**:
Player's License ID
Points added
Reason for points
Timestamp
Staff member who added the points

**Remove Points**:
Player's License ID
Points removed
Reason for removal
Timestamp
Staff member who removed the points
This data is stored in violation_points.json and violation_logs.json for auditing purposes.

Dependencies
QBCore Framework: This script is built for use with the QBCore framework for FiveM.
Customization

**The system is fully customizable**:
**Adding/removing points**: Staff can define the number of points and provide a reason for the violation.
**Logs**: Customize how point additions and removals are logged and displayed.
**UI**: The points display can be styled and modified to fit your server's design.

**Troubleshooting**
If you encounter issues with the script, ensure the following:
The script is placed in the correct folder in your resources directory.
The server has the QBCore framework properly installed.
Check the server logs for errors related to JSON file writing permissions.
If issues persist, please feel free to create an issue in the GitHub repository.

**License**
This project is licensed under the MIT License - see the LICENSE file for details.

Credits
QBCore Framework: For providing the base for the script.
