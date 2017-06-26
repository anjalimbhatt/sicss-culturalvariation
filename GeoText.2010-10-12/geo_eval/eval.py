# You give this real and predicted locations, and it returns mean/median
# physical distance errors, as well as state- and region-level classification
# accuracies.  Note that it won't run out-of-the-box because it needs a PostGIS
# database with a bunch of Census shapefiles loaded up in order to do the
# classification stuff.
# Just use geo_dist.py if you just want distance evaluation.
from __future__ import division
from collections import defaultdict
import sys
#sys.stdout = open('/dev/stdout','w',0)

from stats import mean,medianscore
import geo_dist, regions
# import metro

do_class_eval = '-n' not in sys.argv
if do_class_eval:
  import reverse_geocode
  

# FILE = "/Users/boconnor/twi/geo/GeoTM/data/usa_11k_dc_thresh/user_info.state"
  
dists = []
corrects = defaultdict(list)

for line in sys.stdin:
  sys.stderr.write('.')
  lat1,long1, lat2,long2 = [float(x) for x in line.split()]
  km = geo_dist.dist((lat1,long1),(lat2,long2))
  dists.append(km)
  
  ## loc1 is REAL location,
  ## loc2 is PREDICTED location.
  
## DEPRECATED -- using geonames nearest-city lookup {{{
  #loc1 = reverse_geocode.geonames_city_lookup(lat1,long1)
  #if loc1.country != 'US':
  #  print>>sys.stderr, "skipping non-US loc1"
  #  continue
  #loc2 = reverse_geocode.geonames_city_lookup(lat2,long2, forceUS = True)

  #div1 = regions.StateDivision.get(loc1.admin1, "WTF_"+loc1.admin1)
  #div2 = regions.StateDivision.get(loc2.admin1, "WTF_"+loc2.admin1)
  #region1 = regions.StateRegion.get(loc1.admin1, "WTF_"+loc1.admin1)
  #region2 = regions.StateRegion.get(loc2.admin1, "WTF_"+loc2.admin1)
  #
  #metro1 = metro.closest(lat1,long1)
  #metro2 = metro.closest(lat2,long2)
  #
  #print "{km}\\t{loc1.admin1}\\t{loc2.admin1}\\t{region1}\\t{region2}\\t{div1}\\t{div2}\\t{metro1}\\t{metro2}".format(**locals())
## }}}
  

  ## Do the county lookup via boundary database


  loc1 = reverse_geocode.county_lookup(lat1, long1, strict=True)
  if not loc1:
    print>>sys.stderr, "no county for real loc %s,%s " % (lat1,long1)
    continue
  loc2 = reverse_geocode.county_lookup(lat2, long2, strict=True)
  state2 = None
  if loc2 is None:
    print>>sys.stderr, "no county for prediction %s,%s" % (lat2,long2)
    state2 = "WTF"

  import state_codes
  state1 = state_codes.fips2postal[loc1.statefp]
  state2 = state2 or state_codes.fips2postal[loc2.statefp]
  region1 = regions.StateRegion.get(state1, "WTF")
  region2 = regions.StateRegion.get(state2, "WTF")
  
  corrects['state'].append( int(state1 == state2) )
  #corrects['div'].append( int(div1 == div2) )
  corrects['region'].append( int(region1 == region2) )
  #corrects['metro'].append( int(metro1==metro2) )

  print "\t".join(str(x) for x in [km,state1,state2, region1, region2])

print "--"
print "mean_dist_km %f" % mean(dists)
print "med_dist_km %f" % medianscore(dists)
print "state_acc %f" % mean(corrects['state'])
#print "div_acc %f" % mean(corrects['div'])
print "region_acc %f" % mean(corrects['region'])
# print "metro_acc %f" % mean(corrects['metro'])



# vim:foldmethod=marker
