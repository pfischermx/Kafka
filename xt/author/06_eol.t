#!/usr/bin/perl -w

#-- Pragmas --------------------------------------------------------------------

use 5.010;
use strict;
use warnings;

# ENVIRONMENT ------------------------------------------------------------------

use Test::More;

#-- verify load the module

BEGIN {
    eval 'use Test::NoWarnings';    ## no critic
    plan skip_all => 'because Test::NoWarnings required for testing' if $@;
}

#-- load the modules -----------------------------------------------------------

use Cwd qw(
    abs_path
);
use File::Spec::Functions qw(
    catdir
);

#-- setting up facilities ------------------------------------------------------

#-- declarations ---------------------------------------------------------------

my ( $modules_dir, $t_dir, $author_dir, $release_dir, $t_modules_dir, $tools_dir );

#-- Global data ----------------------------------------------------------------

$modules_dir    = abs_path( 'lib' );
$t_dir          = abs_path( 't' );
$author_dir     = abs_path( catdir( 'xt', 'author' ) );
$release_dir    = abs_path( catdir( 'xt', 'release' ) );
$t_modules_dir  = catdir( $t_dir, 'lib' );
$tools_dir      = abs_path( 'tools' );

# INSTRUCTIONS -----------------------------------------------------------------

eval { use Test::EOL; };
plan skip_all => 'because Test::EOL required for testing' if $@;

all_perl_files_ok(
    {
        trailing_whitespace => 1,
        all_reasons         => 1,
    },
    $modules_dir,
    $t_dir,
    $author_dir,
    $release_dir,
    $t_modules_dir,
    $tools_dir,
);

# POSTCONDITIONS ---------------------------------------------------------------
