package MyIp;
use Mojo::Base 'Mojolicious';


# This method will run once at server start
sub startup {
  my $self = shift;
  #This will be kicked off when the server starts but will keep going for ever. 
  #It is useful for testing. 
  #my $count = 0;
  #Mojo::IOLoop->recurring(1 => sub {
  #  $self->app->log->info('My continuous Count: ' . $count++);
  #});

  # Router
  my $r = $self->routes;

  # Normal route to controller Controller name and subroutine name
  $r->get('/ip')->to(controller => 'myip', action => 'input_ip');
  $r->get('/sipcalc')->to('myip#sipcalc');
  $r->get('/ipcalc')->to('myip#ipcalc');
  $r->get('/')->to('example#welcome');
  $r->get('/covid')->to(controller =>'covid', action => 'latest');

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');
}

1;

