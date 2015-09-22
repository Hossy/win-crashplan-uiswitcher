UISwitcher 1.3 by Hossy
=======================

Installation
------------
Extract the contents of the 7z file directly to your CrashPlan install directory.
For example: C:\Program Files\CrashPlan\UISwapper

Files:

- .\CrashPlan (Local).lnk
- .\CrashPlan (My PC).lnk
- .\CrashPlan (SSH Tunnel).lnk
- .\sed.exe
- .\UISwapper.bat

There are three example shortcuts created:

- CrashPlan (Local)
  - This launches CrashPlan to manage your local instance.
- CrashPlan (My PC)
  - This launches CrashPlan to manage a computer named MYPC (see more info about
    direct connecting below).
- CrashPlan (SSH Tunnel)
  - This launches a PuTTY session named "Putty Session Name Here" then launches
    CrashPlan and connects through that tunnel (see more info about SSH Tunnel
    below).


Background
----------
CrashPlan uses the `conf\ui.properties` and
`%ProgramData%\CrashPlan\conf\ui_%USERNAME%.properties` files to determine where it
should connect and a key (guid from `.ui_info`) to authenticate that connection (as
of CrashPlan 4.3).  `UISwapper.bat` updates the `ui.properties`, `.ui_info`, and
`ui_[USERNAME].properties` files to redirect CrashPlan to another computer.

`UISwapper.bat` also monitors changes to the `.identity` file as a precaution.  If
this file substantially changes, it could mean that file changes outside what
`UISwapper.bat` is monitoring will cause your local instance to stop working.
Because of this and the newness of this new security system, I've built in a
fail-safe to halt `UISwapper.bat` until you can manually verify connectivity and
functionality of your local instance (and backup files as needed).  This feature
may go away in the future if I'm able to determine it really isn't needed.

**IMPORTANT:** The first time you run UISwapper it will create ".local" versions of
the four files mentioned above.  BEFORE running UISwapper for the first time,
verify that these .local files do not exist and that your CrashPlan UI is
connecting to your local instance without issue.

**NOTE:** The changes made by `UISwapper.bat` do not affect your CrashPlan Tray
icon.  That will always display information for your local instance.


