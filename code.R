require(RJSONIO)
require(RColorBrewer)
require(rCharts)
options(stringsAsFactors = F)

toGeoJSON = function(list_){
  x = lapply(list_, function(l){
    list(
      type = 'Feature',
      geometry = list(
        type = 'Point',
        coordinates = c(l$longitude, l$latitude)
      ),
      properties = l[!(names(l) %in% c('latitude', 'longitude'))]
    )
  })
}

data_ = fromJSON('http://citibikenyc.com/stations/json', encoding = 'UTF-8')
bike = data_[[2]]
bike = bike[-13] # bad encoding
bike <- Filter(function(station) { station$statusValue == "In Service" }, bike)
bike2 <- lapply(bike, function(station){
  station$fillColor = if(station$totalDocks == 0){
    '#eeeeee'
  } else {
    cut(station$availableBikes/station$totalDocks, 
        breaks = c(0, 0.20, 0.40, 0.60, 0.80, 1), 
        labels = brewer.pal(5, 'RdYlGn'),
        include.lowest = TRUE
    ) 
  }
  station$popup = whisker::whisker.render('<b>{{station.stationName}}</b><br>
      <b>Total Docks: </b> {{station.totalDocks}} <br>
       <b>Available Bikes:</b> {{station.availableBikes}}
      <p>Retreived At: {{ time }}</p>', list(station = station, time = data_[[1]]))
  return(station)
})

L1 <- Leaflet$new()
L1$tileLayer(provider = 'Stamen.TonerLite')
L1$set(height = 800, width = 1600)
L1$setView(c(40.73, -73.99), 14)
L1$geoJson(toGeoJSON(bike2), 
  onEachFeature = '#! function(feature, layer){
    layer.bindPopup(feature.properties.popup)
  } !#',
  pointToLayer =  "#! function(feature, latlng){
    return L.circleMarker(latlng, {
      radius: 4,
      fillColor: feature.properties.fillColor || 'red',    
      color: '#000',
      weight: 1,
      fillOpacity: 0.8
    })
  } !#"
)
