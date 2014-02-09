### Dart Weather App

Live wind speed and direction for few windsurding spots in South of England
- Highcliffe
- Portland
- Lyndhurst
- Hurst Castle.

Data is courtesy of http://www.r-p-r.co.uk/index.html

The app demonstrates use of 
- Polymer components
- Google Maps & charts see (http://github.com/nickfloros/mford_util).
- Use of bootstrap css to support application for use on mobile devices.
- Support for browser history to allow use to navigate within the site.
- Implementation of bootstrap modal, navbar, navtab controls ((http://github.com/nickfloros/mford_util).
- Integration with Google AppEngine Endpoints (http://github.com/nickfloros/mford_util).

Google App Engine implimentation is outlined at https://github.com/nickfloros/mford-gae

Deployment of the contents of the build directory follows simple step
- Run 'Build Polymer App' step
- Copy contnets of the build directory to `<appengineProject>/src/main/java/webapp`
- Change to `<appengineProject>` and run `mvn appengine:update`   

Outstanding issues
- Goolge maps do work on mobile devices
- Navigation does not work on mobile devices
