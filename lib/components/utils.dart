/*
 * This file contain utility function for determining apropriate image size based
 * on the user screen, width and height, it expect positional parameter width and height,screensWidth and screenHeight as type double, The algorithm first find the image  
 * ratio if the ration is greater ration*screenWidth available is greater than the available screenHeight
 * reduce the ratio by subtracting 0.1 until the ratio X screenWidth is less than the available height 
*/

List<double> findImageSize(
    double width, double height, double screenWidth, double screenHeight) {
  // Calculate aspect ratio
  double ratio = height / width;

  while((ratio * screenWidth) >= (screenHeight-100) ) {
  	ratio -= 0.1;
  }
  // Return the apropriate size
  return [screenWidth, screenWidth * ratio];
}
