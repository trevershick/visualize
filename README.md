# visualize

This is my less than impressive project where i'm simply stashing files and utilities for visualizing configuration files.

I've only got a few in here now...
* Spring Batch xml configuration file XSL transformer to DOT
* Struts-Config to DOT transformer written in clojure - primitive

These are not the end all be all, nor are they even really inspiring, but they have worked for what i've needed them for.

## Usage

Compile the struts config transformer via leiningen "lein uberjar" then run java -jar XXX.jar <struts_config.xml>
The spring batch configuration file should be run via xslt. I'll wrap this in clojure soon enough.

## License

Copyright (C) 2012

Distributed under the Eclipse Public License, the same as Clojure.
