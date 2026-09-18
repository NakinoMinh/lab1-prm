import http.server
import socketserver
import os
import json
import webbrowser

PORT = 8080
DIRECTORY = os.path.join(os.path.dirname(__file__), "build", "web")

# Sample live attendance store shared with Extension
ATTENDANCE_DATA = {
    "status": "success",
    "classCode": "SE1801",
    "subjectCode": "PRN231",
    "slot": 1,
    "students": [
        {"rollNo": "SE182173", "fullName": "Bùi Nhật Minh", "email": "minhnbse182173@fpt.edu.vn", "status": "PRESENT"},
        {"rollNo": "SE171234", "fullName": "Nguyen Van Nam", "email": "namnvse171234@fpt.edu.vn", "status": "PRESENT"},
        {"rollNo": "SE180987", "fullName": "Tran Thi Mai", "email": "maittse180987@fpt.edu.vn", "status": "PRESENT"},
        {"rollNo": "SE183456", "fullName": "Le Hoang Long", "email": "longlhse183456@fpt.edu.vn", "status": "ABSENT"},
        {"rollNo": "SE185111", "fullName": "Pham Thu Ha", "email": "haptse185111@fpt.edu.vn", "status": "PRESENT"}
    ]
}

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Enable CORS for Chrome Extension and local requests
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        if self.path.startswith('/api/attendance'):
            self.send_response(200)
            self.send_header('Content-Type', 'application/json; charset=utf-8')
            self.end_headers()
            self.wfile.write(json.dumps(ATTENDANCE_DATA, ensure_ascii=False).encode('utf-8'))
            return
        return super().do_GET()

if __name__ == "__main__":
    os.chdir(DIRECTORY)
    # Allow port reuse immediately
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
        print(f"FAP Attendance Desktop Web Server running at http://localhost:{PORT}")
        print(f"API for Extension: http://localhost:{PORT}/api/attendance")
        httpd.serve_forever()
