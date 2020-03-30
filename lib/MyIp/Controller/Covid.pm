package MyIp::Controller::Covid;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(dumper);
use Mojo::CSV;
use Data::Dumper;

#date,location,new_cases,new_deaths,total_cases,total_deaths

sub latest {
    my $self = shift;
    my @dates;
    my @cases;
    my @total_cases;
    my @deaths;
    my @total_deaths;
    my @cases_growth_factor;
    my @cases_growth_percentage;

    my $ua = Mojo::UserAgent->new;
    $ua->max_redirects(10);

    #my $tx = $ua->get('https://cowid.netlify.com/data/full_data.csv');
    my $tx =
      $ua->get('https://covid.ourworldindata.org/data/ecdc/full_data.csv');

    #my $tx = $ua->get('https://covid.ourworldindata.org/data/full_data.csv');
    my $values  = $tx->res->body;
    my @csv     = split /\n/, $values;
    my @ireland = grep { /Ireland/ } @csv;
    my @china   = grep { /China/ } @csv;

    #date,location,new_cases,new_deaths,total_cases,total_deaths
    #2020-03-13,Ireland,27,0,70,1

    foreach my $line (@ireland) {
        chomp $line;
        my @fields = split ",", $line;
        push @dates,        $fields[0];    
        push @cases,        $fields[2];
        push @deaths,       $fields[3];
        push @total_cases,  $fields[4];
        push @total_deaths, $fields[5];
    }

    foreach my $daily_index ( 1 .. $#cases ) {

        #Start at 1 rather than 0 to max_index
        my $day_previous = $cases[ $daily_index - 1 ];
        if ( $day_previous == 0 ) {
            push @cases_growth_factor, 0;
        }
        else {
            push @cases_growth_factor, $cases[$daily_index] / $day_previous;
        }
    }

    foreach my $daily_index ( 1 .. $#cases ) {

        #Start at 1 rather than 0 to max_index
        my $cases_previous_total = $total_cases[ $daily_index - 1 ];
        if ( $cases_previous_total == 0 ) {
            push @cases_growth_percentage, 0;
        }
        else {
            push @cases_growth_percentage,
              $cases[$daily_index] / $cases_previous_total;
        }
    }

    my $entries = scalar(@ireland);
    my @answer;
    push @answer, myexp(135);

    my @uncontrolled_deaths;
    my $death_rate = 0.029;
    foreach (@answer) { push @uncontrolled_deaths, ( $_ * $death_rate ); }

    my @latest_values = split( ',', $ireland[ $entries - 1 ] );
    my $today = $latest_values[0];

    #my $today = "2020-04-01";
    my $latest_case_total  = $latest_values[4];
    my $latest_death_total = $latest_values[5];
    my @predicted_cases    = @total_cases;
    my @predicted_deaths   = @total_deaths;
    my @predicted_dates    = @dates;

    my $csv = Mojo::CSV->new( in => '/opt/mojo_full/lib/MyIp/Controller/china_covid_rates.csv' );
    while ( my $row = $csv->row ) {
        if ( $row->[0] gt $today ) {

            push @predicted_dates, $row->[0];
            $latest_case_total  = $latest_case_total * $row->[1];
            $latest_death_total = $latest_death_total * $row->[2];
            push @predicted_cases,  $latest_case_total;
            push @predicted_deaths, $latest_death_total;
        }    # Read row-by-row
    }

    #
    my @predicted_new_cases;
    for ( my $j = 1 ; $j <= $#predicted_cases ; $j++ ) {
        push @predicted_new_cases,
          ( $predicted_cases[$j] - $predicted_cases[ $j - 1 ] );
    }
    #
    sub myexp {
        my $no_exposed     = 2.8;
        my $prob_infection = 1;
        my $days           = $_[0];
        my @uncontrolled_cases;
        my @uncontrolled_deaths;
        
        for ( my $i = 0 ; $i < 75 ; $i++ ) {
            push @uncontrolled_cases, 0;
        }

        for ( my $i = 1 ; $i < ( $days - 75 ) ; $i++ ) {
            #129 is the number of cases record on the 15th of March
            push @uncontrolled_cases, ( 129 * exp( 0.23 * $i ) );
        }
        return @uncontrolled_cases;
    }

#rows x columns - array of anon arrays.
    my @table = (
        \@predicted_dates,     \@cases,
        \@deaths,              \@total_cases,
        \@total_deaths,        \@predicted_cases,
        \@predicted_deaths,    \@answer,
        \@uncontrolled_deaths, \@predicted_new_cases,
        \@cases_growth_factor, \@cases_growth_percentage
    );
    $self->stash( results => \@table );
    $self->render( template => 'covid19' );
}

1;

