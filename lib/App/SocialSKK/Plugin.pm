package App::SocialSKK::Plugin;
use strict;
use warnings;
use base qw(App::SocialSKK::Base);
use LWP::UserAgent::POE;

__PACKAGE__->mk_accessors(qw(_ua ua_options));

sub get_candidates {
    die 'This method must be overridden by subclass';
}

sub ua {
    my $self = shift;
    my %ua_options = ref $self->ua_options eq 'HASH' ? %{$self->ua_options} : ();
    $self->_ua ||= LWP::UserAgent::POE->new(%ua_options);
}

1;

__END__

=head1 NAME

App::SocialSKK::Plugin - Baseclass of Social SKK Plugins

=head1 SYNOPSIS

  package App::SocialSKK::Plugin::YourPlugin;
  use strict;
  use warnings;
  use base qw(App::SocialSKK::Plugin);

  sub get_candidates {
      my ($self, $text) = @_;
      my $res = $self->ua->get('http://example.com/');
      if ($res->is_success) {
          my @candidates;

          # Do some formatting against $res->content and push results
          # into @candidates

          return @candidates;
      }
  }

  1;

  # Then, add a line like below into your .socialskk:
  plugins:
    - name: YourPlugin

=head1 DESCRIPTION

App::SocialSKK::Plugin is a baseclass of Social SKK plugins. It offers
get_candidates() interface and built-in useragent object to retrieve
some data from the Web.

=head1 METHODS

=head2 nwe ( I<\%config> )

=over 4

  my $plugin = App::SocialSKK::Plugin::YourPlugin->new({
      ua_options  => {
          timeout => 5,
          agent   => 'App::SocialSKK::Plugin::YourPlugin',
      },
  });

Takes a EUC-JP string as an input and processes and returns candidates
for the string.

This method must be overridden by subclass.

=back

=head2 get_candidates ( I<$text> )

=over 4

  my @candidates = $plugin->get_candidates($text);

Takes a EUC-JP string as an input and processes and returns candidates
for the string.

This method must be overridden by subclass.

=back

=head2 ua ()

=over 4

  # In your plugin:
  my $res = $self->ua->get('http://example.com/');

Returns LWP::UserAgent::POE object for non-blocking network
retrieval. You can use it to do with the data on the Web.

=back

=head1 SEE ALSO

=over 4

=item * LWP::UserAgent::POE

=item * App::SocialSKK::Plugin::SocialIME

=item * App::SocialSKK::Plugin::Wikipedia

=back

=head1 AUTHOR

Kentaro Kuribayashi E<lt>kentaro@cpan.orgE<gt>
