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

