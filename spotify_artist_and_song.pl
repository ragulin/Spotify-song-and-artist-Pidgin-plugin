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
	my ($account, $sender, $message, $conv, $flag, $data) = @_;
	if ($message =~ /(?:open\.)?spotify(?:\.com)?(?:\/|:)(track|album)(?:\/|:)(.*?)(?:\s|<)+/) {
	    $_[2] =  $message . get_artist_and_song($1, $2);
	}
    return 0;
}

sub get_artist_and_song {
    my $media = shift;
    my $id = shift;

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
    my $content = get($url);
    return $content;
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

