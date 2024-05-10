import numpy as np

# Load the array from .npy file
array = np.load('validation_images.npy')

flat_array = array.flatten()


# Save the array to a .txt file
np.savetxt('validation_images.txt', flat_array, fmt='%s')
