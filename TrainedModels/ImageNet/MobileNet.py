import tensorflow as tf

# Path to the extracted folder containing the saved_model.pb file and the variables folder
saved_model_dir = '//home/afonso/Documents/MLonBAO/TrainedModels/ImageNet/model'

# Convert the model to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
tflite_model = converter.convert()

# Save the converted model to a .tflite file
with open('converted_model.tflite', 'wb') as f:
    f.write(tflite_model)

print("Model has been converted to TensorFlow Lite format.")