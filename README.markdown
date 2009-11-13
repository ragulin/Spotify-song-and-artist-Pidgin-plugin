Pidgin spotify uri plugin
=========================

A small Pidgin plugin that adds song/album and artist to all incoming
messages containing a Spotify uri.

Examples:

spotify:track:6JEK0CvvjDjjMUBFoXShNZ becomes spotify:track:6JEK0CvvjDjjMUBFoXShNZ (Never Gonna Give You Up by Rick Astley)

http://open.spotify.com/track/6JEK0CvvjDjjMUBFoXShNZ becomes http://open.spotify.com/track/6JEK0CvvjDjjMUBFoXShNZ (Never Gonna Give You Up by Rick Astley)

Tested on Ubuntu 9.04 and Pidgin 2.6.3

Requirements
------------
* Perl http://www.perl.org/
* LWP::Simple http://search.cpan.org/~gaas/libwww-perl-5.833/lib/LWP/Simple.pm

Installation
------------
1. Copy the script to ~/.purple/plugins
2. Start Pidgin and choose Tools -> Plugins and activate the 'Show Spotify artist and song' plugin.

Todo
----
Remove dependencies to LWP::Simple and use the provided API from
Pidgin instead, ie Purple::Util::fetch_url()

