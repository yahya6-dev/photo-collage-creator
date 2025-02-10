// This file contains implementation of the grid ceil represented as Ceil class.
// The class is assigned attributes such  as rotation angle for rotating the grid
// isSelected to indicate that the grid ceil is selected, the color the user  fill the ceil with,
// Image to fill the ceil with, rectanglar area representing x,y width and height,
// shape in case the select need a custom shape for the grid cell
import "dart:ui" as ui;
import "package:flutter/material.dart";
import "dart:math";
import "package:flutter/widgets.dart";
import "dart:typed_data";

class Ceil {
  // Background Image of this ceil
  ui.Image? _image;
  String _shape = "Rectangle";
  // Store Kind Of Split within the ceil whether its in vertical or horizontal
  // as we use this field to determine, if certain kinds of splitting is possible or not 
  String splitOrientation = "None";
  // List Of Split Operation on this ceil, we use this fields to recreate the splits ceil during image export
  List<String> splitOperation = []; 
  // Picture element for flexity to change image size at will
  ui.Picture? picture;
  //  Unique id for each ceil but only for toplevel ceils, used for sorting ceils during image export. 
  var id = 0;
  // Id of the ceil that merged this ceil to itself
  int? merginId = null;
  // List children subceils that each can have its own properties
  var subCeils = <Ceil>[];
  // Type of ceil whether it is used as parent ceil or child ceil, to prevent certain operation on subCeils
  String ceilType = "Parent";
  // Grid Ceil Color Used by sub ceils
  Color? gridColor;
  // If a ceil is merged horizontally it cant be further merge vertically
  // This field takes two 3 values Horizontal or Vertical, default None
  String merginAxis = "None";
  // Determine if this ceil is selected, therefore potential for operation to  be applied on it
  bool _isSelected = false;
  double _rotationAngle = 0;
  // Ceil Rectangular Size
  double? _x;
  double? _y;
  double? _width;
  double? _height;
  // Solid filled color
  Color? _color;
  double _elevation = 0;
  Color _elevationColor = Colors.white;
  bool drawned = false;
  Color borderColor = Colors.white;
  double borderWidth = 0.0;

  // This function load the image to be used as ceil filling
  // and resize the image to the ceil size
  void loadImage(int width,int height) {
    _image = picture?.toImageSync(width,height);

  }

  // This function clone a ceil with all its properties
  // excluding its width and height, x,y
  // used to construct the final image for saving to filesystem
  Ceil clone() {
    Ceil ceil = Ceil();
    // Set all attribute of the existing ceil
    ceil.id = id;
    ceil.splitOperation = splitOperation;
    ceil.splitOrientation = splitOrientation;
    ceil.merginId = merginId;
    ceil._elevation=_elevation;
    ceil.borderWidth = borderWidth;
    ceil.borderColor = borderColor;
    ceil._elevationColor = _elevationColor;
    ceil._rotationAngle = _rotationAngle;
    ceil.merginAxis = merginAxis;
    ceil.gridColor = gridColor;
    ceil.ceilType = ceilType;
    // Clone subCeil, but remember to copy their x,y and width, height
    if (subCeils.length > 0) {
      ceil.subCeils = [...subCeils.map((child) { 
        Ceil ceil = child.clone();
        ceil._x = child._x;
        ceil._width = child._width;
        ceil._height  = child._height;
        ceil._y = child._y;
        return ceil; 
      })];
    }

    ceil._shape = _shape;
    ceil._image = _image;
    ceil.merged = merged;
    ceil._color  = _color;
    ceil.merginAxis = merginAxis;
    return ceil;
  }

  // An interface for setting grid color 
  void setGridColor(Color color) {
  	this.gridColor = color;
  }

  // This function is called when a user finished cropping the image
  // and press Apply button, it expect Picture as an argument and image dimension
  void setPicture(ui.Picture picture,int width,int height) {
    // If no subceils draw the picture as the background of the ceil
    if (subCeils.length == 0) {
      this.picture = picture;
      // Load the image;
      loadImage(width,height);
    }
    // Ceil contains subCeils, Loop through to find  selected ceils.
    else {
      subCeils.forEach((child) {
        if (child.getSelectionState()) {
          child.setPicture(picture,width,height);
        }
      });
    }
  }

