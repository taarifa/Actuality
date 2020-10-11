'use strict'

angular.module('actualityApp')

  .factory 'ApiResource', ($resource, $http, flash) ->
    (resource, args) ->
      Resource = $resource "/api/#{resource}/:id"
      , # Default arguments
        args
      , # Override methods
        query:
          method: 'GET'
          isArray: false
      Resource.update = (id, data) ->
        # We need to remove special attributes starting with _ since they are
        # not defined in the schema and the data will not validate and the
        # update be rejected
        putdata = {}
        for k, v of data when k[0] != '_'
          putdata[k] = v
        $http.put("/api/#{resource}/"+id, putdata,
                  headers: {'If-Match': data._etag})
        .success (res, status) ->
          if status == 200 and res._status == 'OK'
            flash.success = "#{resource} successfully updated!"
            data._etag = res._etag
          if status == 200 and res._status == 'ERR'
            for field, message of res._issues
              flash.error = "#{field}: #{message}"
      Resource.patch = (id, data, etag) ->
        $http
          method: 'PATCH'
          url: "/api/#{resource}/"+id
          data: data
          headers: {'If-Match': etag}
      return Resource

  .factory 'Facility', (ApiResource) ->
    ApiResource 'facilities'

  .factory 'Vehicle', (ApiResource) ->
    ApiResource 'vehicles'

  .factory 'Movement', (ApiResource) ->
    ApiResource 'movements'

  .factory 'Map', ($filter) ->
    (id, opts) =>

      defaults =
        markerType: "regular"
        heatmap: false
        showScale: false

      options = _.extend(defaults, opts)

      osmLayer = L.tileLayer(
        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        attribution: '(c) OpenStreetMap')

      satLayer = L.tileLayer(
        'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        attribution: '(c) Esri')

      baseMaps =
        "Open Street Map": osmLayer
        "Satellite": satLayer

      overlays = {}

      markerLayer = L.featureGroup()

      overlays.Routes = markerLayer
      defaultLayers = [osmLayer, markerLayer]

      if options.heatmap
        heatmapLayer = new HeatmapOverlay
          radius: 15
          maxOpacity: .7
          scaleRadius: false
          useLocalExtrema: true

        overlays["Routes Heatmap"] = heatmapLayer

        # we add the heatmap layer by default
        defaultLayers.push(heatmapLayer)

      map = L.map id,
        # Gitega, Burundi
        center: new L.LatLng -3.4314318, 29.9254274
        zoom: 5
        fullscreenControl: true
        layers: defaultLayers

      if options.heatmap
        # FIXME: remove the heatmap layer again to workaround
        # https://github.com/pa7/heatmap.js/issues/130
        map.removeLayer(heatmapLayer)

      # add a layer selector
      layerSelector = L.control.layers(baseMaps, overlays).addTo(map)

      # add a distance scale
      if options.showScale
        scale = L.control.scale().addTo(map)

      makePopup = (mv) ->
        cleanKey = (k) ->
          $filter('titlecase')(k.replace("_"," "))

        cleanValue = (k,v) ->
          if v instanceof Date
            v.getFullYear()
          else if k == "location"
            v.coordinates.toString()
          else
            v

        header = '<h5>Vehicle ' + mv.license_plate + ' (<a href="#/movements/' + mv._id + '">Edit</a>)</h5>' +
                 '<span class="popup-key">Status</span>: ' + mv.status + '<br />' +
                 '<a href="#/movements/?license_plate=' + mv.license_plate + '">Show movements</a> | ' +
                 '<a href="#/movements/new?license_plate=' + mv.license_plate + '">Submit report</a>' +
                 '<hr style="margin-top:10px; margin-bottom: 10px;" />'

        # FIXME: can't this be offloaded to angular somehow?
        fields = _.keys(mv).sort().map((k) ->
            '<span class="popup-key">' + cleanKey(k) + '</span>: ' +
            '<span class="popup-value">' + String(cleanValue(k,mv[k])) + '</span>'
          ).join('<br />')

        html = '<div class="popup">' + header + fields + '</div>'

      @clearMarkers = () ->
        markerLayer.clearLayers()

      # FIXME: more hardcoded statusses
      makeAwesomeIcon = (status) ->
        if status == 'legitimate'
          color = 'green'
        else if status == 'illegal'
          color = 'red'
        else
          color = 'black'

        icon = L.AwesomeMarkers.icon
          prefix: 'glyphicon',
          icon: 'tint',
          markerColor: color

      makeMarker = (mv) ->
        [lng,lat] = mv.location.coordinates
        mt = options.markerType

        if mt == "circle"
          m = L.circleMarker L.latLng(lat,lng),
            stroke: false
            radius: 5
            fillOpacity: 1
            fillColor: {legitimate: 'green', illegal: 'red', unknown: 'black'}[mv.status]
        else
          m = L.marker L.latLng(lat,lng),
              icon: makeAwesomeIcon(mv.status)

      @addMovements = (mvs) ->
        mvs.forEach (mv) ->
          [lng,lat] = mv.location.coordinates

          m = makeMarker(mv)
          popup = makePopup(mv)
          m.bindPopup popup
          markerLayer.addLayer(m)

        if options.coverage
          coords = mvs.map (x) -> [x.location.coordinates[1], x.location.coordinates[0]]
          coverageLayer.setData coords

        if options.heatmap
          costMap =
            unknown: 0
            legitimate: -1
            illegal: 1

          coords = []
          mvs.forEach (x) ->
            coords.push
              lat: x.location.coordinates[1]
              lng: x.location.coordinates[0]
              value: costMap[x.status]

          heatmapLayer.setData 
            data: coords

      @zoomToMarkers = () ->
        bounds = markerLayer.getBounds()
        if bounds.isValid()
          map.fitBounds(bounds)

      return this

  # Get an angular-dynamic-forms compatible form description from a Facility
  # given a facility code
  .factory 'FacilityForm', (Facility) ->
    (facility_code) ->
      Facility.get(where: {facility_code: facility_code})
        # Return a promise since dynamic-forms needs the form template in
        # scope when the controller is invoked
        .$promise.then (facility) ->
          mkfield = (type, label, step) ->
            type: type
            label: label
            step: step
            class: "form-control"
            wrapper: '<div class="form-group"></div>'
          fields = {}
          for f, v of facility._items[0].fields
            if v.type == 'point'
              fields.longitude = mkfield 'number', 'longitude', 'any'
              fields.latitude = mkfield 'number', 'latitude', 'any'
              fields.longitude.model = 'location.coordinates[0]'
              fields.latitude.model = 'location.coordinates[1]'
            else
              # Use the field name as label if no label was specified
              fields[f] = mkfield v.input || v.type, v.label || f
              if v.type in ['float', 'number']
                fields[f].step = 'any'
              if v.allowed?
                fields[f].type = 'select'
                options = {}
                options[label] = label: label for label in v.allowed
                fields[f].options = options
          fields.submit =
            type: "submit"
            label: "Save"
            class: "btn btn-primary"
          return fields

  .factory 'FacilityCreate', (FacilityForm, Map, flash, geolocation, $location) ->
    (scope, facility, facility_code, name) ->
      scope.formTemplate = FacilityForm facility_code

      d = new Date()
      d.setSeconds(0)
      d.setMilliseconds(0)
      scope.form =
        facility_code: facility_code
        date_recorded: d
      _.extend(scope.form, $location.search())

      geolocation.getLocation().then (data) ->
        flash.success = "Geolocation succeeded: got coordinates" + " #{data.coords.longitude.toPrecision(4)}, #{data.coords.latitude.toPrecision(4)}"
        scope.form.location = coordinates: [data.coords.longitude, data.coords.latitude]
        map = Map("editMap", {})
        map.clearMarkers()
        map.addMovements([scope.form])
        map.zoomToMarkers()
      , (reason) ->
        flash.error = "Geolocation failed:" + " #{reason}"
      scope.save = () ->
        form = {}
        for k, v of scope.form
          if v != null
            form[k] = if v instanceof Date then v.toGMTString() else v
            if v.coordinates
              form[k].type = 'Point'
        console.log form
        facility.save form, (f) ->
          if f._status == 'OK'
            console.log "Successfully created #{name}", f
            flash.success = "#{name} successfully created!"
          if f._status == 'ERR'
            console.log "Failed to create #{name}", f
            for field, message of f._issues
              flash.error = "#{field}: #{message}"

  .factory 'FacilityEdit', (FacilityForm, Map, $routeParams) ->
    (scope, facility, facility_code) ->
      map = Map("editMap", {})

      facility.get id: $routeParams.id, (f) ->
        # We are editing a facility so set the date_recorded
        # field to today, should it be saved.
        d = new Date()
        d.setSeconds(0)
        d.setMilliseconds(0)
        f.date_recorded = d

        scope.form = f
        map.clearMarkers()
        map.addMovements([f])
        map.zoomToMarkers()

      scope.formTemplate = FacilityForm facility_code
      scope.save = () ->
        for f of scope.form
          if scope.form[f] instanceof Date
            scope.form[f] = scope.form[f].toGMTString()
        facility.update(id, scope.form)
