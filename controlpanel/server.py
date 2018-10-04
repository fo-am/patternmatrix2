import SimpleHTTPServer
import SocketServer
import os

class server(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path=='/tablet':
            os.system("./tablet.sh")
        if self.path=='/warpweighted':
            os.system("./warpweighted.sh")
        if self.path=='/warpweighted-exp':
            os.system("./warpweighted-exp.sh")
        if self.path=='/robot':
            os.system("./robot.sh")
        if self.path=='/shutdown':
            os.system("sudo halt")
        if self.path=='/reboot':
            os.system("sudo reboot")
        self.path = '/index.html'
        return SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

os.chdir("/home/pi/code/patternmatrix2/controlpanel")
PORT = 80
httpd = SocketServer.TCPServer(("", PORT), server)
httpd.serve_forever()
