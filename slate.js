var margin = 0;

// General Config
slate.cfga({
  "defaultToCurrentScreen" : true,
  "secondsBetweenRepeat" : 0.1,
  "checkDefaultsOnLoad" : true,
  "focusCheckWidthMax" : 3000
});

// Corner Operations
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

// Left Right Operations
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

var centeredResize = slate.operation("move", {
  "x": "screenOriginX+screenSizeX*.1",
  "y": "screenOriginY+screenSizeY*.05",
  "width": "screenSizeX*.8",
  "height": "screenSizeY*.9"
});

var centered = slate.operation("move", {
  "x": "screenOriginX+(screenSizeX-windowSizeX)/2",
  "y": "screenOriginY+(screenSizeY-windowSizeY)/2",
  "width": "windowSizeX",
  "height": "windowSizeY"
});

// Focus Operations
var focusLeft = slate.operationFromString("focus left");
var focusRight = slate.operationFromString("focus right");
var focusUp = slate.operationFromString("focus up");
var focusDown = slate.operationFromString("focus down");

// misc
var hint = slate.operationFromString("hint ASDFGHJKL");
var grid = slate.operationFromString("grid");
var undo = slate.operationFromString("undo");
var throwNext = slate.operationFromString("throw next");

function cycle(a) {
  var i = 0;
  var f = function(win) {
    win.doOperation( a[i] );
    i++;
    i %= a.length;
  }

  f.reset = function() { i = 0 }

  return f
}

function callsReset(operation, elements) {
  return function(win) {
    if (typeof(operation) == 'function') {
      operation(win);
    } else {
      win.doOperation(operation);
    }
    for (var i = 0; i < elements.length; i++) {
      elements[i].reset()
    }
  }
}

// left right (with cycling thirds)
var leftCycle = cycle([pushLeft, pushLeftThird, pushLeftTwoThirds]);
var rightCycle = cycle([pushRight, pushRightThird, pushRightTwoThirds]);

// corners
slate.bind("1:ctrl;alt", callsReset(topLeft, [leftCycle, rightCycle]));
slate.bind("2:ctrl;alt", callsReset(topRight, [leftCycle, rightCycle]));
slate.bind("3:ctrl;alt", callsReset(bottomLeft, [leftCycle, rightCycle]));
slate.bind("4:ctrl;alt", callsReset(bottomRight, [leftCycle, rightCycle]));

slate.bind("left:ctrl;alt", callsReset(leftCycle, [rightCycle]));
slate.bind("right:ctrl;alt", callsReset(rightCycle, [leftCycle]));

// top and bottom
slate.bind("down:ctrl;alt", callsReset(pushBottom, [leftCycle, rightCycle]));
slate.bind("up:ctrl;alt", callsReset(pushTop, [leftCycle, rightCycle]));

// total screen actions
slate.bind("c:ctrl;alt", callsReset(centered, [leftCycle, rightCycle]));
slate.bind("c:ctrl;alt;shift", callsReset(centeredResize, [leftCycle, rightCycle]));
slate.bind("f:ctrl;alt", callsReset(fullscreen, [leftCycle, rightCycle]));

// focus
slate.bind("h:ctrl;alt", focusLeft);
slate.bind("j:ctrl;alt", focusUp);
slate.bind("k:ctrl;alt", focusDown);
slate.bind("l:ctrl;alt", focusRight);

// misc
slate.bind("s:ctrl;alt", hint);
slate.bind("g:ctrl;alt", grid);
slate.bind("x:ctrl;alt", throwNext);
slate.bind("/:ctrl;alt", undo);
