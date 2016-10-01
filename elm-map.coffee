mapboxgl.accessToken = '***REMOVED***'

window.map = undefined 
mapIsReady = false

initMap = ->
    window.map = new mapboxgl.Map
      container: "map"
      style: "mapbox://styles/mapbox/streets-v8"
      center: [
        -74.50
        40
      ]
      zoom: 9
    map.on "style.load", =>
        map.addSource "queryResults"
        , type: "geojson", data: {type: "FeatureCollection", features: []}
        
        map.addLayer
            "id": "markers"
            "type": "symbol"
            "source": "queryResults"
            "layout": 
                "icon-image": "monument-15"
                "text-field": "{title}"
                "text-font": ["Open Sans Semibold", "Arial Unicode MS Bold"]
                "text-offset": [0, 0.6]
                "text-anchor": "top"
                
        map.addLayer
            "id": "polygons"
            "type": "fill"
            "source": "queryResults"
            "layout": {}
            "paint": 
                "fill-color": "#088"
                "fill-opacity": 0.8
                
        mapIsReady = true
        console.log "Map is ready"

initMap()

elmApp.ports.mapData.subscribe (model) ->
    console.log "mapData model: ", model
    if mapIsReady 
        console.log "Setting data to", model["0"]
        map.getSource("queryResults").setData model["0"]
        console.log "Setting centre to", model["0"].features[0].geometry.coordinates
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