### CrashPlan Bug in 4.3.0 ###
As I just discovered today (9/22/2015), there is a bug within CrashPlan if you
change the listening port even under the supported procedure (e.g. [Known Conflict Between The CrashPlan App And Juniper Network Connect On Windows](http://support.code42.com/CrashPlan/Latest/Troubleshooting/Known_Conflict_Between_The_CrashPlan_App_And_Juniper_Network_Connect_On_Windows)).
The bug is that when you change the listening port, the
`%ProgramData%\CrashPlan\conf\ui_%USERNAME%.properties` file is not properly
updated to reflect the change.  While this doesn't break the CrashPlan service
itself, it prevents the UI from connecting to the local instance.

I have written a procedure within `UISwapper.bat` that detects a port change and
will fix the `%ProgramData%\CrashPlan\conf\ui_%USERNAME%.properties` file to keep
the UI working on the local instance.  As a precaution, this procedure will only
run if the CrashPlan instance is 4.3.0.  My hope is that the next release of
CrashPlan will fix this bug.  If it doesn't, I will post a new version of the
script to handle the updated version.  For the foreseeable future, I plan on
keeping the bug fix procedure version-specific to prevent future problems.

You can always fix the bug manually by editing the servicePort line in the
`%ProgramData%\CrashPlan\conf\ui_%USERNAME%.properties` file and restarting the UI.

Enabling Remote Management of CrashPlan
---------------------------------------
By default, CrashPlan locks itself down to only be managed locally.  This can be
changed by editing the `my.service.xml` file.  This must be done on every machine
you intend to manage remotely.

**WARNING:** Doing this will cause CrashPlan to accept remote connections from
anywhere.  Be sure you understand what this means.  It is **HIGHLY** recommended
that you enable the option to require a password for the desktop application. To do
this:

1. Open CrashPlan.
2. Click Settings.
3. Choose the Security tab.
4. Check the box for "Require account password to access CrashPlan desktop
   application" if it isn't already checked.
5. Click Save.

For more information about securing CrashPlan, check out [Security Settings Reference](http://support.code42.com/CrashPlan/Latest/CrashPlan_App_Reference/Security_Settings_Reference).

On Windows, the `my.service.xml` file is located at:
`%ProgramData%\CrashPlan\conf\my.service.xml`

1. Stop the CrashPlan Backup Service under Services.
   - You can also do this by running: `net stop CrashPlanService`
2. Create a backup copy of your `my.service.xml` file.
3. Open the `my.service.xml` file and locate the line:
   `<serviceHost>127.0.0.1</serviceHost>`.  It should be under the
   `<serviceUIConfig>` section.
4. Change 127.0.0.1 to 0.0.0.0.
   - Old line: `<serviceHost>127.0.0.1</serviceHost>`
   - New line: `<serviceHost>0.0.0.0</serviceHost>`
5. Save the file.
6. Start the CrashPlan Backup Service.
   - You can also do this by running: `net start CrashPlanService`

That's it.  Remote Management is now enabled.  Now, let's actually use it.


Gathering the connection key (guid) from the remote computer
------------------------------------------------------------
The connection key is located within the `.ui_info` file.  The format of this file
is `<port>,<guid>` -- you only need the `<guid>` portion.

`.ui_info` file locations:

- Windows: `%ProgramData%\CrashPlan\.ui_info`
- Linux: `/var/lib/crashplan/.ui_info`
- Mac: `/Library/Application Support/CrashPlan/.ui_info` (need to have finder set
to show hidden files)


Direct Connecting
-----------------
### Instructions ###

Use `.\CrashPlan (My PC).lnk` as a shortcut template for direct connections:

1. Create a copy of the shortcut.
2. Right-click the copy and choose Properties.
3. In the `Target` field on the `Shortcut` tab:
   - Change "mypc" to be IP or hostname of the remote computer.
   - Replace the GUID after `/uiinfoguid` with the connection key from the remote
     computer.
4. Click the General tab and rename your shortcut as needed.
5. Click OK.

You're done.  Double-click your shortcut and manage your remote CrashPlan instance.


Connecting Through an SSH Tunnel
--------------------------------
### References ###

- [Using CrashPlan On A Headless Computer](http://support.crashplan.com/doku.php/how_to/configure_a_headless_client)
- [Configuring PuTTY: 4.1.2 Loading and storing saved sessions](http://the.earth.li/~sgtatham/putty/0.62/htmldoc/Chapter4.html#config-saving)

Use the references above to create your PuTTY SSH Tunnel saved session.  You will
need the saved session name and the local port you chose.  CrashPlan's
documentation uses local port 4200.

#### Configure shortcut to connect to CrashPlan ####

Use `.\CrashPlan (SSH Tunnel).lnk` as a shortcut template for direct connections:

1. Create a copy of the shortcut.
2. Right-click the copy and choose `Properties`.
3. In the `Target` field on the `Shortcut` tab:
   - Change "12345" (after `/port`) to the local port you specified in your SSH
     Tunnel config.
   - Change "Putty Session Name Here" (after `/putty`) to your PuTTY saved session
     (leave the double-quotes there).
   - Replace the GUID after `/uiinfoguid` with the connection key from the remote
     computer.
4. Click the `General` tab and rename your shortcut as needed.
5. Click OK.

You're done.  Double-click your shortcut, establish your SSH tunnel when prompted,
and manage your remote CrashPlan instance.


Troubleshooting
---------------
If you experience problems connecting to your local instance with UISwapper, please
confirm against your three ".local" files that the servicePort is 4243.  If the
value is other than 4243, you will need to modify `UISwapper.bat` and change the
line that reads `SET _SVCPORT=4243` to the appropriate port.  If this still fails,
try reinstalling the CrashPlan UI on your computer, delete the three ".local"
files, check the servicePort within `conf\ui.properties` and update `UISwapper.bat`
is necessary, and try again.


Copyright
---------
Copyright 2012,2014-2015 Hossy

`UISwitcher` is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

`UISwitcher` is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with `UISwitcher`.  If not, see <http://www.gnu.org/licenses/>.

Change Log
----------
### v1.3 ###
- Added /resetlocal switch to allow manual cleanup/reset of the .local files.
- Added monitor for .identity file as a precaution against potentially unmonitored
changes.
- Added check for CrashPlan listening port changes
- Added procedure to fix CrashPlan 4.3.0 bug when changing the listening port
- Fixed potential problem with regular expressions

### v1.2 ###
- Updated UISwapper to handle new connection security feature in CrashPlan 4.3+.

### v1.1 ###
- Fixed problem running on Windows 8

### v1.0 ###
- Initial commit
