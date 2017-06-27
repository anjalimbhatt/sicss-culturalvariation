import sys,re,sqlalchemy   ## also needs psycopg2
db = sqlalchemy.create_engine("postgresql://localhost/geo")

def geonames_city_lookup(lat,long, forceUS=False):  
  # This approach of filter-then-sort is a really dumb approach.
  # Instead we should just do one pass looking for the argmin

  def filter_q(delta):
    d=delta
    lat1,lat2 = lat-d,lat+d
    long1,long2= long-d,long+d
    return """
    select * from geoname 
    where box(latlong,latlong) && '(({lat1},{long1}),({lat2},{long2}))'::box
    """.format(**locals())
  
  countries = "('US')" if forceUS else ('US','CA','MX')
  final_sql = """
  where country in {countries}
  order by (latlong <-> point({lat},{long})) 
  limit 1  
  """.format(**locals())
  
  fq = filter_q(0.1)
  sql = "select * from ({fq}) q  {final_sql}".format(**locals())
  res = list(db.execute(sql))
  if res: return res[0]
  # print>>sys.stderr,"fallback"
  fq = filter_q(10)
  sql = "select * from ({fq}) q  {final_sql}".format(**locals())
  res = list(db.execute(sql))
  if res: return res[0]
  # print>>sys.stderr,"fallback2"
  
  sql = "select * from geoname {final_sql}".format(**locals())
  return list(db.execute(sql))[0]

#print lookup(34.88369804,-82.45685237)

def county_lookup(lat,long, strict=False):
  # Adapted from http://www.macgeekery.com/hacks/software/using_postgis_reverse_geocode
  # The bounding box has to deal with crazy crappy predictions and such...
  query_geom = "setsrid(makepoint({long}, {lat}), 4269)".format(**locals())
  def q_with_bb(box_size):
      #AND
      #distance(the_geom, {query_geom}) < {box_size}
    return """
    SELECT statefp,name from "2008_us_county" 
    WHERE
      (the_geom && expand({query_geom}, {box_size}))
    ORDER BY
      distance(the_geom, {query_geom})
    ASC
    LIMIT 1
    """.format(query_geom=query_geom, box_size=box_size)

  #q = """select name,statefp from "2008_us_county" 
  #where (the_geom && expand(setsrid(makepoint(-97.699858, 30.422627), 4269), 1) ) limit 25"""
  for size in (.01,) if strict else (.01, 1, 10):
    res = list(db.execute(q_with_bb(1)))
    if len(res) > 0: break
  if not res: return None
  return res[0]

StatesWithZCTATables = set(m.group(1) for m in [re.search(r'zt(\d\d)_',t) for t in db.table_names()] if m)

def zcta_lookup(lat,long):
  query_geom = "setsrid(makepoint({long}, {lat}), 4269)".format(**locals())
  box_size = .01

  state_q = """
    SELECT statefp from "2008_us_county" 
    WHERE
      (the_geom && expand({query_geom}, {box_size}))
    ORDER BY
      distance(the_geom, {query_geom})
    ASC
    LIMIT 1
  """.format(**locals())

  # First get the state
  res = list(db.execute(state_q))
  if not res: return None

  statefp = res[0].statefp
  if statefp not in StatesWithZCTATables: return None

  # Now the ZCTA in that state's ZCTA table
  zcta_q = """
  SELECT A.zcta  
  FROM zt{statefp}_d00 A
    JOIN zcta_info B ON (B.pop_total > 1000 AND A.zcta=B.zcta)
  WHERE
    (the_geom && expand({query_geom}, {box_size}))
  ORDER BY
    distance(the_geom, {query_geom})
  ASC
  LIMIT 1
  """.format(**locals())

  res = list(db.execute(zcta_q))
  if not res:
    print "HAS COUNTY BUT NOT ZCTA"
    return None
  return res[0].zcta
  
####################################

if __name__=='__main__':
  for line in sys.stdin:
    username,lat,long = line[:-1].split("\t")
    lat=float(lat); long=float(long)
    #rec = lookup(lat,long)
    #print username, (lat,long), county_lookup(lat,long)
    #print username, (lat,long), zcta_lookup(lat,long)
    #print username,lat,long
    zcta = zcta_lookup(lat,long)
    print "OUT",username, lat, long, zcta
  
    #sys.stderr.write(".")
    #print "{username}\\t{rec.country}\\t{rec.admin1}".format(**locals())

