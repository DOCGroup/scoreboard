# DOCGroup scoreboard configuration files

## Adding to the scoreboard

Edit one of the xml files in this repository to add builds to the
[DOCGroup](https://github.com/DOCGroup) scoreboard. These xml files will be used to generate
the [DOCGroup scoreboard](https://www.dre.vanderbilt.edu/scoreboard/).

## Running locally

To run locally, run `naboo_dre.sh` with these environment variables:

1. `AUTOBUILD_ROOT` - Path to [autobuild](https://github.com/DOCGroup/autobuild) to use.
1. `OUTPUT` - Path to destination of the web site.

Otherwise they default to hardcoded paths that you probably don't want to use.
