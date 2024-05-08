import numpy as np
from time import perf_counter
from tflite_runtime.interpreter import Interpreter


# Load the validation dataset
val_images = np.load('validation_images.npy')
val_labels = np.load('validation_labels.npy')

# Load the TensorFlow Lite model
interpreter = Interpreter(model_path='cifar10_model.tflite')
interpreter.allocate_tensors()

# Get input and output tensors
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# A function to perform inference
def run_inference(interpreter, input_data):
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    output_data = interpreter.get_tensor(output_details[0]['index'])
    return output_data

# Evaluate the model on the validation dataset
correct_predictions = 0
total_images = len(val_images)  # Ensuring the total count is a scalar integer
for i in range(total_images):
    input_data = np.expand_dims(val_images[i], axis=0).astype(np.float32)
    start_time = perf_counter()  # Start timing
    prediction = run_inference(interpreter, input_data)
    end_time = perf_counter()  # End timing
    print(f"Inference time: {end_time - start_time:.6f} seconds")
    predicted_label = np.argmax(prediction)
    correct_predictions += (predicted_label == val_labels[i])

# Calculate the accuracy and ensure it is a float
accuracy = float(correct_predictions) / total_images
print(f'TFLite model accuracy: {accuracy:.4f}')
