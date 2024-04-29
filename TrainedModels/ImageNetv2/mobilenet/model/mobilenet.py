import cv2
import numpy as np
import tflite_runtime.interpreter as tflite
import time


# Path to the video file
video_path = 'video.mp4'

# Path to the TFLite model file
model_path = '1.tflite'

# Initialize the TFLite interpreter
interpreter = tflite.Interpreter(model_path=model_path)
interpreter.allocate_tensors()

# Get model input details and output details for processing
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Open the video
cap = cv2.VideoCapture(video_path)

frame_time = 1

while True:
    start_time = time.perf_counter()  # More accurate timing than time.time()
    # Read a frame
    success, frame = cap.read()
    
    if success:
        cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        resized_frame = cv2.resize(frame, (192, 192))
        
        model_input = np.expand_dims(resized_frame, axis=0).astype(np.uint8)

        # Perform inference
        interpreter.set_tensor(input_details[0]['index'], model_input)
        interpreter.invoke()
        
        # Get the model's output (adjust indices as necessary for your model)
        output_data = interpreter.get_tensor(output_details[0]['index'])
        print (output_data)
                       
        end_time = time.perf_counter()
        frame_time = (end_time - start_time) * 1000  # Calculate time in milliseconds
        print(frame_time)
        # Break the loop if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    else:
        print("Video file ended")
        break

# Release the video capture and close all OpenCV windows
cap.release()
cv2.destroyAllWindows()
