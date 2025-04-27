from flask import Flask, request, jsonify, Response, send_from_directory, abort, send_file
from flask_cors import CORS
import yottadb
import os
import tempfile
import traceback
from functools import wraps

app = Flask(__name__)

# Configuration
CALLIN_TABLE = "/srv/calltab.ci"
BASE_DIR = "/srv"
UPLOAD_DIR = "/tmp/mumps_uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

# Initialize YottaDB Call-In
try:
    yottadb.switch_ci_table(yottadb.open_ci_table(CALLIN_TABLE))
    print("YottaDB Call-In interface initialized successfully")
except Exception as e:
    print(f"Failed to initialize Call-In: {e}")
    exit(1)

# ========================
# CORS ORIGIN FUNCTIONS
# ========================
def get_allowed_origins():
    """Fetch allowed CORS origins from YottaDB"""
    try:
        result = yottadb.cip("GETORIGINS", [], has_retval=True)
        print(result)
        if isinstance(result, bytes):
            result = result.decode('utf-8').strip()
        return [origin.strip() for origin in result.split(',') if origin.strip()]
    except Exception as e:
        print(f"Error fetching allowed origins: {traceback.format_exc()}")
        # Fallback to default if YottaDB call fails
        return ["https://oscarspawclub.com"]

# CORS Configuration with Auth support
allowed_origins = get_allowed_origins()
print("Allowed origins:", allowed_origins)
CORS(app, resources={
    r"/*": {
        "origins": allowed_origins,
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "X-API-Token", "Authorization"],
        "expose_headers": ["Authorization"],
        "supports_credentials": True,
        "max_age": 600
    }
})

# Supported file extensions
ALLOWED_EXTENSIONS = {
    '.html', '.htm', '.xhtml', '.js', '.css', '.json',
    '.jpg', '.jpeg', '.png', '.gif', '.svg', '.webp',
    '.mp4', '.webm', '.ogg', '.woff', '.woff2', '.ttf', '.eot',
    '.txt', '.pdf', '.ico'
}

# ========================
# AUTHENTICATION FUNCTIONS
# ========================
def requires_auth(path, host):
    """Check if path requires auth via YottaDB call-in"""
    try:
        print(host)
        result = yottadb.cip("REQUIRESAUTH", [path, host], has_retval=True)
        print(result)
        return result == b'1' if isinstance(result, bytes) else result == '1'
    except Exception as e:
        print(f"Error checking auth requirement: {traceback.format_exc()}")
        return False

def authenticate(username, password):
    """Validate credentials via YottaDB call-in"""
    try:
        result = yottadb.cip("VALIDATEUSER", [username, password], has_retval=True)
        return result == b'1' if isinstance(result, bytes) else result == '1'
    except Exception as e:
        print(f"Authentication error: {traceback.format_exc()}")
        return False

def check_auth(auth):
    """Validate Basic Auth credentials"""
    if not auth or not auth.username or not auth.password:
        return False
    return authenticate(auth.username, auth.password)

def basic_auth_required(f):
    """Decorator for routes requiring authentication"""
    @wraps(f)
    def decorated(*args, **kwargs):
        referrer = request.referrer
        print(f"Request came from: {referrer}")  # Log referrer (optional)
        hostname = request.host.split(':')[0]
        print("requires auth?")
        print(requires_auth(request.path, hostname))
        if requires_auth(request.path, hostname):
            auth = request.authorization
            if not check_auth(auth):
                return Response(
                    'Authentication required\n',
                    401,
                    {'WWW-Authenticate': 'Basic realm="Login Required"'})
        return f(*args, **kwargs)
    return decorated

# ===================
# UTILITY FUNCTIONS
# ===================

def get_home_path(hostname):
    """Get home path via YottaDB call-in"""
    try:
        result = yottadb.cip("GETHOMEPATH", [hostname], has_retval=True)
        if result:
            if isinstance(result, bytes):
                result = result.decode('utf-8').strip()
            clean_path = os.path.normpath(result.lstrip('/'))
            if not clean_path.startswith('..') and not os.path.isabs(clean_path):
                return clean_path
        return None
    except Exception as e:
        print(f"Error in GETHOMEPATH: {traceback.format_exc()}")
        return None

def write_payload(data):
    """Write payload to temp file"""
    try:
        with tempfile.NamedTemporaryFile(
            dir=UPLOAD_DIR,
            prefix="mumps_",
            delete=False,
            mode='wb'
        ) as f:
            if isinstance(data, str):
                data = data.encode('utf-8')
            f.write(data)
            return f.name
    except Exception as e:
        print(f"Error writing payload: {e}")
        return None

