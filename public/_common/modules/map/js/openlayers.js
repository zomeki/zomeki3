var OpenLayersViewer = function(id, source, latitude, longitude, zoom, latitude2, longitude2) {
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
      zoom: (zoom || 12),
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

  if (latitude2 != undefined || longitude2 != undefined) {
    var extent = [longitude, latitude, longitude2, latitude2];
    extent = ol.extent.applyTransform(extent, ol.proj.getTransform("EPSG:4326", "EPSG:3857"));
    this._map_canvas.getView().fit(extent, this._map_canvas.getSize());
  }

}

OpenLayersViewer.prototype.create_markers = function(markers) {
  var position_features = [];
  var default_style = new ol.style.Style({
    image: new ol.style.Icon({
      anchor: [0.5, 1],
      anchorXUnits: 'fraction',
      anchorYUnits: 'fraction',
      opacity: 0.75,
      src: '/_common/themes/openlayers/images/marker.png'
    })
  });

  for (var i = 0; i < markers.length; i++) {
    var marker = markers[i];
    var feature = new ol.Feature();
    feature.setProperties({
      'id': marker.id,
      'content': marker.content
    });
    if (marker.icon != null && marker.icon != '') {
      var marker_style = new ol.style.Style({
        image: new ol.style.Icon({
          anchor: [0.5, 1],
          anchorXUnits: 'fraction',
          anchorYUnits: 'fraction',
          opacity: 0.75,
          src: marker.icon
        })
      });
      feature.setStyle(marker_style);
    } else {
      feature.setStyle(default_style);
    }
    var coordinates = ol.proj.transform([marker.lng, marker.lat], "EPSG:4326", "EPSG:3857");
    feature.setGeometry(new ol.geom.Point(coordinates));
    position_features.push(feature);
  }

  var point_layer = new ol.layer.Vector({
    map: this._map_canvas,
    source: new ol.source.Vector({
      features: position_features
    })
  });
  this._map_canvas.addLayer(point_layer);
  this._position_features = position_features;
  var _this = this;
  this._map_canvas.on('click', function(e) {
    var iconFeatureA = e.map.getFeaturesAtPixel(e.pixel);
    if (iconFeatureA !== null) {
      var selected = iconFeatureA[0];
      _this.open_information(selected);
    }
  });
}

OpenLayersViewer.prototype.move_to = function(marker_id) {
  for (var i = 0; i <= this._position_features.length; i++) {
    if (this._position_features[i].get('id') == marker_id) {
      this.open_information(this._position_features[i]);
      this._map_canvas.getView().setZoom(16);
      break;
    }
  }
}

OpenLayersViewer.prototype.open_information = function(selected) {
  var coordinate = selected.getGeometry().getCoordinates();
  this._content.innerHTML = selected.get('content');
  this._popoverlay.setPosition(coordinate);
  this._map_canvas.getView().setCenter(coordinate);
}