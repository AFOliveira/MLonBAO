import numpy as np
import tensorflow as tf

# Load the validation dataset
val_images = np.load('validation_images.npy')
val_labels = np.load('validation_labels.npy')

# Load the TensorFlow Lite model
interpreter = tf.lite.Interpreter(model_path='mnist_model.tflite')
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
for i in range(len(val_images)):
    input_data = np.expand_dims(val_images[i], axis=0).astype(np.float32)
    prediction = run_inference(interpreter, input_data)
    predicted_label = np.argmax(prediction)
    correct_predictions += (predicted_label == val_labels[i])

# Calculate the accuracy
accuracy = correct_predictions / len(val_labels)
print(f'TFLite model accuracy: {accuracy:.4f}')
