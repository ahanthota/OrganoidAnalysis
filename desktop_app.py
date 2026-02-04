import os
import sys
import threading
import webbrowser
import time
from flask import Flask, render_template, request, jsonify, send_file

if getattr(sys, 'frozen', False):
    application_path = sys._MEIPASS
else:
    application_path = os.path.dirname(os.path.abspath(__file__))

sys.path.insert(0, application_path)

from organoid_analysis import analyze_organoids as analyze_basic
from organoid_analysis_watershed import analyze_organoids_watershed
from organoid_analysis_hough import analyze_organoids_hough
from organoid_analysis_morphology import analyze_organoids_morphology
from organoid_analysis_commercial_sims import analyze_arivis_sim, analyze_assayscope_sim

try:
    from organoid_analysis_unet import analyze_organoids_unet
    UNET_AVAILABLE = True
except Exception as e:
    print(f"Warning: U-Net not available. Using fallback.")
    UNET_AVAILABLE = False
    def analyze_organoids_unet(image_paths):
        from organoid_analysis_unet import analyze_organoids_unet_fallback
        return analyze_organoids_unet_fallback(image_paths)

try:
    from organoid_analysis_stardist import analyze_organoids_stardist
    STARDIST_AVAILABLE = True
except Exception as e:
    print(f"Warning: StarDist not available. Using fallback.")
    STARDIST_AVAILABLE = False
    def analyze_organoids_stardist(image_paths):
        from organoid_analysis_stardist import analyze_organoids_stardist_fallback
        return analyze_organoids_stardist_fallback(image_paths)

app = Flask(__name__, 
            template_folder=os.path.join(application_path, 'templates'),
            static_folder=os.path.join(application_path, 'static'))

if getattr(sys, 'frozen', False):
    app_root = os.path.dirname(sys.executable)
else:
    app_root = os.path.dirname(os.path.abspath(__file__))

UPLOAD_FOLDER = os.path.join(app_root, 'static', 'uploads')
RESULTS_FOLDER = os.path.join(app_root, 'static', 'results')

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['RESULTS_FOLDER'] = RESULTS_FOLDER

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(RESULTS_FOLDER, exist_ok=True)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/methods')
def methods():
    methods_path = os.path.join(application_path, 'methods_explanation.html')
    if os.path.exists(methods_path):
        return send_file(methods_path)
    return "Methods explanation not found", 404

@app.route('/analyze', methods=['POST'])
def analyze():
    try:
        if 'images[]' not in request.files:
            return jsonify({'error': 'No images uploaded'}), 400
        
        files = request.files.getlist('images[]')
        method = request.form.get('method', 'basic')
        
        if not files or files[0].filename == '':
            return jsonify({'error': 'No selected file'}), 400
        
        image_map = {}
        saved_paths = []
        
        files.sort(key=lambda x: x.filename)

        for i, file in enumerate(files):
            if file and file.filename:
                filename = file.filename
                filepath = os.path.join(UPLOAD_FOLDER, filename)
                try:
                    file.save(filepath)
                    day_label = i + 1
                    image_map[day_label] = filepath
                    saved_paths.append(filepath)
                except Exception as e:
                    print(f"Error saving file {filename}: {e}")
                    return jsonify({'error': f'Failed to save file {filename}: {str(e)}'}), 500

        if not image_map:
            return jsonify({'error': 'No valid images were uploaded'}), 400

        print(f"Running {method} analysis on {len(saved_paths)} images...")
        
        try:
            if method == 'watershed':
                results = analyze_organoids_watershed(image_map)
                debug_subfolder = 'debug_output_watershed'
            elif method == 'hough':
                results = analyze_organoids_hough(image_map)
                debug_subfolder = 'debug_output_hough'
            elif method == 'stardist':
                results = analyze_organoids_stardist(image_map)
                if isinstance(results, dict) and "error" in results:
                    return jsonify({'error': results["error"]}), 500
                debug_subfolder = 'debug_output_stardist'
            elif method == 'morphology':
                results = analyze_organoids_morphology(image_map)
                debug_subfolder = 'debug_output_morphology'
            elif method == 'arivis':
                results = analyze_arivis_sim(image_map)
                debug_subfolder = 'debug_output_arivis'
            elif method == 'assayscope':
                results = analyze_assayscope_sim(image_map)
                debug_subfolder = 'debug_output_assayscope'
            elif method == 'unet':
                results = analyze_organoids_unet(image_map)
                if isinstance(results, dict) and "error" in results:
                    return jsonify({'error': results["error"]}), 500
                debug_subfolder = 'debug_output_unet'
            else:
                results = analyze_organoids_basic_wrapper(image_map)
                debug_subfolder = 'debug_output'
            
            if results is None:
                return jsonify({'error': 'Analysis returned None. Please check your images and try again.'}), 500
            
            if not isinstance(results, list):
                return jsonify({'error': f'Analysis returned invalid format. Expected list, got {type(results)}'}), 500
            
            if len(results) == 0:
                return jsonify({'error': 'Analysis returned no results. Please check your images and try again.'}), 500
                
            processed_results = []
            for res in results:
                if not isinstance(res, dict):
                    print(f"Warning: Skipping invalid result: {res}")
                    continue
                    
                if 'day' not in res:
                    print(f"Warning: Result missing 'day' field: {res}")
                    continue
                    
                day = res['day']
                
                if method == 'watershed':
                    debug_name = f"watershed_debug_day{day}.jpg"
                elif method == 'hough':
                    debug_name = f"hough_debug_day{day}.jpg"
                elif method == 'stardist':
                    debug_name = f"stardist_debug_day{day}.jpg"
                elif method == 'morphology':
                    debug_name = f"morphology_debug_day{day}.jpg"
                elif method == 'arivis':
                    debug_name = f"arivis_debug_day{day}.jpg"
                elif method == 'assayscope':
                    debug_name = f"assayscope_debug_day{day}.jpg"
                elif method == 'unet':
                    debug_name = f"unet_debug_day{day}.jpg"
                else:
                    debug_name = f"debug_day{day}.jpg"

                debug_url = f"/static/uploads/{debug_subfolder}/{debug_name}"
                
                orig_filename = os.path.basename(image_map.get(day, ''))
                orig_url = f"/static/uploads/{orig_filename}"

                res['original_url'] = orig_url
                res['debug_url'] = debug_url
                processed_results.append(res)
            
            if len(processed_results) == 0:
                return jsonify({'error': 'No valid results after processing. Please check your images.'}), 500
                
            return jsonify({
                'success': True,
                'method': method,
                'results': processed_results
            })

        except Exception as e:
            import traceback
            error_trace = traceback.format_exc()
            print(f"Analysis Error: {e}")
            print(f"Traceback:\n{error_trace}")
            return jsonify({
                'error': f'Analysis failed: {str(e)}',
                'details': error_trace.split('\n')[-2] if len(error_trace.split('\n')) > 1 else None
            }), 500

    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"Server Error: {e}")
        print(f"Traceback:\n{error_trace}")
        return jsonify({
            'error': f'Server error: {str(e)}',
            'details': error_trace.split('\n')[-2] if len(error_trace.split('\n')) > 1 else None
        }), 500

def analyze_organoids_basic_wrapper(image_map):
    return analyze_basic(image_map)

def open_browser(port_num):
    time.sleep(1.5)
    webbrowser.open(f'http://127.0.0.1:{port_num}')

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    threading.Thread(target=open_browser, args=(port,), daemon=True).start()
    app.run(host='127.0.0.1', port=port, debug=False, use_reloader=False)
