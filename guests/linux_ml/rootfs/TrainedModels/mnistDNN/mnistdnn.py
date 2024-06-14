import tensorflow as tf
from tensorflow.keras.layers import Input, Dense
from tensorflow.keras.models import Model
from tensorflow.keras.datasets import mnist
import numpy as np
from sklearn.model_selection import train_test_split

# Load the MNIST dataset
(train_images, train_labels), (test_images, test_labels) = mnist.load_data()

# Preprocess the data
train_images = train_images.reshape((train_images.shape[0], 784)).astype('float32') / 255
test_images = test_images.reshape((test_images.shape[0], 784)).astype('float32') / 255

# Split the training data into a custom train and validation set (70% train, 30% validation)
train_images, val_images, train_labels, val_labels = train_test_split(
    train_images, train_labels, test_size=0.3, random_state=42)

# Define the model architecture
input_layer = Input(shape=(784,))
fc0 = Dense(40, activation='tanh')(input_layer)
fc1 = Dense(32, activation='tanh')(fc0)
output_layer = Dense(10, activation='sigmoid')(fc1)

# Create the model
model = Model(inputs=input_layer, outputs=output_layer)

# Compile the model
model.compile(optimizer='adam', 
              loss='sparse_categorical_crossentropy', 
              metrics=['accuracy'])

# Train the model
model.fit(train_images, train_labels, epochs=2, validation_data=(val_images, val_labels))

# Evaluate the model on the original test set
test_loss, test_accuracy = model.evaluate(test_images, test_labels)
print(f'Test accuracy: {test_accuracy}')

# Save the model in HDF5 format (optional here, shown for demonstration)
model.save('mnist_model.h5')
print("Model saved as mnist_model.h5")

# Save the validation images and labels as .npy files
np.save('validation_images.npy', val_images)
np.save('validation_labels.npy', val_labels)
print("Validation data saved as NumPy arrays.")

# Convert the model to TensorFlow Lite format
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT] # Add quantization options here 

tflite_model = converter.convert()

# Save the TFLite model to a file
with open('mnist_model.tflite', 'wb') as f:
    f.write(tflite_model)
print("TFLite model saved as mnist_model.tflite")