  // Function to indicate that, this ceil already has x,y and width,height
  // therefore no need to recalculate it again during canvas drawing
  void setIsDrawned(bool state) {
  	drawned = state;
  }

 	// Indicate whether the ceil have image set or color set
 	// used for allowing or disallowing mergin btw ceils
  bool get haveFilling => _image != null || _color != null;

  // Determine if this ceil has x,y and width and height
  bool get isDrawned => drawned;

  // Size for normalizing this ceil while growing/enlarging 
  double xOrigin = 0;
  double yOrigin = 0;
  double widthOrigin = 0;
  double heightOrigin = 0;


  // An interface to change a grid ceil rotation angle
  // that ranges from 0 90deg degree, in each step it increases by 15deg;
  void increaseRotationAngle() {
    // Increase rotation angle of subCeils if the parent ceil has any
    if (subCeils.length > 0) {
      subCeils.forEach((child)  {
        if (child.getSelectionState()) {
          child.increaseRotationAngle();
        }

        });
    }

    // If the ceil has subCeils don't rotate the parent ceil
    if ((subCeils.length > 0)) return;
    
    // Else rotate the parent ceil,
    // but clamp the angle between 0 and 90 degree
  	if (_rotationAngle == 90)
  		_rotationAngle = 0;

  	else
  		_rotationAngle += 15; 
  }

  // Flag to indicate if this widget is merged to another ceil
  bool merged = false;

  // Determine if this ceil is merged to another ceil
  bool get isMerged => merged;

  // Increase this ceil's area size and its drawing priority, ceil with high elevation is drawned last.
  void setElevationHeight(double value) {
    // Terminate early if the ceil contained subCeils
    if (subCeils.length > 0) 
      return;

    // we use xOrigin, yOrigin, and widthOrigin,heightOrigin to modify the _x, _y ,_width _height
    // but still xOrigin,yOrigin and widthOrigin,heightOrigin contain the original position and size
    _elevation = value;

    // Dont inflate if we're on the left most of the screen
    if (xOrigin != 0.0) {
      _x = xOrigin - value;
    }
    // Dont inflate if we're on top most of the screen
    if (_y != 0.0)
      _y = yOrigin - value;
    

    _width = widthOrigin + value*2;
    _height = heightOrigin + value*2;

  }

  // A variant of setElevationHeight but called during saving canvas to image
  // it takes additional argument heightFactor, since export size may be different from the 
  // size of our drawing canvas.
  // We use it estimate apropriate size for elevated ceil
  void setElevationHeightCustom(double value,double widthFactor,double heightFactor) {
    _elevation = value;
    if (xOrigin != 0.0) {
      _x = xOrigin - value*widthFactor;
    }

    if (_y != 0.0)
      _y = yOrigin - value*heightFactor;
    

    _width = widthOrigin + value*widthFactor*2;
    _height = heightOrigin + value*2*heightFactor;

  }

  // Get Overlapping with other widget and it is drawing priority
  // The widget with higher elevation always get drawned last
  int getElevationLevel() {
    return _elevation.toInt();
  }

  // set this ceil as beeing merged to another or not
  void setIsMerged(bool flag) {
  	merged = flag;
  }


  // Method for setting ceil border color called from GridEditorState
  void setBorderColor(Color color) {
  	// If it has no nested ceils set border color directly on this ceil,
  	// else Route calling to the subCeils
  	if (subCeils.length == 0)
  		borderColor = color;
    // Loop through subCeil if any
  	else {
  		subCeils.forEach((child) {
  			if (child.getSelectionState())
  				child.setBorderColor(color);
  			});
  	}
  }

  // Method for setting ceil border width, called from GridEdiorState
  void setBorderWidth(double width) {
    // If it has no nested ceils set border color directly on this ceil,
    // else Route calling to the subCeils
  	if (subCeils.length == 0)
  		borderWidth = width;

    // Loop through subCeils if any
  	else {
  		subCeils.forEach((child) {
  			if (child.getSelectionState())
  				child.setBorderWidth(width);
  			});
  	}
  }
  
