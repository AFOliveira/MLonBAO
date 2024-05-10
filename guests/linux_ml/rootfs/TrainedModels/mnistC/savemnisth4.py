import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Dense, Conv2D, Flatten, MaxPooling2D, Input
from tensorflow.keras.datasets import mnist
from sklearn.model_selection import train_test_split

# Load the dataset
(train_images, train_labels), _ = mnist.load_data()

# Preprocess the data
train_images = train_images.reshape((train_images.shape[0], 28, 28, 1)).astype('float32') / 255

# Reduce dataset size to a smaller subset for example 10%
sample_size = len(train_images)  # Using only 10% of the data
small_train_images = train_images[:sample_size]
small_train_labels = train_labels[:sample_size]

# Split the reduced data into training and validation sets (70% train, 30% validation)
train_images, val_images, train_labels, val_labels = train_test_split(
    small_train_images, small_train_labels, test_size=0.3, random_state=42)

# Build the model using Functional API
inputs = Input(shape=(28, 28, 1))
x = Conv2D(32, (3, 3), activation='relu')(inputs)
x = MaxPooling2D((2, 2))(x)
x = Flatten()(x)
x = Dense(128, activation='relu')(x)
outputs = Dense(10, activation='softmax')(x)
model = Model(inputs=inputs, outputs=outputs)

# Compile the model
model.compile(optimizer='adam', 
              loss='sparse_categorical_crossentropy', 
              metrics=['accuracy'])

# Train the model
model.fit(train_images, train_labels, epochs=1, validation_data=(val_images, val_labels))

# Evaluate the model on the validation set
val_loss, val_acc = model.evaluate(val_images, val_labels)
print('Validation accuracy:', val_acc)

# Save the validation images and labels to .npy files
np.save('validation_images.npy', val_images)
np.save('validation_labels.npy', val_labels)
print(val_labels)

# Save the model to an HDF5 file
model.save('mnist_model.h5')
print("Model saved in HDF5 format.")
