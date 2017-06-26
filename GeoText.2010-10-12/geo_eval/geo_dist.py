## geopy has an insane bug??? not using
# import geopy.distance  ## Need to use Haversine algorithm on our data!!!!!!!!!!!!!!!!!!
# gcd = geopy.distance.GreatCircleDistance() #####  do not use this!!!!!!!!!

import math
from math import atan, tan, sin, cos, pi, sqrt, atan2, acos, asin

EARTH_RADIUS = 6372.795


###### http://blog.julien.cayzac.name/2008/10/arc-and-distance-between-two-points-on.html

# /// @brief The usual PI/180 constant
# static const double DEG_TO_RAD = 0.017453292519943295769236907684886;
# /// @brief Earth's quatratic mean radius for WGS-84
# static const double EARTH_RADIUS_IN_METERS = 6372797.560856;
# 
# /** @brief Computes the arc, in radian, between two WGS-84 positions.
#   *
#   * The result is equal to <code>Distance(from,to)/EARTH_RADIUS_IN_METERS</code>
#   *    <code>= 2*asin(sqrt(h(d/EARTH_RADIUS_IN_METERS )))</code>
#   *
#   * where:<ul>
#   *    <li>d is the distance in meters between 'from' and 'to' positions.</li>
#   *    <li>h is the haversine function: <code>h(x)=sin2(x/2)</code></li>
#   * </ul>
#   *
#   * The haversine formula gives:
#   *    <code>h(d/R) = h(from.lat-to.lat)+h(from.lon-to.lon)+cos(from.lat)*cos(to.lat)</code>
#   *
#   * @sa http://en.wikipedia.org/wiki/Law_of_haversines
#   */
# double ArcInRadians(const Position& from, const Position& to) {
#     double latitudeArc  = (from.lat - to.lat) * DEG_TO_RAD;
#     double longitudeArc = (from.lon - to.lon) * DEG_TO_RAD;
#     double latitudeH = sin(latitudeArc * 0.5);
#     latitudeH *= latitudeH;
#     double lontitudeH = sin(longitudeArc * 0.5);
#     lontitudeH *= lontitudeH;
#     double tmp = cos(from.lat*DEG_TO_RAD) * cos(to.lat*DEG_TO_RAD);
#     return 2.0 * asin(sqrt(latitudeH + tmp*lontitudeH));
# }

# /** @brief Computes the distance, in meters, between two WGS-84 positions.
#   *
#   * The result is equal to <code>EARTH_RADIUS_IN_METERS*ArcInRadians(from,to)</code>
#   *
#   * @sa ArcInRadians
#   */
# double DistanceInMeters(const Position& from, const Position& to) {
#     return EARTH_RADIUS_IN_METERS*ArcInRadians(from, to);
# }

DEG_TO_RAD = 0.017453292519943295769236907684886;

def ArcInRadians_haversine( (lat1,long1), (lat2,long2) ):
  latitudeArc  = (lat1 - lat2) * DEG_TO_RAD;
  longitudeArc = (long1 - long2) * DEG_TO_RAD;
  
  latitudeH = sin(latitudeArc * 0.5);
  latitudeH *= latitudeH;
  lontitudeH = sin(longitudeArc * 0.5);
  lontitudeH *= lontitudeH;
  tmp = cos(lat1*DEG_TO_RAD) * cos(lat2*DEG_TO_RAD);
  return 2.0 * asin(sqrt(latitudeH + tmp*lontitudeH));



def ArcInRadians_spherical_law((lat1,long1), (lat2,long2) ):
  lat1,long1,lat2,long2 = [math.radians(x) for x in (lat1,long1,lat2,long2)]
  return acos(sin(lat1)*sin(lat2) + 
                    cos(lat1)*cos(lat2) *
                    cos(long2-long1))
def dist(p1,p2):
  return EARTH_RADIUS * ArcInRadians_haversine(p1,p2)
  # return EARTH_RADIUS * ArcInRadians_spherical_law(p1,p2)
  
# print median([1,2,7])
# print median([1,2,7,9])
# print mean([1,2,7])
# print mean([1,2,7.9])
