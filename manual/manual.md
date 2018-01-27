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

Once connected visit this URL: `http://10.42.0.1/`. You should see a
web page in your browser like this:

![](https://github.com/Kairotic/patternmatrix2/raw/master/manual/images/web.png)

From here you can remotely switch loom types and shutdown or restart
the Pi. Note: while connected to the pattern matrix, you will not be
able to reach the internet.

## Connections

Overall picture – the Raspberry Pi connects to the two “row
controller” boards via a 4 way ribbon cable. Each “row controller”
supplies power to it's 8 sensor boards via a 2 way ribbon cable and
reads the sensor data via the large 16 way ribbon cable that plugs
into each sensor.

![](https://github.com/Kairotic/patternmatrix2/raw/master/manual/images/overall.jpg)

The connectors on the sensor end are left plugged in, but the other
ends need connecting to the row controllers. Blobs of grey nail
varnish indicate the side of the plug that should be facing up:

![](https://github.com/Kairotic/patternmatrix2/raw/master/manual/images/connecting.jpg)

The row controllers need connecting to the Raspberry Pi via the 4 way
ribbon cable:

![](https://github.com/Kairotic/patternmatrix2/raw/master/manual/images/pi-close.jpg)

## More detailed information
   
If the sensors need to be disconnected at any time, they are
reconnected like this, with the power on the left two pins and the
data on the right four pins - with the metal parts outward facing.

![](https://github.com/Kairotic/patternmatrix2/raw/master/manual/images/sensor-close.jpg)

These are the four types of connector, from left to right: four sensor
data connectors, two sensor power connectors and two connectors that
connect the Raspberry Pi to the row controllers.

![](https://github.com/Kairotic/patternmatrix2/raw/master/manual/images/connectors.jpg)



