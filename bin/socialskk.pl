#!/usr/bin/env perl
use strict;
use warnings;
use YAML::Syck;
use File::Spec;
use File::HomeDir;
use Getopt::Long;
use Sys::Hostname;
use POE qw(Component::Server::TCP Filter::Stream);

use App::SocialSKK;

my %options = (
    config   => File::Spec->catfile(File::HomeDir->my_home, '.socialskk'),
    port     => 1179,
    address  => '127.0.0.1',
    hostname => Sys::Hostname::hostname(),
);

GetOptions(
    'config=s'   => \$options{config},
    'hostname=s' => \$options{hostname},
    'address=s'  => \$options{address},
    'port=i'     => \$options{port},
);

# use Social IME as a default backend
my $config = {
    plugins => [
        { name => 'SocialIME' },
    ],
};

$config =  YAML::Syck::LoadFile($options{config}) if -e $options{config};
my $app = App::SocialSKK->new({(%options, config => $config)});

POE::Component::Server::TCP->new(
    Port         => $options{port},
    Address      => $options{address},
    Hostname     => $options{hostname},
    ClientFilter => POE::Filter::Stream->new,
    ClientInput  => sub {
        my ($kernel, $heap, $input)  = @_[KERNEL, HEAP, ARG0];
        if ($input =~ /^0/) {
            $kernel->yield('shutdown');
            return;
        }
        my $result = $app->protocol->accept($input);
        if (defined $result) {
            $heap->{client}->put($result);
        }
    },
);

POE::Kernel->run;
exit;
