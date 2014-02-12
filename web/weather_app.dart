library weather_app;
import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

import 'package:logging/logging.dart' show Logger, Level, LogRecord;

import 'package:mford_util/mford_elements.dart';
import 'footer_tab.dart';
import 'wind_chart.dart';
import 'package:mford_util/mford_gae.dart';

/**
 * Main shell application
 */
@CustomTag('weather-app')
class WeatherApp extends PolymerElement {
  final Logger _log = new Logger('WeatherApp');

  bool get applyAuthorStyles => true;
  
  NavBar _navTab;
  WindChart _wchart;
  JsMfordGoogleMap _gMap;
  FooterTab _footerTab;
  int _workAreaHeightOffset=0;
  bool _showingMap = true;
  
  Mford_Gae_Services _svc;
  
  WeatherApp.created() : super.created() {
    _log.info('WeatherApp.created shadowRoot is null ${shadowRoot!=null}');
  }
  
  void enteredView() {
    super.enteredView();
    _log.info('WeatherApp.enteredView shadowRoot is null ${shadowRoot!=null}');
    
    if (shadowRoot!=null) { // there is a strange behaviour 
      
      _navTab = $['navTab'];
      _footerTab = $['footerTab'];
      _wchart = $['chart'];
      _gMap = $['map'];
      
      on[NavBar.selectionEventName].listen( (eventData) {
        _showSite(_svc.sites[eventData.detail]);
        window.history.pushState('site', 'site', '#${eventData.detail}');
      });
      
      on[JsMfordGoogleMap.MARKER_SELECTED_EVENT].listen((eventData) {
        _navTab.select('${eventData.detail}');
        _showSite(_svc.sites[eventData.detail]);
        window.history.pushState('site', 'site', '#${eventData.detail}');
        
      });
      
      on[NavBar.mapSelected].listen( (eventData) {
        if (!showMapping) {
          _showMap();
          window.history.pushState(null, 'map','#map');
        }
      });

      // do not understand why I need both but if I do not do that
      // the JS version of code nothing happens
      window.onHashChange.listen( (Event event)  {
        _log.info('onHashChange');
      });
      
      window.onPopState.listen( (var postStateEvent) {
        var urlHash = window.location.hash; 
        _log.info('onPopState $urlHash');
        if ('#map'.compareTo(urlHash)==0 || urlHash.isEmpty) {
          _showMap();
          _navTab.select('map');
        }
        else {
          var strId = urlHash.substring(1);
          _navTab.select(strId);
          _showSite(_svc.sites[int.parse(strId)]);
        }
      });

      _svc=new Mford_Gae_Services()
          ..readSites().then( (List<AnemometerSite>  resp) {
          _renderSites(resp);
          });          
      
      _navTab.select('map');
      
      window.onResize.listen( (event) {
        event.preventDefault(); // stop the event from propagating ..
        
        if (_showingMap) {
          _gMap.show( window.innerWidth,window.innerHeight-(_navTab.height + _footerTab.height));
        }
        else {
          _wchart.resize(window.innerWidth,window.innerHeight-(_navTab.height + _footerTab.height));
        }
      });
     
      
      if (_showingMap)
        _gMap.show(window.innerWidth,window.innerHeight-(_navTab.height + _footerTab.height));


    }

  }
  
  /**
   * renders anemometer sites 
   */
  void _renderSites(List<AnemometerSite> sites){
    _navTab.options.clear();
    for (var item in sites) {
      _navTab.options.add(item.stationName);
      _gMap.addMarker(item.stationCode,item.stationName, item.latitude, item.longitude);
    }
    _gMap.show(window.innerWidth,window.innerHeight-(_navTab.height + _footerTab.height));

  }
  
  /**
   * show data for one of the sites  
   */
  void _showSite(AnemometerSite data) {
    if (_showingMap) {
      _gMap.classes.toggle("hide");
      _wchart.classes.toggle("hide");
      _showingMap=false;
    }

    _wchart.loading(data.stationName);
    _svc.readSite(data.id).then( _processResponse);
    _wchart.resize(window.innerWidth,window.innerHeight-(_navTab.height + _footerTab.height));

  }


  /**
   * show the map
   */
  void _showMap() {
    if (!_showingMap) {
      _showingMap=true;
      _wchart.classes.toggle("hide");
      _gMap.classes.toggle("hide");
      _gMap.show(window.innerWidth,window.innerHeight-(_navTab.height + _footerTab.height));
    }
  }

  void _processResponse(var resp) {
   _wchart.draw(resp);
  }
  
  
  
  bool get  showMapping => _showingMap;
}