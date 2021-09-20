# cornerContour WebGL Turtle test
cornerContour WebGL test of turtle graphics and beginRepeat

[demo](https://nanjizal.github.io/cornerContourWebGLTurtle/index.html) 

Star Turtle draw example.

```Haxe
    var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.no );
    // ( repeat 6 times so the star has last corner round. )
    sketcher.setPosition( 100, 200 )
            .penSize( 10 )
            .blue()
            .west()
            .beginRepeat( 6 )
            .forward( 150 )
            .right( 144 )
            .penColorChange( 0.09, 0.1, -0.09 )
            .endRepeat()
            .blue();
````
