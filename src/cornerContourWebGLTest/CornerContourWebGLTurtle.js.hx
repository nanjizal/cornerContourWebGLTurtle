package cornerContourWebGLTest;

import cornerContour.io.Float32Array;

// contour code
import cornerContour.Sketcher;
import cornerContour.Pen2D;
import cornerContour.StyleSketch;
import cornerContour.StyleEndLine;
// SVG path parser
import justPath.*;
import justPath.transform.ScaleContext;
import justPath.transform.ScaleTranslateContext;
import justPath.transform.TranslationContext;

// webgl gl stuff
import cornerContourWebGLTest.ShaderColor2D;
import cornerContourWebGLTest.HelpGL;
import cornerContourWebGLTest.BufferGL;
import cornerContourWebGLTest.GL;

// html stuff
import cornerContourWebGLTest.Sheet;
import cornerContourWebGLTest.DivertTrace;

// js webgl 
import js.html.webgl.Buffer;
import js.html.webgl.RenderingContext;
import js.html.webgl.Program;
import js.html.webgl.Texture;

function main(){
    new CornerContourWebGLTurtle();
}

class CornerContourWebGLTurtle {
    // cornerContour specific code
    var sketcher:       Sketcher;
    var pen2D:          Pen2D;
    
    // WebGL/Html specific code
    public var gl:               RenderingContext;
        // general inputs
    final vertexPosition         = 'vertexPosition';
    final vertexColor            = 'vertexColor';

    // general
    public var width:            Int;
    public var height:           Int;
    public var mainSheet:        Sheet;

    // Color
    public var programColor:     Program;
    public var bufColor:         Buffer;
    var divertTrace:             DivertTrace;
    var arr32:                   Float32Array;
    var len:                     Int;
    var totalTriangles:          Int;
    var bufferLength:            Int;
    public function new(){
        divertTrace = new DivertTrace();
        trace('Contour Test of Turtle');
        width = 1024;
        height = 768;
        // use Pen to draw to Array
        drawContours();
        rearrageDrawData();
        renderOnce();
    }
    
