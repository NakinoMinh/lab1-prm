import http.server
import socketserver
import os
import webbrowser

PORT = 3000
DIRECTORY = os.path.join(os.path.dirname(__file__), "docs")

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

if __name__ == "__main__":
    os.chdir(DIRECTORY)
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"=======================================================")
        print(f"  FAP Student Attendance Portal (Cổng Điểm Danh SV)   ")
        print(f"  Running locally at: http://localhost:{PORT}         ")
        print(f"  GitHub Pages Live: https://nakinominh.github.io/lab1-prm/ ")
        print(f"=======================================================")
        webbrowser.open(f"http://localhost:{PORT}")
        httpd.serve_forever()
