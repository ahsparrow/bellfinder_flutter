# Bell Finder - A change ringers' directory of bell towers

Copyright (C) 2020 Alan Sparrow

Bell Finder summarises of the details of the more than 7000 bell towers
with rings of three or more bells. The app also allows you to record
details of any visits.

Bell Finder uses the Dove data file from the Central Council of Church
Bellringers (CCCBR). The file (bellfinder/src/main/assets/dove.txt) is a
modified version of the CCCBR's original with the removal some unused fields.
The file is distributed under a Creative Commons license (see below.)

LICENSES

1. Bell Finder is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Bell Finder is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see <https://www.gnu.org/licenses/>.

1. The Dove tower data (app/src/main/assets/dove.txt) is a modified
   version of the file provided by the Central Council of Church Bell
   Ringers and is licensed under the Creative Commons Attribution-
   ShareAlike 4.0 International Public License. To view a copy of the
   license, visit <https://creativecommons.org/licenses/by-sa/4.0/legalcode>

## Release build (Android)

Set keystore properties in android/key.properties.

Set version name and build number in pubspec.yaml, e.g to set
version 1.2.3, build 45 use "1.2.3+45"

Update Dove data in assets/dove.json

Run `flutter build appbundle -dart-define='DOVE_DATE=<date string>`

The release bundle is created at `[project]/build/app/outputs/bundle/release/app.aab`