  // Set Parent Shape if it has no subCeils else
  // loop through children ceils to determine which
  // one of the subCeils to change its shape
  void setShape(String shape) {
    if (subCeils.length == 0)
      _shape = shape;

    else {
      subCeils.forEach((child) {
        if (child.getSelectionState()) {
          child.setShape(shape);
        }
      });
    }
  }

  // Id of the ceil to assist when it comes to sorting ceils during export
  // for determining which ceils get drawned last or first.
  int getId() {
    return id;
  }

  // x y position of this ceil in the canvas
  List<double> getPosition() {
  	return [_x as double,_y as double];
  }


 	Path getPath(String type, double x, double y, double width, double height) {

   	// Return Path based on the type provided calculated using x,y, width and height
   	switch(type) {
   		case "Heptagon":
          // Return Path With Shape Of Heptagon
   				var sideWidth = width  / 4;
      		var sideLength = height / 4;
      		
      		var path  = Path();
      		path.fillType = PathFillType.evenOdd;

      		var centerX = x + width / 2;
      		var xOffset = sideWidth / 2;
      		var yOffset = sideLength / 2;

      		var tip = Offset(centerX,y);
      		var first = Offset(x+xOffset,y+sideLength);
      		var second = Offset(x,y + sideLength* 2 + yOffset);
      		var third = Offset(x + sideWidth ,sideLength * 4 + y);
      		var fourth = Offset(x+sideWidth*3, y + sideLength*4);
      		var fifth = Offset(x + sideWidth * 4, y+sideLength * 2 + yOffset);
      		var sixth = Offset(x+ sideWidth * 4 - xOffset, sideLength + y);

      		path.addPolygon([tip,first,second,third,fourth,fifth,sixth],false);
      		path.close();
      		return path;

   		case "Rectangle":
        // Return Path With Shape Of Rectangle
   			Rect rect = Rect.fromLTWH(x,y,width,height);
   			var path = Path();
        path.fillType = PathFillType.nonZero;
        path.addRect(rect);
        path.close();
        return path;

      case "Diamond":
        // Return Path With Shape Of Diamond
      	var path = Path();
      	path.fillType =  PathFillType.evenOdd;
      	var sideLength = height / 2;
      	var centerX = x + width / 2;
      	var centerY = y + height / 2;
      	var tip = Offset(centerX,y);
      	var first = Offset(x ,y+sideLength);
      	var second = Offset(centerX , y + sideLength*2);
      	var third = Offset(x + width ,y + sideLength);
     
      	path.addPolygon([tip,first,second,third],false);
      	path.close();
      	return path;

      case "Hexagon":
        // Return Path With Shape Of Hexagon
      	var path = Path();
        var sideLength = height / 4;
        var sideWidth = width / 2;

        var centerX = x + width / 2;
        var centerY = y + height / 2;
        var bottomTip = Offset(centerX, height + y);
        var topTip = Offset(centerX,y);
        var firstSide = Offset(x, sideLength + y);
        var secondSide = Offset(x , y + sideLength  * 3);
        var thirdSide = Offset(x + width, y + sideLength*3);
        var fourth = Offset(x + width, y + sideLength);
        path.addPolygon(
              [topTip, firstSide,secondSide,bottomTip,thirdSide,fourth], true);
        path.fillType = PathFillType.evenOdd;
        path.close();
        return path;

      case "Pentagon":
        // Return Path With Shape Of Pentagon
      	var sideLength = height / 2;
      	var path = Path();
      	var centerX = x  + width / 2;
      	var centerY = y + height / 2;
      	var tip = Offset(centerX, y);
      	var first = Offset(x, sideLength + y);
      	var second = Offset(x, (sideLength*2) + y);
      	var three = Offset(x + width, sideLength*2  + y);
      	var fourth = Offset(x + width, sideLength + y);

      	path.addPolygon([tip,first,second,three,fourth],true);
      	path.close();
      	return path;

      case "Star":
        // Return Path With Shape Of Star
      	var path = Path();
      	var centerX = x + width  / 2;
      	var centerY = y + height / 2;

      	var xDivision = width  / 5;
      	var yDivision = height / 4;
      	var tip = Offset(centerX, y);
      	var first = Offset(x  + xDivision*2, y + yDivision);
      	var second = Offset(x , y + yDivision);
      	var xOffset = xDivision / 2;
      	var yOffset = yDivision / 2;
      	var third = Offset(x + (xDivision * 2) - xOffset, y + yDivision*2);
      	var fourth = Offset(x + xOffset, y + yDivision * 4);
      	var sixth = Offset(x + width - xOffset, y + height);
      	var fifth = Offset(centerX, y + yDivision*3);
      	var seventh = Offset(x + (xDivision * 4) - xOffset, y + yDivision*2 );
      	var eight = Offset(x + (xDivision*3), y  + yDivision);
      	var nine = Offset(x + xDivision*5, y  + yDivision);
      	//var tenth = Offset((_x as double) + 2.5*xDivision,(_y as double) );
      	path.addPolygon([tip,first,second,third,fourth,fifth,sixth,seventh,nine,eight],true);
      	//path.clipRect(getRect());
      	path.close();
      	return path;
      	
      case "Triangle":
        // Return Path With Shape Of Triangle
      	var centerX = x + width / 2;
      	var path = Path();
      	var top = Offset(centerX, y);
      	var left = Offset(x, y + height);
      	var right = Offset(x  + width, y+height);

      	path.addPolygon([top,left,right],false);
      	path.close();
       	return path;

      case "Circle":
        // Return Path With Shape Of Circle
      	var centerXY = Offset(width /2,height/2);
      	var rect = Rect.fromLTWH(x,y,width, height);
      	var path = Path();
      	path.fillType = PathFillType.evenOdd;
      	path.addArc(rect,0,360);
      	path.close();
      	return path;

      case "Heart":
        // Return Path With Shape Of Circle
        var path = Path();
        var centerX = x + width / 2;
        var centerY = y + height / 2;
        var xOffset = width / 4;
        var yOffset = height / 4;

        var leftRect = Rect.fromLTWH(x,y,width/2,yOffset*2);
        var rightRect = Rect.fromLTWH(x+width/2,y,width/2,yOffset*2);

        path.arcTo(rightRect,0,-135,false);
        path.arcTo(leftRect,0,-135,false);
        path.arcTo(Rect.fromLTWH(x+width/2,y+height,1,1),0,180,false);
        //print("Debug => $leftRect $rightRect ${_height as double}");
        path.fillType = PathFillType.evenOdd;
        path.close();
        return path;
      default:
      	return Path();
         
   	}

  }

  