def video_stream(path):
    """Handle MP4 range requests"""
    range_header = request.headers.get('Range')
    if not range_header:
        return send_file(path)
    
    size = os.path.getsize(path)    
    byte1, byte2 = 0, None
    
    range_ = range_header.split('bytes=')[1].split('-')
    byte1 = int(range_[0])
    if len(range_) > 1 and range_[1]:
        byte2 = int(range_[1])
    
    length = size - byte1
    if byte2 is not None:
        length = byte2 - byte1 + 1
    
    with open(path, 'rb') as f:
        f.seek(byte1)
        data = f.read(length)
    
    rv = Response(data, 
                206,
                mimetype='video/mp4',
                direct_passthrough=True)
    rv.headers.add('Content-Range', f'bytes {byte1}-{byte1+length-1}/{size}')
    return rv

def serve_static_file(path):
    """Serve static files with security checks"""
    try:
        requested_path = os.path.join(BASE_DIR, path.lstrip('/'))
        requested_path = os.path.normpath(requested_path)
        
        if not requested_path.startswith(BASE_DIR):
            abort(403)
        
        if os.path.isdir(requested_path):
            for index in ['index.html', 'index.htm']:
                index_path = os.path.join(requested_path, index)
                if os.path.isfile(index_path):
                    return send_from_directory(requested_path, index)
            abort(404)
        
        if os.path.isfile(requested_path):
            if requested_path.endswith('.mp4'):
                return video_stream(requested_path)
            return send_from_directory(os.path.dirname(requested_path),
                                    os.path.basename(requested_path))
        
        if not os.path.splitext(requested_path)[1]:
            for ext in ALLOWED_EXTENSIONS:
                test_path = requested_path + ext
                if os.path.isfile(test_path):
                    if ext == '.mp4':
                        return video_stream(test_path)
                    return send_from_directory(os.path.dirname(test_path),
                                           os.path.basename(test_path))
        
        abort(404)
    except Exception as e:
        print(f"Error serving file: {traceback.format_exc()}")
        abort(500)

# ==============
# ROUTES
# ==============

@app.route('/test-auth')
@basic_auth_required
def test_auth():
    return jsonify({"message": "Authenticated successfully!"})

@app.route('/srv/<path:subpath>')
@basic_auth_required
def serve_from_srv(subpath):
    return serve_static_file(subpath)

@app.route('/mumps/<func_name>', methods=['GET', 'POST'])
@app.route('/<path:subpath>/mumps/<func_name>', methods=['GET', 'POST'])
@basic_auth_required
def mumps_gateway(subpath=None, func_name=None):
    temp_file = None
    try:
        if request.method == 'GET':
            args = list(request.args.values())
            result = yottadb.cip(func_name, args, has_retval=True)
        else:
            temp_file = write_payload(request.get_data())
            if not temp_file:
                return jsonify({"error": "Failed to process payload"}), 500
            result = yottadb.cip(func_name, [f"FILE:{temp_file}"], has_retval=True)
        
        if isinstance(result, bytes):
            result = result.decode('utf-8')
        return Response(result, mimetype='text/plain')
    except Exception as e:
        print(f"Error in {func_name}: {traceback.format_exc()}")
        return jsonify({"error": str(e)}), 500
    finally:
        if temp_file and os.path.exists(temp_file):
            try:
                os.unlink(temp_file)
            except Exception as e:
                print(f"Error deleting temp file: {e}")

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
@basic_auth_required
def catch_all(path):
    if path.startswith('srv/'):
        return serve_static_file(path[4:])
    
    if not path or path == '/':
        hostname = request.host.split(':')[0]
        home_path = get_home_path(hostname)
        
        if home_path:
            full_path = os.path.join(BASE_DIR, home_path)
            if os.path.exists(full_path):
                if os.path.isdir(full_path):
                    for index in ['index.html', 'index.htm']:
                        index_path = os.path.join(full_path, index)
                        if os.path.isfile(index_path):
                            return send_from_directory(full_path, index)
                return serve_static_file(home_path)
        
        return serve_static_file('index.html') if os.path.exists(os.path.join(BASE_DIR, 'index.html')) else "Not Found", 404
    
    return serve_static_file(path)

@app.after_request
def add_cors_headers(response):
    origin = request.headers.get('Origin')
    print("in origin code")
    print(origin)
    if origin and origin in allowed_origins:
        response.headers.add('Access-Control-Allow-Origin', origin)
        response.headers.add('Access-Control-Allow-Credentials', 'true')
        response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        response.headers.add('Access-Control-Allow-Headers', 'Content-Type, X-API-Token, Authorization')
        response.headers.add('Access-Control-Expose-Headers', 'Authorization')
        response.headers.add('Vary', 'Origin')
    return response

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9080)
