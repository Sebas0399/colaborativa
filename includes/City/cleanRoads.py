import geopandas as gpd
from shapely.geometry import Point, LineString, MultiLineString

# Load the shapefile
road_network = gpd.read_file('includes/City/Cambridge/Roads.shp')

# Identify disconnected segments
disconnected_segments = []
for index, road in road_network.iterrows():
    if road.geometry.is_empty or not road.geometry.is_valid:
        disconnected_segments.append(index)

# Merge small disconnected segments
threshold_length = 100  # Adjust the threshold length as per your requirements
merged_segments = []
for index in disconnected_segments:
    segment = road_network.loc[index, 'geometry']
    nearest_segment = road_network.geometry.distance(segment).idxmin()
    if segment.length < threshold_length:
        if road_network.loc[nearest_segment, 'geometry'].is_valid:
            merged_segment = segment.union(road_network.loc[nearest_segment, 'geometry'])
            merged_segments.append(merged_segment)

# Remove isolated nodes or loose ends
loose_ends = []
for index, road in road_network.iterrows():
    if isinstance(road.geometry, LineString):
        start_point = Point(road.geometry.coords[0])
        end_point = Point(road.geometry.coords[-1])
        connected_segments = [
            geom for geom in road_network.geometry
            if (start_point.touches(geom) or end_point.touches(geom)) and geom.is_valid
        ]
        if not connected_segments:
            loose_ends.append(index)
    elif isinstance(road.geometry, MultiLineString):
        for line in road.geometry:
            start_point = Point(line.coords[0])
            end_point = Point(line.coords[-1])
            connected_segments = [
                geom for geom in road_network.geometry
                if (start_point.touches(geom) or end_point.touches(geom)) and geom.is_valid
            ]
            if not connected_segments:
                loose_ends.append(index)
                break

# Perform modifications on the road network
road_network.loc[merged_segments, 'geometry'] = merged_segments
road_network = road_network.drop(loose_ends)

# Validate and save the updated shapefile
road_network = road_network.reset_index(drop=True)
road_network.to_file('includes/City/Cambridge/updatedRoads.shp')
