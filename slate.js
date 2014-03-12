var margin = 15;
 
slate.cfga({
  "defaultToCurrentScreen" : true,
  "secondsBetweenRepeat" : 0.1,
  "checkDefaultsOnLoad" : true,
  "focusCheckWidthMax" : 3000
});
 
// Create Operations
var topLeft = slate.operation("move", {
  "x" : "screenOriginX+" + margin,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX/2-" + margin * 1.5,
  "height" : "screenSizeY/2-" + margin * 1.5
});
 
var topRight = slate.operation("move", {
  "x" : "screenOriginX+screenSizeX/2+" + margin / 2,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX/2-" + margin * 1.5,
  "height" : "screenSizeY/2-" + margin * 1.5
});
 
var bottomRight = slate.operation("move", {
  "x" : "screenOriginX+screenSizeX/2+" + margin / 2,
  "y" : "screenOriginY+screenSizeY/2+" + margin / 2,
  "width" : "screenSizeX/2-" + margin * 1.5,
  "height" : "screenSizeY/2-" + margin * 1.5
});
 
var bottomLeft = slate.operation("move", {
  "x" : "screenOriginX+" + margin,
  "y" : "screenOriginY+screenSizeY/2+" + margin / 2,
  "width" : "screenSizeX/2-" + margin * 1.5,
  "height" : "screenSizeY/2-" + margin * 1.5
});
 
var pushRight = slate.operation("move", {
  "x" : "screenOriginX+screenSizeX/2+" + margin / 2,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX/2-" + margin * 1.5,
  "height" : "screenSizeY-" + margin * 2
});

var pushRightThird = slate.operation("move", {
  "x" : "screenOriginX+2*screenSizeX/3+" + margin / 2,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX/3-" + margin * 1.5,
  "height" : "screenSizeY-" + margin * 2
});

var pushRightTwoThirds = slate.operation("move", {
  "x" : "screenOriginX+screenSizeX/3+" + margin / 2,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX*2/3-" + margin * 1.5,
  "height" : "screenSizeY-" + margin * 2
});
 
var pushLeft = slate.operation("move", {
  "x" : "screenOriginX+" + margin,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX/2-" + margin * 1.5,
  "height" : "screenSizeY-" + margin * 2
});

var pushLeftThird = slate.operation("move", {
  "x" : "screenOriginX+" + margin,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX/3-" + margin * 1.5,
  "height" : "screenSizeY-" + margin * 2
});

var pushLeftTwoThirds = slate.operation("move", {
  "x" : "screenOriginX+" + margin,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX*2/3-" + margin * 1.5,
  "height" : "screenSizeY-" + margin * 2
});

var pushTop = slate.operation("move", {
  "x" : "screenOriginX+" + margin,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX-" + margin * 2,
  "height" : "screenSizeY/2-" + margin * 1.5
});
 
var pushBottom = slate.operation("move", {
  "x" : "screenOriginX+" + margin,
  "y" : "screenOriginY+screenSizeY/2+" + margin / 2,
  "width" : "screenSizeX-" + margin * 2,
  "height" : "screenSizeY/2-" + margin * 1.5
});
 
var fullscreen = slate.operation("move", {
  "x" : "screenOriginX+" + margin,
  "y" : "screenOriginY+" + margin,
  "width" : "screenSizeX-" + margin * 2,
  "height" : "screenSizeY-" + margin * 2
});
 
var centered = slate.operation("move", {
  "x": "screenOriginX+screenSizeX*.1",
  "y": "screenOriginY+screenSizeY*.05",
  "width": "screenSizeX*.8",
  "height": "screenSizeY*.9"
});

function cycle(a) {
  var i = 0;
  return function(win) {
    win.doOperation( a[i] );
    i++;
    i %= a.length;
  }
}

var hyper = "ctrl;alt";

// corners
slate.bind("1:" + hyper, topLeft);
slate.bind("2:" + hyper, topRight);
slate.bind("3:" + hyper, bottomLeft);
slate.bind("4:" + hyper, bottomRight);

// left right (with cycling thirds)
slate.bind("left:" + hyper, cycle([pushLeft, pushLeftThird, pushLeftTwoThirds]));
slate.bind("right:" + hyper, cycle([pushRight, pushRightThird, pushRightTwoThirds]));

// top and bottom
slate.bind("down:" + hyper, pushBottom);
slate.bind("up:" + hyper, pushTop);

// total screen actions
slate.bind("c:" + hyper, centered);
slate.bind("f:" + hyper, fullscreen);