  // Set this ceil position and size
  void setRect(double x, double y, double width, double height) {
    _x = x;
    _y = y;
    _width = width;
    _height = height;

    // Remember to assign  xOrigin, yOrigin, widthOrigin, heightOrigin
    // used for normalizing ceil during growing/enlarging
    xOrigin = x;
    yOrigin = y;
    widthOrigin = width;
    heightOrigin = height;

  }


  // Draw this ceil on the canvas with its various attribute such as image, color
  void drawItem(Canvas canvas, bool showGrid) {
    // If ceil is merged to another skip it
    if (!isMerged) {
    	if (showGrid) {
      	canvas.save();
        var rect = Rect.fromLTWH(
            _x as double, _y as double, _width as double, _height as double);

        var color = Color.fromRGBO(180,180,180,1);
        // If this is a subchild draw it with its own grid color 
        if (gridColor != null) {
        	color = gridColor as Color;
        }

        // Outline paint
        var paint1 = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color;

        canvas.drawRect(rect, paint1);
        canvas.restore();
      }

      var x = _x as double;
      var y = _y as double;
      var width = _width as double;
      var height = _height as double;
      canvas.save();
      // Rotate this ceil
      if (_rotationAngle != 0) {
			  canvas.translate(x+width/2,y+height/2);
        canvas.rotate( (pi/180)*_rotationAngle);
      }

      Path path;
      if (_rotationAngle != 0)
        path = getPath(_shape,-width/2,-height/2,width,height);
      else
        path = getPath(_shape,x,y,width,height);

      // Clip everything out bound of our shape
      canvas.clipPath(path);

      // Draw Our Ceil Filling Color
      if (_color != null) {
        var paint2 = Paint()..color = _color as Color;
        canvas.drawRect(getRect(false), paint2);
      }

      // Draw our ceil background image if any.
      if (_image != null) {
        var width = _image?.width.toDouble() as double;
        var height = _image?.height.toDouble() as double;
        var paint1 = Paint()..color = Colors.white;
        var rect = Rect.fromLTWH(0, 0, width, height);
        
        canvas.drawImageRect(_image as ui.Image, rect, getRect(false), paint1);
        
      }

      if (borderWidth != 0) {
      	// Draw An Outline around ceil, following it shape 
      	var paint3 = Paint()..color = borderColor
      		..style = PaintingStyle.stroke
      		..strokeWidth = borderWidth;

      	 var x1 = (_x as double);
				 var y1 = (_y as double);
				 var width1 = (_width as double);
				 var height1 = (_height as double);

				 canvas.save();
				 // Outline Path or border Path
         Path path2;
         if (_rotationAngle != 0)
				  path2 = getPath(_shape,-width1/2,-height1/2,width1,height1);

         else
          path2 = getPath(_shape,x1,y1,width1,height1);

      	 canvas.drawPath(path2,paint3);
      	 canvas.restore();
      }

      if (getSelectionState()) {
        var paint = Paint()
          ..color = Color.fromRGBO(
              255, 255, 255, 0.2); //Color.fromRGBO(255,255,255,0.3);
        canvas.drawRect(getRect(false), paint);
        // Draw A blue green check for selected ceil
        var centerX = (_x as double) + (_width as double) / 2;
        var offsetX = (_width as double) / 5;
        var offsetY = (_height as double) / 4;

        // starting offset on x,y plane
        double x = (_x as double);
        double y = (_y as double);

        // rotation angle is set, set width and height as starting offsets
        if (_rotationAngle != 0) {
          x = -(_width as double)/2;
          y = -(_height as double)/2;
        }

        var paint00 = Paint()..color = Color.fromRGBO(0,100,250,1)
         ..strokeWidth = 4
         ..style = PaintingStyle.stroke;

        var offset1 = Offset(offsetX + x,offsetY*2+(y));
        var offset2 = Offset(offsetX*2 + x,offsetY*3+(y));
        var offset3 = Offset(offsetX*4 + (x), offsetY + (y));
        var offset4 = Offset(offsetX*2 + (x), offsetY*3 + (y));
        canvas.drawPoints(ui.PointMode.lines,[offset1,offset2,offset3,offset4],paint00);
        //canvas.restore();
      }

      canvas.restore();

     // Children ceil themselve last drawned
      subCeils.forEach((child) => child.drawItem(canvas, showGrid));

      
      
    }
  }