    public
    function rearrageDrawData(){
        trace( 'rearrangeDrawData' );
        var pen = pen2D;
        var data = pen.arr;
        var red    = 0.;   
        var green  = 0.;
        var blue   = 0.; 
        var alpha  = 0.;
        var color: Int  = 0;
        // triangle length
        totalTriangles = Std.int( data.size/7 );
        bufferLength = totalTriangles*3;
         // xy rgba = 6
        len = Std.int( totalTriangles * 6 * 3 );
        var j = 0;
        arr32 = new Float32Array( len );
        for( i in 0...totalTriangles ){
            pen.pos = i;
            color = Std.int( data.color );
            alpha = alphaChannel( color );
            red   = redChannel(   color );
            green = greenChannel( color );
            blue  = blueChannel(  color );
            // populate arr32.
            arr32[ j ] = gx( data.ax );
            j++;
            arr32[ j ] = gy( data.ay );
            j++;
            arr32[ j ] = red;
            j++;
            arr32[ j ] = green;
            j++;
            arr32[ j ] = blue;
            j++;
            arr32[ j ] = alpha;
            j++;
            arr32[ j ] = gx( data.bx );
            j++;
            arr32[ j ] = gy( data.by );
            j++;
            arr32[ j ] = red;
            j++;
            arr32[ j ] = green;
            j++;
            arr32[ j ] = blue;
            j++;
            arr32[ j ] = alpha;
            j++;
            arr32[ j ] = gx( data.cx );
            j++;
            arr32[ j ] = gy( data.cy );
            j++;
            arr32[ j ] = red;
            j++;
            arr32[ j ] = green;
            j++;
            arr32[ j ] = blue;
            j++;
            arr32[ j ] = alpha;
            j++;
        }
    }
    public
    function drawContours(){
        trace( 'drawContours' );
        pen2D = new Pen2D( 0xFF0000FF );
        pen2D.currentColor = 0xff0000FF;
        turtleStar();
        //turtleTest0();
        haxeLogo();
        heptagram();
        enneagram();
    }
    public
    function renderOnce(){
        trace( 'renderOnce' );
        mainSheet = new Sheet();
        mainSheet.create( width, height, true );
        gl = mainSheet.gl;
        clearAll( gl, width, height, 0., 0., 0., 1. );
        programColor = programSetup( gl, vertexString, fragmentString );
        gl.bindBuffer( GL.ARRAY_BUFFER, null );
        gl.useProgram( programColor );
        bufColor = interleaveXY_RGBA( gl
                       , programColor
                       , arr32
                       , vertexPosition, vertexColor, true );
        gl.bindBuffer( GL.ARRAY_BUFFER, bufColor );
        gl.useProgram( programColor );
        gl.drawArrays( GL.TRIANGLES, 0, bufferLength );
        
    }
    public static inline
    function alphaChannel( int: Int ) : Float
        return ((int >> 24) & 255) / 255;
    public static inline
    function redChannel( int: Int ) : Float
        return ((int >> 16) & 255) / 255;
    public static inline
    function greenChannel( int: Int ) : Float
        return ((int >> 8) & 255) / 255;
    public static inline
    function blueChannel( int: Int ) : Float
        return (int & 255) / 255;
    public inline
    function gx( v: Float ): Float {
        return -( 1 - 2*v/width );
    }
    public inline
    function gy( v: Float ): Float {
        return ( 1 - 2*v/height );
    }
    // Feel free to improve and pull better one.
    public 
    function haxeLogo(){
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.no );
        // ( repeat 6 times so the star has last corner round. )
        var a = 10;
        var b = 47;
        sketcher.setPosition( 500, 300 );
        sketcher.turtleHistoryOn = true;
        sketcher.penSize( 8 )
                .red()
                .fillOff()
                .circle( 10 )
                .orange()
                .north()
                .forward( 100 )
                .right( b-a/2 - 2 )
                .beginRepeat( 40 )
                .right( a )
                .forwardFactor( .98 )//( 100 )
                .right( b )
                .forwardFactor( .98 )//100 )
                .penSizeChange( -0.18 )
                .right( a*2+b )
                .right( a )
                .forwardFactor( .98 )//( 100 )
                .right( b )
                .forwardFactor( .98 )
                .left( 92 )
                .penSizeChange( -0.18 )
                .endRepeat()
                .orange();
        sketcher.turtleHistoryOn = false;
        sketcher.setPosition( 300, 500 );
        sketcher.north();
        sketcher.traceHistory();
        sketcher.playHistory( 0 );
    }
    
    public
    function enneagram(){
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.no );
        var sides = 9;
        var angle: Float = turtleGram( 9 );
        sketcher.setPosition( 700, 180 )
                .penSize( 10 )
                .yellow()
                .penColorChange( -0.09, 0.01, 0.09 )
                .west()
                .fillOff()
                .beginRepeat( sides+1 ) // to make corners nice, do extra turn.
                .archBezier( 300, 150, -10 )
                .right( angle )
                .penColorChange( -0.09, 0.01, 0.09 )
                .endRepeat()
                .blue();
    }
    inline
    function turtleGram( sides: Int ){
        return 4.*(90.-360./sides);
    }
    public
    function heptagram(){
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.no );
        sketcher.setPosition(700, 400 )
                .penSize( 10 )
                .plum()
                .west()
                .fillOff()
                .beginRepeat( 7+1 ) // to make corners nice, do extra turn.
                .archBezier( 300, 150, 30 )
                .right( 4*(90-360/7) )
                .penColorChange( 0.09, 0.1, -0.09 )
                .endRepeat()
                .blue();
    }
    public
    function turtleStar(){
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.no );
        // ( repeat 6 times so the star has last corner round. )
        sketcher.setPosition( 50, 150 )
                .penSize( 10 )
                .blue()
                .west()
                .fillOff()
                .beginRepeat( 6 )
                .archBezier( 300, 150, 30 )
                .right( 144 )
                .penColorChange( 0.09, 0.1, -0.09 )
                .endRepeat()
                .blue();
    }
    public
    function turtleTest0(){
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.no );
        sketcher.setPosition( 400, 200 )
            .penSize( 30 )
            .forward( 60 )
            .right( 45 )
            .forward( 60 )
            .right( 45 )
            .forward( 70 )
            .arc( 50, 120 );
    }
}