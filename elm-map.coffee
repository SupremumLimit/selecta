mapboxgl.accessToken = '***REMOVED***'

map = undefined 
mapIsReady = false

initMap = ->
    map = new mapboxgl.Map
      container: "map"
      style: "mapbox://styles/mapbox/streets-v8"
      center: [
        -74.50
        40
      ]
      zoom: 9
    map.on "style.load", =>
        map.addSource "markers"
        , type: "geojson", data: {type: "FeatureCollection", features: []}
        
        map.addLayer
            "id": "markers",
            "type": "symbol",
            "source": "markers",
            "layout": 
                "icon-image": "monument-15",
                "text-field": "{title}",
                "text-font": ["Open Sans Semibold", "Arial Unicode MS Bold"],
                "text-offset": [0, 0.6],
                "text-anchor": "top"
        mapIsReady = true
        console.log "Map is ready"

elmApp.ports.mapData.subscribe (model) ->
    console.log "mapData model: ", model
    initMap() if !map?
    
    if mapIsReady 
        console.log "Setting data to", model["0"]
        map.getSource("markers").setData model["0"]
        console.log "Setting centre to", model["0"].features[0].geometry.coordinates[0] 
        map.setCenter model["0"].features[0].geometry.coordinates 

    # if mapIsReady
    #     features = R.map (o) ->
    #         type: o.type_
    #         geometry:
    #             type: o.geometry.type_
    #             coordinates: o.geometry.coordinates
    #         properties:
    #             title: o.properties.title
    #             "marker-symbol": o.properties.markerSymbol
    #     , model.markers
    #     map.getSource("markers").setData {type: "FeatureCollection", features: features}
    #
    #
