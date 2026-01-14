import google.generativeai as genai
import time

# 1. Setup your API Key
# Get an API key from https://aistudio.google.com/
genai.configure(api_key="YOUR_API_KEY_HERE")

def analyze_piano_performance(video_file_path):
    # 2. Upload the video file to Google's servers
    print(f"Uploading file: {video_file_path}...")
    video_file = genai.upload_file(path=video_file_path)
    print(f"Completed upload: {video_file.uri}")

    # 3. Wait for the video to be processed (crucial for long videos)
    while video_file.state.name == "PROCESSING":
        print('.', end='', flush=True)
        time.sleep(10)
        video_file = genai.get_file(video_file.name)

    if video_file.state.name == "FAILED":
        raise ValueError(video_file.state.name)

    # 4. Initialize the Gemini 1.5 Pro model
    model = genai.GenerativeModel(model_name="gemini-1.5-pro")

    # 5. Define the exact prompt
    prompt = """
    Analyze this piano performance for a music student across 4 quadrants:

    1. Technical Skills & Competence: Evaluate technique, timing, accuracy
    2. Compositional & Musicianship Knowledge: Assess musical understanding, phrasing
    3. Repertoire & Cultural Knowledge: Identify piece and stylistic appropriateness
    4. Performing Artistry: Evaluate expression and artistic interpretation

    Provide scores (1-100) and feedback for each quadrant.
    """

    # 6. Generate the analysis
    print("\nAnalyzing performance...")
    response = model.generate_content([video_file, prompt])

    return response.text

# Usage
if __name__ == "__main__":
    # Replace with the path to your video file
    video_path = "performance_video.mp4"
    analysis_report = analyze_piano_performance(video_path)
    print("\n--- PERFORMANCE ANALYSIS REPORT ---\n")
    print(analysis_report)