  // This function is called when a ceil is tapped on the gridEditor
  // used to select or deselect a ceil
  void updateState(Offset pos, void Function() updateState,
      void Function(int arg) addSelectedCeil) {
  	if (isMerged) {
  		updateState();
  		return;
  	}

    Rect rect = Rect.fromLTWH(_x as double, _y as double, _width as double, _height as double);
    if (rect.contains(pos) && (subCeils.length == 0)) {

      // Select this  ceil if it is not selected
      if (!getSelectionState()) {
        setSelectionState(true);
        addSelectedCeil(1);
      } 
      // Deselect this ceil if it is selected
      else {
        setSelectionState(false);
        addSelectedCeil(-1);
        
      }
      updateState();
    }

  	// Determine whether any of its subceils is selected
    subCeils.forEach((child) {
    	if (child.getRect().contains(pos)) {
    		if (child.getSelectionState()) {
    			child.setSelectionState(false);
          addSelectedCeil(-1);
    		}
    		else {
    			child.setSelectionState(true);
          addSelectedCeil(1);
         
    
    		}
         updateState();
    	}
      
    });
  }

  // Return Rect object representing this ceil size and position
  Rect getRect([bool flag=true]) {
    // Starting offset
    var x = _x as double;
    var y = _y as double;
    var width = _width as double;
    var height = _height as double;

    // Flag is true, return rect without taking rotation angle into consideration,
    // Use to select subCeils disrespect they're rotated or not
    if (flag) {
      return Rect.fromLTWH(x,y,width,height);
    }

    if (_rotationAngle != 0)
    	return Rect.fromLTWH(-width/2,-height/2,width,height);
      
    return Rect.fromLTWH(x , y, width,
        height);
  }

