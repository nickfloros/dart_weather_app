library wind_chart;
import 'dart:html';

import 'package:intl/intl.dart';
import 'package:polymer/polymer.dart';
import 'package:mford_util/mford_elements.dart';

import 'package:mford_util/mford_gae.dart';

/**
 * A Polymer click counter element.
 */
@CustomTag('wind-chart')
class WindChart extends PolymerElement {

  bool get applyAuthorStyles => true;
  
  @observable String siteName='';

  DateFormat _tfmt = new DateFormat('HH:mm');

  LineChart _windSpeedLineChart;
  LineChart _windDirectionLineChart;

  ModalLoading _progressBar;

  WindChart.created() : super.created() {
    print('WindChart.created : shadowRoot is null ${shadowRoot==null}');
  }

  void enteredView() {
    super.enteredView();
    print('WindChart.enteredView : shadowRoot is null ${shadowRoot==null}');
    if (shadowRoot!=null) {      
     _windSpeedLineChart =$['speedChart'];
     _windDirectionLineChart =$['directionChart'];
     _progressBar = $['modalLoading'];
     // look for component rather than id ... 
     // _progressBar = this.shadowRoot.getElementsByTagName('yab-progress-bar').first;
     window.on['drawCharts'].listen( (data) {draw(data.detail);});
    }
  }
  
  void resize(int width, int height) {
    $['chartDiv'].style.width='${width}px';
    $['chartDiv'].style.height='${height}px';
  }
  
  void loading(String name) {
    print('Loading - $name');
    siteName = name;
    $['siteName'].text=name;
    _progressBar.show(titleTxt:name);
  }
  
  /**
   * draw charts
   */
  void draw(AnemometerSiteReadings resp) {
    
    List directionData = new List() 
      ..add( new List() 
      ..add('Time')
      ..add('Min')
      ..add('Avg')
      ..add('Max')
      );
    
    List speedData = new List() 
      ..add( new List() 
      ..add('Time')
      ..add('Min')
      ..add('Avg')
      ..add('Max')
      );            
      
    for (AnemometerReading item in resp.readings) {
      directionData.add(item.direction.toList(item.timeStamp));
      speedData.add(item.speed.toList(item.timeStamp));
    }
    $['siteName'].text='$siteName - last reading @ ${_tfmt.format(resp.readings.last.timeStamp)}, next @ ${_tfmt.format(resp.expireTime)}';
    _windSpeedLineChart.draw(speedData);
    _windDirectionLineChart.draw(directionData);
    _progressBar.hide(); 
  }
}
