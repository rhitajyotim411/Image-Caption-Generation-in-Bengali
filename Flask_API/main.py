import os
from flask import *
from ImgCap import captioner as cap

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = 'uploaded_images'

if not os.path.exists(app.config['UPLOAD_FOLDER']):
    os.makedirs(app.config['UPLOAD_FOLDER'])


@app.route('/')
def main():
    return "Image Caption Generation in Bengali"


@app.route('/upload', methods=['POST'])
def upload_image():

    if 'image' not in request.files:
        return jsonify({"error": "No image provided."}), 400

    image = request.files['image']
    if image.filename == '':
        return jsonify({"error": "No selected file."}), 400

    if image:
        global extension
        for item in os.listdir(app.config['UPLOAD_FOLDER']):
            item_path = os.path.join(app.config['UPLOAD_FOLDER'], item)
            if os.path.isfile(item_path):
                os.remove(item_path)

        extension = image.filename.split(".")[-1]
        filename = os.path.join(
            app.config['UPLOAD_FOLDER'], "image."+extension)
        # filename = os.path.join(app.config['UPLOAD_FOLDER'], image.filename)
        image.save(filename)
        return jsonify({"message": "Image uploaded successfully."})


@app.route('/caption')
def success():
    return predict(f'image.'+extension)


def predict(img):
    return cap.generate(f'./uploaded_images/{img}')


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5000)
