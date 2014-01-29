library footertab;
import 'package:polymer/polymer.dart';

/**
 * A Polymer click counter element.
 */
@CustomTag('footer-tab')
class FooterTab extends PolymerElement {
  // need that to ensure that bootscrap css is applied
  bool get applyAuthorStyles => true;

  FooterTab.created() : super.created() {
    print('footerTab.created : shadowRoot is null ${shadowRoot==null}');
  }

  
  void enteredView() {
    super.enteredView();
    print('footerTab.enteredView : shadowRoot is null ${shadowRoot==null}');
   }
  
  /*
   * this is hardwired .. as we can getting it from dom does not 
   * work very well due images not loaded in the shawdow dom
   */
  int get height {
    if ($['footDiv']!=null)
      return $['footDiv'].clientHeight;
    return 50;
  }
}

