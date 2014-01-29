library weather_app;
import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:route_hierarchical/client.dart';

import 'package:mford_util/mford_elements.dart';
import 'footer_tab.dart';
import 'wind_chart.dart';
import 'package:mford_util/mford_gae.dart';
/**
 * Main shell application
 */
@CustomTag('weather-app')
class WeatherApp extends PolymerElement {
  
  bool get applyAuthorStyles => true;
  
  NavBar _navTab;
  WindChart _wchart;
  JsMfordGoogleMap _gMap;
  FooterTab _footerTab;
  int _workAreaHeightOffset=0;
  var _contentDiv;
  Router router;
  
  bool _showingMap = true;
  
  Mford_Gae_Services _svc;
  
  WeatherApp.created() : super.created() {
    print('WeatherApp.created shadowRoot is null ${shadowRoot!=null}');
  }
  
  void enteredView() {
    super.enteredView();
    print('WeatherApp.enteredView shadowRoot is null ${shadowRoot!=null}');
    
    if (shadowRoot!=null) { // there is a strange behaviour 
      
      _navTab = $['navTab'];
      _footerTab = $['footerTab'];
      _wchart = $['chart'];
      _gMap = $['map'];
      _contentDiv = $['content']
        ..children.add(_gMap);

      on[NavBar.selectionEventName].listen( (eventData) {
        _showSite(_svc.sites[eventData.detail]);
      });

      on[JsMfordGoogleMap.MARKER_SELECTED_EVENT].listen((eventData) {
        _navTab.select('${eventData.detail}');
        _showSite(_svc.sites[eventData.detail]);
        });
      
      on[NavBar.mapSelected].listen(_showMap);
                  
      _svc=new Mford_Gae_Services()
           ..readSites().then( (resp)=>_renderSites(resp));
//      _navTab.select('map');
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
    window.history.pushState(null, 'site', '#${data.id}');
  }


  /**
   * show the map
   */
  void _showMap(CustomEvent data) {
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