  // Retrieve color of this ceil
  Color? getColor() {
    return _color;
  }

  // Set color filling of this ceil if it has children ceils
  // Loop through them and set the corresponding color filling for selected subCeils
  void setColor(Color color) {
    if (subCeils.length == 0)
      _color = color;

    else {
      subCeils.forEach((child) {
        if (child.getSelectionState())
          child.setColor(color);
        });
    }
  }

  // Interface to retrieve rotation angle
  double getRotationAngle() {
    return _rotationAngle;
  }


  // Remove all filling and style of this grid ceil
  void removeCeilFilling() {
  	// Reset all ceil's attributes to their default
    if (subCeils.length == 0) {
  	 _shape = "Rectangle";
  	 _image = null;
  	 _color = null;
  	 borderWidth = 0;
  	 borderColor = Colors.white;
  	 _rotationAngle = 0;
  	 _elevationColor = Colors.white;
  	 _elevation = 0;

    }
    // Loop through sub ceils if any
    else {
      subCeils.forEach((child) {
        if (child.getSelectionState())
          child.removeCeilFilling();

        });

    }
  }

  // Set whether this ceil is selected or not
  void setSelectionState(bool isSelected) {
    _isSelected = isSelected;
  }

  // Return state of selection of this ceil whether it is selected or not
  bool getSelectionState() {
    return _isSelected;
  }

 

  void splitHorizontal() {
  	// If the parent ceil contains no sub ceils
  	// find the center along y axis for second grid ceil as its y, while the starting y [of the parent ceil] position for the first
  	// grid ceil, their height will be  height / 2  the original height, then set their corresponding grid color
  	// then attach them to subCeils. 
    
    // Terminate split operation as child ceil cant be sub divided further;
    if (ceilType == "Child") return;   
  	if (subCeils.length == 0) {
  		var x = _x as double;
  		var y = _y  as double;
  		var width = _width as double;
  		var height = _height as double;

  		double centerY = y + height / 2;
  		height = height / 2;


  		Ceil firstCeil = Ceil()..setRect(x,y,width,height);
  		Ceil secondCeil = Ceil()..setRect(x,centerY,width,height);

  		// Set their respective grid ceil color differentiate from the parent grid ceil
  		firstCeil.setGridColor(Colors.white);
  		secondCeil.setGridColor(Colors.white);
      firstCeil.ceilType = "Child";
      secondCeil.ceilType = "Child";
  		subCeils.addAll([firstCeil,secondCeil]);
      firstCeil.splitOrientation = "horizontal";
      secondCeil.splitOrientation = "horizontal";
      // Store in split orientation for reconstructing the subceils in the output image
      splitOperation.add("horizontal");

  	}
    // If the ceil is already divide either vertical or horizontal divide the two subceils into two more
    // ceils
  	else if (subCeils.length == 2) {
  		// Get Reference to the firstChild in the subceils and divide it vertically
  		var firstCeil = subCeils[0];
			var x1 = firstCeil._x as double;
  		var y1 = firstCeil._y  as double;
  		var width1 = firstCeil._width as double;
  		var height1 = firstCeil._height as double;

  		double centerY1 = y1 + height1 / 2;
  		height1 = (height1) / 2;

  		Ceil secondCeil = Ceil()..setRect(x1,centerY1,width1,height1);
  		firstCeil.setRect(x1,y1,width1,height1);

  		// Third Child Ceil
  		var thirdCeil = subCeils[1];
  		var x2 = thirdCeil._x as double;
  		var y2 = thirdCeil._y as double;
  		var width2 = thirdCeil._width as double;
  		var height2 = thirdCeil._height as double;

  		double centerY2 = y2 + height2 / 2;
  		height2 = (height2 / 2);

  		// Fourth child
  		Ceil fourthCeil = Ceil()..setRect(x2,centerY2,width2,height2);

  		// Modify Third Child  Rect area
  		thirdCeil.setRect(x2,y2,width2,height2);
  		// Set their respective grid ceil color differentiate from the parent grid ceil
  		secondCeil.setGridColor(Colors.white);
  		fourthCeil.setGridColor(Colors.white);
      secondCeil.ceilType = "Child";
      fourthCeil.ceilType = "Child";
      thirdCeil.ceilType = "Child";
      firstCeil.ceilType = "Child";
      secondCeil.splitOrientation = "horizontal";
      fourthCeil.splitOrientation = "horizontal";
  		subCeils.addAll([secondCeil,fourthCeil]);
      // Trace the kind of split for recreation during image saving
      splitOperation.add("horizontal");
  	}
  }

