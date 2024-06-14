from time import perf_counter
start_time2 = perf_counter()  # Start timing

import numpy as np
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

#f = open('inference_times.txt', 'w')

# Evaluate the model on the validation dataset
correct_predictions = 0
total_inferences = 0
inference_time = 0
for i in range(len(val_images)):
    input_data = np.expand_dims(val_images[i], axis=0).astype(np.float32)
    
    start_time = perf_counter()  # Start timing
    prediction = run_inference(interpreter, input_data)
    end_time = perf_counter()  # End timing
    
    inference_time += (end_time - start_time)
    #print(f"Inference time: {end_time - start_time:.6f} seconds")
    #f.write(f"{end_time - start_time:.6f}\n")
    
    predicted_label = np.argmax(prediction)
    correct_predictions += (predicted_label == val_labels[i])
    total_inferences = total_inferences + 1

# Calculate the accuracy
accuracy = correct_predictions / len(val_labels)
print(f'TFLite model accuracy: {accuracy}')

print (f'Total inferences: {total_inferences}')
print (f'Total inference time: {inference_time:.6f} seconds')
print (f'')

#Finish timing
final_time2 = perf_counter()
print(f"Total time: {final_time2 - start_time2:.6f} seconds")
