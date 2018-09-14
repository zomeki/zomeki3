var OpenLayersEditor = function(id, source, latitude, longitude, map_zoom) {
  if (source == "webtis") {
    var base = new ol.layer.Tile({
      source: new ol.source.XYZ({
        attributions: "<a href='https://maps.gsi.go.jp/development/ichiran.html' target='_blank'>国土地理院</a>",
        url: "//cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png",
        projection: "EPSG:3857"
      })
    });
  } else {
    var base = new ol.layer.Tile({
      source: new ol.source.OSM(),
      type: 'base'
    });
  }
  var container = document.getElementById('popup');
  container.style.display = 'block';
  var content = document.getElementById('popup-content');
  var closer = document.getElementById('popup-closer');
  var popoverlay = new ol.Overlay({
    element: container,
    autoPan: true,
    autoPanAnimation: {
      duration: 250
    }
  });
  this._content = content;
  this._popoverlay = popoverlay;

  closer.onclick = function() {
    popoverlay.setPosition(undefined);
    closer.blur();
    return false;
  };

  this._map_canvas = new ol.Map({
    target: id,
    view: new ol.View({
      center: ol.proj.fromLonLat([longitude, latitude]),
      zoom: map_zoom,
      maxZoom: 18
    }),
    overlays: [popoverlay],
    layers: [base],
    controls: ol.control.defaults({
      attributionOptions: {
        collapsible: false
      }
    })
  });

  this._map_canvas.addControl(new ol.control.ScaleLine());
  this._map_canvas.addControl(new ol.control.ZoomSlider());
  this._map_canvas.addControl(new ol.control.FullScreen());

  var click_style = new ol.style.Style({
    image: new ol.style.Icon({
      anchor: [0.5, 1],
      anchorXUnits: 'fraction',
      anchorYUnits: 'fraction',
      opacity: 0.75,
      src: '/_common/themes/openlayers/images/marker-blue.png'
    })
  });
  var click_feature = new ol.Feature();
  click_feature.setStyle(click_style);
  this._click_feature = click_feature;

  this._map_canvas.on('moveend', function(e) {
    var map = e.map;
    var center = map.getView().getCenter();
    center = ol.proj.transform(center, "EPSG:3857", "EPSG:4326");
    var zoom = map.getView().getZoom();
    $("#centerDispLat").val(center[1]);
    $("#centerDispLng").val(center[0]);
    $("#zoomDisp").val(zoom);

    document.getElementById('centerDispLat').value = center[1];
    document.getElementById('centerDispLng').value = center[0];
    document.getElementById('zoomDisp').value = zoom;
  });
}

OpenLayersEditor.prototype.create_markers = function(markers) {
  var position_features = [this._click_feature];
  var marker_style = new ol.style.Style({
    image: new ol.style.Icon({
      anchor: [0.5, 1],
      anchorXUnits: 'fraction',
      anchorYUnits: 'fraction',
      opacity: 0.75,
      src: '/_common/themes/openlayers/images/marker.png'
    })
  });

  this._marker_style = marker_style;
  this._marker_features = {};

  for (var i = 0; i < markers.length; i++) {
    var marker = markers[i];
    var feature = new ol.Feature();
    feature.setProperties({
      'id': marker.id,
      'content': marker.content
    });
    feature.setStyle(marker_style);
    var coordinates = ol.proj.transform([marker.lng, marker.lat], "EPSG:4326", "EPSG:3857");
    feature.setGeometry(new ol.geom.Point(coordinates));
    position_features.push(feature);
    this._marker_features[marker.id] = feature;
  }

  var point_layer = new ol.layer.Vector({
    map: this._map_canvas,
    source: new ol.source.Vector({
      features: position_features
    })
  });
  this._point_layer = point_layer;
  this._map_canvas.addLayer(point_layer);

  this._position_features = position_features;

  var _this = this;
  this._map_canvas.on('click', function(e) {
    var iconFeatureA = e.map.getFeaturesAtPixel(e.pixel);
    if (iconFeatureA !== null) {
      var selected = iconFeatureA[0];
      var coordinate = selected.getGeometry().getCoordinates();
      _this._content.innerHTML = selected.get('content');
      _this._popoverlay.setPosition(coordinate);
      _this._map_canvas.getView().setCenter(coordinate);
    } else {
      var coordinates = ol.proj.transform(e.coordinate, "EPSG:3857", "EPSG:4326");
      document.getElementById('clickDispLat').value = coordinates[1];
      document.getElementById('clickDispLng').value = coordinates[0];
      _this._click_feature.setGeometry(new ol.geom.Point(e.coordinate));
    }
  });
}

OpenLayersEditor.prototype.set_map_info = function(name) {
  var lat = document.getElementById('centerDispLat').value;
  var lng = document.getElementById('centerDispLng').value;
  var zoom = document.getElementById('zoomDisp').value;
  if (lat == '' || lng == '' || zoom == '') {
    alert("現在の縮尺と座標が取得できません。");
    return;
  }
  document.getElementById(name + 'Lat').value = lat;
  document.getElementById(name + 'Lng').value = lng;
  document.getElementById(name + 'Zoom').value = zoom;
}

OpenLayersEditor.prototype.set_marker = function(name) {
  var lat = document.getElementById('clickDispLat').value;
  var lng = document.getElementById('clickDispLng').value;
  if (lat == '' || lng == '') {
    alert("座標を指定してください。");
    return;
  }
  var title = document.getElementById(name + 'Name').value;

  document.getElementById(name + 'Lat').value = lat;
  document.getElementById(name + 'Lng').value = lng;
  var coordinates = ol.proj.transform([parseFloat(lng), parseFloat(lat)], "EPSG:4326", "EPSG:3857");
  var point = new ol.geom.Point(coordinates);
  if (this._marker_features[name] != null) {
    this._marker_features[name].getGeometry().setCoordinates(coordinates);
  } else {
    var feature = new ol.Feature();
    feature.setProperties({
      'id': name,
      'content': title
    });
    feature.setStyle(this._marker_style);
    feature.setGeometry(point);
    this._point_layer.getSource().addFeature(feature);
    this._marker_features[name] = feature;
  }
}

OpenLayersEditor.prototype.unset_marker = function(name) {
  document.getElementById(name + 'Name').value = '';
  document.getElementById(name + 'Lat').value = '';
  document.getElementById(name + 'Lng').value = '';
  if (this._marker_features[name]) {
    this._point_layer.getSource().removeFeature(this._marker_features[name]);
    this._marker_features[name] = null;
  }
}