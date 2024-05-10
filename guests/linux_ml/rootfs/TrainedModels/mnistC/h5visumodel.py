import tensorflow as tf
from tensorflow.keras.models import load_model

# Load the model from the HDF5 file
model = load_model('mnist_model.h5')

# Print the model summary
model.summary()
