UISwitcher 1.0 by Hossy
=======================

Installation
------------
Extract the contents of the 7z file directly to your CrashPlan install directory.
For example: C:\Program Files\CrashPlan

Files:

- .\CrashPlan (Local).lnk
- .\CrashPlan (Mu PC).lnk
- .\CrashPlan (SSH Tunnel).lnk
- .\UISwapper.bat
- .\conf\ui.properties.local
- .\conf\ui.properties.mypc
- .\conf\ui.properties.sshtunnel

There are three example shortcuts created:

- CrashPlan (Local)
  - This launches CrashPlan to manage your local instance.
- CrashPlan (My PC)
  - This launches CrashPlan to manage a computer named MYPC (see
more info about direct connecting below).
- CrashPlan (SSH Tunnel)
  - This launches a PuTTY session named "Putty Session Name Here" then launches
    CrashPlan and connects through that tunnel (see more info about SSH Tunnel
    below).


Enabling Remote Management of CrashPlan
---------------------------------------
By default, CrashPlan locks itself down to only be managed locally.  This can be
changed by editing the `my.service.xml` file.  This must be done on every machine you
intend to manage remotely.

**WARNING:** Doing this will cause CrashPlan to accept remote connections from
anywhere.  Be sure you understand what this means.  It is **HIGHLY** recommended that
you enable the option to require a password for the desktop application. To do
this:

1. Open CrashPlan.
2. Click Settings.
3. Choose the Security tab.
4. Check the box for "Require account password to access CrashPlan desktop
   application" if it isn't already checked.
5. Click Save.

For more information about securing CrashPlan, check out <http://support.code42.com/CrashPlan/Latest/Configuring/Security>.

On Windows 7, the `my.service.xml` file is is located at:
`C:\ProgramData\CrashPlan\conf\my.service.xml`

1. Stop the CrashPlan Backup Service under Services.
   - You can also do this by running: `net stop CrashPlanService`
2. Create a backup copy of your `my.service.xml` file.
3. Open the `my.service.xml` file and locate the line: `<serviceHost>127.0.0.1</serviceHost>`.  It should be under the `<serviceUIConfig>` section.
4. Change 127.0.0.1 to 0.0.0.0.
   - Old line: `<serviceHost>127.0.0.1</serviceHost>`
   - New line: `<serviceHost>0.0.0.0</serviceHost>`
5. Save the file.
6. Start the CrashPlan Backup Service.
   - You can also do this by running: `net start CrashPlanService`

That's it.  Remote Management is now enabled.  Now, let's actually use it.


Direct Connecting
-----------------
CrashPlan uses the `conf\ui.properties` file to determine where it should connect.
`UISwapper.bat` switches out the `ui.properties` file to redirect CrashPlan to another
computer.

**NOTE:** The `ui.properties` file does not affect your CrashPlan Tray icon.  That will
always display information for your local instance.

Use `.\conf\ui.properties.mypc` as a template for direct connections:

1. Open `ui.properties.mypc` in a text editor like Notepad.
   - Notice the only uncommented line (lines not beginning with #) is line 2:
     `serviceHost=MYPC`.  This instructs CrashPlan to lookup the IP for MYPC and connect to that computer.
2. Change "MYPC" in line 2 to the name or IP address of the remote computer.
3. Save the file with a new name in the format `ui.properties.<identifier>` (without
   the angle brackets).  Replace `<identifier>` with something meaningful to you (no spaces).

Use `.\CrashPlan (My PC).lnk` as a shortcut template for direct connections:

1. Create a copy of the shortcut.
2. Right-click the copy and choose Properties.
3. In the Target field on the Shortcut tab, change "mypc" to be the `<identifier>`
   you chose above.
4. Click the General tab and rename your shortcut as needed.
5. Click OK.

You're done.  Double-click your shortcut and manage your remote CrashPlan instance.


Connecting Through an SSH Tunnel
--------------------------------
### References ###

- <http://support.crashplan.com/doku.php/how_to/configure_a_headless_client>
- <http://the.earth.li/~sgtatham/putty/0.62/htmldoc/Chapter4.html#config-saving>

Use the references above to create your PuTTY SSH Tunnel saved session.  You will
need the saved session name and the local port you chose.  CrashPlan's
documentation uses local port 4200.

### Instructions ###

Use `.\conf\ui.properties.sshtunnel` as a template for SSH tunnel connections:

1. Open `ui.properties.sshtunnel` in a text editor like Notepad.
   - Notice the only uncommented line (lines not beginning with `#`) is line 3:
`servicePort=4200`.  This instructs CrashPlan to use local port 4200 to connect to the CrashPlan Backup
Service.
2. Change "4200" in line 3 to the local port you specified in your SSH Tunnel config.
3. Save the file with a new name in the format `ui.properties.<identifier>` (without
   the angle brackets).  Replace `<identifier>` with something meaningful to you (no spaces).

Use `.\CrashPlan (SSH Tunnel).lnk` as a shortcut template for direct connections:

1. Create a copy of the shortcut.
2. Right-click the copy and choose `Properties`.
3. In the `Target` field on the `Shortcut` tab:
   - Change "sshtunnel" to be the `<identifier>` you chose above.
   - Change "Putty Session Name Here" to your PuTTY saved session (leave the
     double-quotes there).
4. Click the `General` tab and rename your shortcut as needed.
5. Click OK.

You're done.  Double-click your shortcut, establish your SSH tunnel when prompted,
and manage your remote CrashPlan instance.

Copyright
---------
Copyright 2012-2013 Hossy

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
### v1.0 ###
- Initial commit