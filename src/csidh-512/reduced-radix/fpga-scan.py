# Copyright (C) 2021 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which 
# can be found at https://opensource.org/licenses/MIT (or should be included 
# as LICENSE.txt within the associated archive or repository).

import driver, itertools

# =============================================================================

def rv32( args ) :
  pass

# -----------------------------------------------------------------------------

def rv64( args ) :
  if ( args.prog ) :
    driver.program_fpga( args, 'rv64', 'csidh-512', 'reduced' )

  for TYPE in [ 'RV64_TYPE1', 'RV64_TYPE2', 'RV64_TYPE3' ] :
    driver.run( args, 'rv64', 'csidh-512', 'reduced', TYPE, '' )
# -----------------------------------------------------------------------------

if ( __name__ == '__main__' ) :
  driver.main( rv32, rv64 )

# =============================================================================
