use LWP::Simple;
use Purple;

use strict;
use warnings;

our %PLUGIN_INFO = (
    perl_api_version => 2,
    name => "Show Spotify artist and song",
    version => "0.2",
    summary => "Adds artist and song to incoming messages containing Spotify uris.",
    description => "Adds artist and song to incoming messages containing Spotify uris.",
    author => "Mikael Forsberg <mikael.forsberg\@athega.se>",
    url => "http://athega.se",
    load => "plugin_load",
    unload => "plugin_unload"
);

sub convert_link {
    # matches a spotify uri or a spotify HTTP link
    # $1 = original uri
    # $2 = media, track or album
    # $3 = media id
    $_[2] =~ s/((?:http:\/\/)?(?:open\.)?spotify(?:\.com)?(?:\/|:)(track|album)(?:\/|:)(\w+))/$1 . ' ' . get_artist_and_song($2, $3)/eg;
    return 0;
}

sub get_artist_and_song {
    my ($media, $id) = @_;

    my $data = get_data($id, $media);
    return " (" . parse_xml($data) . ")";
}

sub parse_xml {
    my $data = shift;
    if (!$data) {
        return;
    }
  	my $root = Purple::XMLNode::from_str($data);
    my $name = $root->get_child("name")->get_data();
    my $artist = $root->get_child("artist")->get_child("name")->get_data();
    return "$name by $artist";
}

sub get_data {
    my ($id, $media) = @_;
    my $url = 'http://ws.spotify.com/lookup/1/?uri=spotify:' . $media . ':' . $id;
    return get($url);
}

sub plugin_init {
    return %PLUGIN_INFO;
}

sub plugin_load {
    my $plugin = shift;
    my $message_handle = Purple::Conversations::get_handle();
    Purple::Signal::connect($message_handle, "receiving-im-msg",
                                 $plugin, \&convert_link, $plugin);
}

sub plugin_unload {
    my $plugin = shift;
    Purple::Debug::info("Song and artist plugin", "plugin_unload() - Spotify song and artist plugin unloaded.\n");
}

