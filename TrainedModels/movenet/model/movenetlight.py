import cv2
import numpy as np
import tflite_runtime.interpreter as tflite
import time


# Path to the video file
video_path = 'video.mp4'

# Path to the TFLite model file
model_path = '3.tflite'

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
        
        model_input = np.expand_dims(resized_frame, axis=0).astype(np.float32)

        # Perform inference
        interpreter.set_tensor(input_details[0]['index'], model_input)
        interpreter.invoke()
        
        # Get the model's output (adjust indices as necessary for your model)
        output_data = interpreter.get_tensor(output_details[0]['index'])
        
        # Process the output data
        keypoints = output_data[0, 0, :, :2]  # Assuming coordinates are in the first two channels
        confidences = output_data[0, 0, :, 2]  # Assuming confidence scores are in the third channel

        radius = 1  # Adjust radius as desired
        color = (0, 255, 0)  # Green color for keypoints
        thickness = 2  

        # Example: Print keypoints and confidence scores
        for i in range(len(keypoints)):
            x, y = keypoints[i]
            confidence = confidences[i]
            print(f"Keypoint {i}: ({x:.2f}, {y:.2f}), Confidence: {confidence:.2f}") 
            x = int(x * resized_frame.shape[1]) 
            y = int(y * resized_frame.shape[0])
            if (confidence>0.2):
                cv2.circle(resized_frame, (y, x), radius, color, thickness)

        fps = 1000 / frame_time  # Calculate FPS (assuming frame_time is in milliseconds)

        # Prepare FPS message
        fps_message = f"FPS: {fps:.2f}"
        print(fps_message)
        # Put the FPS message on the frame
        cv2.putText(resized_frame, fps_message, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 
                    0.4, (0, 255, 0), 1)  # Green text, thickness 2

        # Display the resized frame
        cv2.imshow('Resized Frame', resized_frame)
        
        end_time = time.perf_counter()
        frame_time = (end_time - start_time) * 1000  # Calculate time in milliseconds
        print(frame_time)
        # Break the loop if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    else:
        break

# Release the video capture and close all OpenCV windows
cap.release()
cv2.destroyAllWindows()
