import geo_dist
# msa=read_nns("../geo_metro/lat_long_pop_msa.tsv",col.names=c('lat','long','pop','msa'))

metro_areas = []
for line in open("../geo_metro/lat_long_pop_msa.tsv"):
  lat,long,pop,name = line[:-1].split("\t")
  metro_areas.append({'latlong':(float(lat), float(long)),  'name': name, 'pop': pop} )


def closest(lat,long, K = 25):
  K = K or len(metro_areas)
  K = min(K, len(metro_areas))
  inds = range(K)    
  inds.sort(key= lambda i: geo_dist.dist(metro_areas[i]['latlong'], (lat,long)))
  return metro_areas[inds[0]]['name']