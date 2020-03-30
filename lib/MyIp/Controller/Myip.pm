package MyIp::Controller::Myip;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub input_ip {
  my $self = shift;
  # Render template "myip/input_ip.html.ep
  $self->render;
}
sub sipcalc {
  my $c    = shift;
  my $prefix = $c->param('prefix');
  my $netmask = $c->param('net');
  my $result = `sipcalc $prefix/$netmask`;
  $c->stash (results => "$result");
  $c->render(template => 'myip/results');
};

sub ipcalc {
  my $c    = shift;
  my $prefix = $c->param('prefix');
  my $netmask = $c->param('net');
  my $result = `ipcalc $prefix/$netmask`;
  $c->stash (results => "$result");
  $c->render(template => 'myip/results');
};

1;