  void splitVertical() {
  	// if the parent ceil contains no sub ceils
  	// find the center along x axis for second grid as its starting x position, while the actual  x position of the parent for the first grid ceil
  	// while their width will be width/2 of the parent.
  	// then attach to subceils and setting their grid color
    if (ceilType == "Child") return;
  	if (subCeils.length == 0) {
  		var x = _x as double;
  		var y = _y  as double;
  		var width = _width as double;
  		var height = _height as double;
      double centerX = x + width / 2;
  		width = (width) / 2;


  		Ceil firstCeil = Ceil()..setRect(x,y,width,height);
  		Ceil secondCeil = Ceil()..setRect(centerX,y,width,height);

      // Set Ceil Type 
      firstCeil.ceilType = "Child";
      secondCeil.ceilType = "Child";

  		// Set their respective grid ceil color differentiate from the parent grid ceil
  		firstCeil.setGridColor(Colors.white);
  		secondCeil.setGridColor(Colors.white);

  		subCeils.addAll([firstCeil,secondCeil]);

      firstCeil.splitOrientation ="vertical";
      secondCeil.splitOrientation = "vertical";
      splitOperation.add("vertical");
  	}

  	else if (subCeils.length == 2) {
  		// Get Reference to the firstChild in the subceils and divide it vertically
  		var firstCeil = subCeils[0];
			var x1 = firstCeil._x as double;
  		var y1 = firstCeil._y  as double;
  		var width1 = firstCeil._width as double;
  		var height1 = firstCeil._height as double;

  		double centerX = x1 + width1 / 2;
  		width1 = (width1) / 2;

  		Ceil secondCeil = Ceil()..setRect(centerX,y1,width1,height1);
  		firstCeil.setRect(x1,y1,width1,height1);

  		// Third Child Ceil
  		var thirdCeil = subCeils[1];
  		var x2 = thirdCeil._x as double;
  		var y2 = thirdCeil._y as double;
  		var width2 = thirdCeil._width as double;
  		var height2 = thirdCeil._height as double;

  		double centerX1 = x2 + width2 / 2;
  		width2 = (width2 / 2);

  		// Fourth child
  		Ceil fourthCeil = Ceil()..setRect(x2,y2,width2,height2);

  		// Modify Third Child  Rect area
  		thirdCeil.setRect(centerX1,y2,width2,height2);
  		// Set their respective grid ceil color differentiate from the parent grid ceil
  		secondCeil.setGridColor(Colors.white);
  		fourthCeil.setGridColor(Colors.white);
  		subCeils.addAll([secondCeil,fourthCeil]);

      secondCeil.splitOrientation ="vertical";
      fourthCeil.splitOrientation = "vertical";
      splitOperation.add("vertical");
      secondCeil.ceilType = "Child";
      fourthCeil.ceilType = "Child";
  	}

  }

  @override
  String toString() {
    return "Ceil Rect => $getRect()";
  }

  // Retrieve image used as its filling of this ceil
  ui.Image? getImageFilling() {
    return _image;
  }

  // Retrieve this ceil shape
  String getCeilShape() {
    return _shape;
  }

  // This set ceil's shape ie rectangular,circular
  void setCeilShape(String shape) {
    _shape = shape;
  }

  // Retrieve the size of this ceil
  List<double> getSize() {
  	return [_width as double, _height as double];
  }
}
