import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# Load the TensorFlow Lite model
interpreter = tf.lite.Interpreter(model_path='converted_model.tflite')
interpreter.allocate_tensors()

# Get input and output details
input_details = interpreter.get_input_details()
print("Expected input shape:", input_details[0]['shape'])

# Set up the data generator for the test dataset
test_datagen = ImageDataGenerator(rescale=1./255)
test_generator = test_datagen.flow_from_directory(
    '/home/afonso/Documents/MLonBAO/TrainedModels/ImageNet',  # Confirm this is the correct path
    target_size=(128, 128),  # Adjust to the model's expected input size
    batch_size=1,            # Model does not support batching
    class_mode='categorical',
    shuffle=False)

# Function to predict using the interpreter
def predict(interpreter, input_data):
    print("Shape of input data before reshaping:", input_data.shape)
    if input_data.size == 0:
        raise ValueError("Input data is empty. Check the image loading process.")
    # Ensure input_data has the correct shape
    input_data = np.reshape(input_data, input_details[0]['shape'])
    interpreter.set_tensor(input_details[0]['index'], input_data)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    return output

# Evaluate the model
correct_predictions = 0
total_predictions = 0

# Iterate over the test data
for images, labels in test_generator:
    predictions = predict(interpreter, images)
    predicted_classes = np.argmax(predictions, axis=1)
    true_classes = np.argmax(labels, axis=1)
    correct_predictions += (predicted_classes == true_classes).sum()
    total_predictions += 1

    # Stop once all images are processed
    if total_predictions >= len(test_generator.filenames):
        break

# Calculate accuracy
accuracy = correct_predictions / total_predictions
print("Model accuracy on test set: {:.2f}%".format(accuracy * 100))
