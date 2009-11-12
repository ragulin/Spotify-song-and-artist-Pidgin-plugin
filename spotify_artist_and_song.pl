use XML::Simple;
use LWP::Simple;
use Purple;

use strict;
use warnings;

our %PLUGIN_INFO = (
    perl_api_version => 2,
    name => "Show Spotify artist and song",
    version => "0.1",
    summary => "Adds artist and song to incoming messages containing Spotify uris.",
    description => "Adds artist and song to incoming messages containing Spotify uris.",
    author => "Mikael Forsberg <mikael.forsberg\@athega.se>",
    url => "http://athega.se",
    load => "plugin_load",
    unload => "plugin_unload"
);

sub convert_link {
	my ($account, $sender, $message, $conv, $flag, $data) = @_;
	if ($message =~ /spotify:(track|album)|open\.spotify\.com/) {
	    $_[2] =  $message . get_artist_and_song($message);
	}
    return 0;
}

sub get_artist_and_song {
    my $message = shift;

    $message =~ /(?:open\.)?spotify(?:\.com)?(?:\/|:)(track|album)(?:\/|:)(.*?)(?:\s|<)+/;
    my ($media, $id);
    if (defined $1 && defined $2) {
        $media = $1;
        $id = $2;
    } else {
        return ;
    }

	return " (" . parse_link($id, $media) . ")";
}

sub parse_link {
    my ($id, $media) = @_;
    my $data = get_data($id, $media);
    return $data->{$media}[0]{'name'}[0] . " by " . $data->{$media}[0]{'artist'}[0]{'name'}[0];
}

sub get_data {
    my ($id, $media) = @_;
    my $url = 'http://ws.spotify.com/lookup/1/?uri=spotify:' . $media . ':' . $id;
    my $content = get($url);
    my $simple = new XML::Simple;
    return $simple->XMLin($content, ForceArray => 1, KeepRoot => 1);
}

sub plugin_init {
    return %PLUGIN_INFO;
}

sub plugin_load {
    my $plugin = shift;
    my $message_handle = Purple::Conversations::get_handle();
    Purple::Signal::connect($message_handle, "receiving-im-msg",
                                 $plugin, \&convert_link, undef);
}

sub plugin_unload {
    my $plugin = shift;
    Purple::Debug::info("Song and artist plugin", "plugin_unload() - Spotify song and artist plugin unloaded.\n");
}

