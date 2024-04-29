import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Dense, Conv2D, Flatten, MaxPooling2D, Input
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.model_selection import train_test_split

# Load the dataset
# Assuming you have ImageNet data in 'train' and 'val' directories
train_datagen = ImageDataGenerator(rescale=1./255)
val_datagen = ImageDataGenerator(rescale=1./255)

train_generator = train_datagen.flow_from_directory(
        '/home/afonso/Documents/MLonBAO/TrainedModels/ImageNet',
        target_size=(224, 224),
        batch_size=32,
        class_mode='categorical')

validation_generator = val_datagen.flow_from_directory(
        '/home/afonso/Documents/MLonBAO/TrainedModels/ImageNet',
        target_size=(224, 224),
        batch_size=32,
        class_mode='categorical')

# Build the model using MobileNetV2 pre-trained on ImageNet
base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))  # include_top=False excludes the final dense layers
x = base_model.output
x = Flatten()(x)
x = Dense(1024, activation='relu')(x)
outputs = Dense(1000, activation='softmax')(x)  # 1000 classes in ImageNet
model = Model(inputs=base_model.input, outputs=outputs)

# Compile the model
model.compile(optimizer='adam', 
              loss='categorical_crossentropy', 
              metrics=['accuracy'])

# Train the model
model.fit(train_generator, epochs=1, validation_data=validation_generator)

# Evaluate the model on the validation set
val_loss, val_acc = model.evaluate(validation_generator)
print('Validation accuracy:', val_acc)

# TensorFlow Lite conversion
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS,
    tf.lite.OpsSet.SELECT_TF_OPS
]
converter.allow_custom_ops = True

try:
    tflite_model = converter.convert()
    # Save the TFLite model to a file
    with open('imagenet_model.tflite', 'wb') as f:
        f.write(tflite_model)
    print("TFLite model and validation data are saved.")
except Exception as e:
    print("Failed to convert model to TensorFlow Lite format:", e)
