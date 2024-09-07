# Image Caption Generation in Bengali

This project implements an image caption generation model specifically tailored for Bengali language descriptions. The system is deployed using a Flask API, which allows users to upload images and receive corresponding Bengali captions via a Flutter application.

## Features
- **Image Caption Generation**: Generates captions for uploaded images in Bengali.
- **Flask API**: An API is built using Flask that handles image uploads and returns captions.
- **Pre-trained Model**: The caption generation model is pre-trained and can be loaded to handle image input.
- **Local Execution**: The API is designed to run **locally only**.

## Model Details
- The model is trained on a dataset of **17,693 images**, each paired with **5 captions** in Bengali.
  
## Prerequisites
Before you run the API, make sure to have the following:
1. Python 3.8.10 (or above if compatible) installed
2. Required dependencies installed (use `requirements.txt`)

   ```bash
   pip install -r requirements.txt
   ```

3. **Model Weights**: Ensure that the pre-trained model weights are added to the `ImgCap` package. Without these, the API will not function correctly.

## Running the Flask API
To start the Flask API, follow these steps:

1. Run the `main.py` file to start the API:

   ```bash
   python main.py
   ```

2. After execution, an IP address will be displayed on the console. This IP will be used to send requests to the API.

3. **Update IP Address**: Make sure to update the app (or client) with the correct IP address shown on the console after running the API.

## Notes
- Ensure that the saved weights are correctly placed in the `ImgCap` package as they are crucial for the model's functionality.
- The IP address displayed in the console is dynamic and will change every time the Flask server is restarted. Make sure to update the IP address in app accordingly.
- This API is intended for local use only.
