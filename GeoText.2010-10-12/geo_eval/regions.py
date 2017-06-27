# www.census.gov/geo/www/us_regdiv.pdf
CensusDivisions = (
('PACIFIC', 'AK HI  WA OR CA'.split()),
('MOUNTAIN', 'MT ID WY NV UT CO AZ NM'.split()),
('WN_CENTRAL', 'ND SD MN NE IA KS MO'.split()),
('EN_CENTRAL', 'WI MI IL IN OH'.split()),
('WS_CENTRAL', 'OK AR TX LA'.split()),
('ES_CENTRAL', 'KY TN MS AL'.split()),
('S_ATLANTIC', 'FL GA SC NC VA WV DC MD DE'.split()),
('M_ATLANTIC', 'NY PA NJ'.split()),
('NEW_ENGLAND', 'ME NH VT MA CT RI'.split()),
)


StateDivision = {}
for div,states in CensusDivisions:
  for state in states:
    assert state not in StateDivision
    StateDivision[state] = div

## Check: postal codes from http://en.wikipedia.org/wiki/U.S._state
all_states = "AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY".split()
all_states += ['DC']
assert len(all_states) == 51
assert set(all_states) == set(StateDivision.keys())


DivisionRegion = dict((
('PACIFIC', 'WEST'),
('MOUNTAIN', 'WEST'),
('WN_CENTRAL', 'MIDWEST'),
('EN_CENTRAL', 'MIDWEST'),
('WS_CENTRAL', 'SOUTH'),
('ES_CENTRAL', 'SOUTH'),
('S_ATLANTIC', 'SOUTH'),
('M_ATLANTIC', 'NORTHEAST'),
('NEW_ENGLAND', 'NORTHEAST'),
))

StateRegion = dict(((state, DivisionRegion[div]) for state,div in StateDivision.items()))