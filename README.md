Introduction
------------

This is a puppet module to manage an in-house maintained version of the
SUNWzfs-auto-snap package that was originally written for OpenSolaris.
Our version is backported to Solaris 10 and makes use of the OpenCSW
ksh93 package to fill in some missing functionality in the old version
of ksh that ships with Solaris 10.

The module currently only handles the CSW dependencies for the package.
It does not handle installing the actual package, nor does it enable
the services. That functionality is still being handled by our CFengine
installation.
