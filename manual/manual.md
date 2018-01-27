### Pattern matrix 4x4 v3 manual

This version comprises warp weighted and tablet weaving and a new web
control panel that can be used via laptop or phones via wifi
connection (it uses it's own local network no internet connectivity is
required).

![](https://github.com/Kairotic/patternmatrix2/raw/master/manual/images/pic.jpg)

On startup the warp weighted loom mode activates with a 4x4
matrix. The same controls and block works as before for colour, but
there is no special 'shutdown' token any more.

## Web control panel

Connect via wifi to `patternmatrix` password: `penelopeundo`
Visit this URL: `http://10.42.0.1/`

From here you can remotely switch loom types and shutdown or restart
the Pi. Note: while connected to the pattern matrix, you will not be
able to reach the internet.

## Connections

Overall picture – the Raspberry Pi connects to the two “row
controller” boards via a 4 way ribbon cable. Each “row controller”
supplies power to it's 8 sensor boards via a 2 way ribbon cable and
reads the sensor data via the large 16 way ribbon cable that plugs
into each sensor.








Each sensor board connects with the power to the left and 

